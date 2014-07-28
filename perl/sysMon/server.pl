#!/usr/bin/perl 
use strict; 
use IO::Socket; 
use POSIX qw(:signal_h WNOHANG setsid); 
use Net::SMTP; 
use Fcntl qw(:DEFAULT :flock); 
 
#  电子邮件地址，用来接受报警 
my @emails = ( 
		'sa@sample-inc.com', 
		'dba@sample-inc.com', 
		#  其他email地址 
	    ); 
#  程序运行的主目录，这里是写死的，需要修改成自己的目录，或写成配置文件 
my $rundir = '/home/afoo/monsvr'; 
#  程序运行的 PID文件 
my $pid_file = $rundir . "/monsvr.pid"; 
#  配置文件，定义各客户端的 IP及扫描参数 
my $cfg_file = $rundir . "/monsvr.cf"; 
# 2 个日志文件，错误日志及运行日志 
my $err_log = $rundir. "/monsvr.err"; 
my $log_file = $rundir. "/monsvr.log"; 
#  客户端的运行端口 
my $agent_port = 7780; 
#  主循环退出的条件，等于 0 不退出，大于 0退出 
my $DONE = 0; 
#  每10 分钟执行一次扫描 
my $scan_inter = 10;   
#  最后一次扫描的时间 
my $last_scan_time = 0; 
#  记录子进程 ID的状态表 
my %status; 
# MTA主机的 IP及端口，用来发送报警邮件。 
# Linux 默认安装了 sendmail，打开它即可。 
my $mtahost = '127.0.0.1'; 
my $mtaport = 25; 
 
#  安装自己的信号处理器 
#  子进程退出时，从状态表里删掉子进程 ID 
$SIG{CHLD}=sub {while((my $child=waitpid(-1,WNOHANG))>0){delete $status{$child}}}; 
# SIGTERM或 SIGINT 信号导致程序退出 
$SIG{TERM}=$SIG{INT}=sub {$DONE++}; 
#  发送 HUP 信号可让程序 reload 自身（kill –HUP `cat monsvr.pid`） 
$SIG{HUP}=\&do_hup; 
# die 和 warn调用时，将输出重定向到日志文件 
$SIG{__DIE__}=\&log_die; 
$SIG{__WARN__}=\&log_warn; 

#  获取进程状态，首先从PID文件里获取已在运行的进程ID （如果有的话），如果kill 0 =>$pid
#  返回真，则表示进程已在运行，服务拒绝启动。如果 PID文件不可写，服务也拒绝启动。 
if (-e $pid_file) 
{ 
	open (PIDFILE,$pid_file) or die "[EMERG] $!\n"; 
	my $pid=<PIDFILE>; 
	close PIDFILE; 
 
        die "[EMERG] process is still run\n" if kill 0 => $pid; 
        die "[EMERG] can't remove pid file\n" unless -w $pid_file && unlink $pid_file; 
} 
 
#  程序进入后台，并将自身的进程 ID写入 PID 文件。 
open (HDW,">",$pid_file) or die "[EMERG] $!\n"; 
my $pid=daemon(); 
print HDW $pid; 
close HDW; 
 
#  主循环 
while (!$DONE) 
{ 
	#  如果距上一次扫描的时间间歇大于$scan_inter定义的分钟，并且没有扫描子进程存在，则
	#  启动一个扫描子进程 
        if ( (time - $last_scan_time > $scan_inter * 60) && ! %status ) { 
		#  启动扫描后，将最后一次扫描的时间，更新为当前时间 
		$last_scan_time = time; 
	 
		#  设置信号掩码，屏蔽前面重载的几个信号，防止这几个信号在 fork的时候进入 
		my $signals = POSIX::SigSet->new(SIGHUP,SIGINT,SIGTERM,SIGCHLD); 
		sigprocmask(SIG_BLOCK,$signals); 

		# fork 子进程 
		my $child = fork(); 
		die "can't fork $!" unless defined $child; 
	 
		#  父进程里取消信号掩码 
		if ($child) { 
			$status{$child} =1; 
			sigprocmask(SIG_UNBLOCK,$signals); 
	 
		#  子进程里先将 HUP，INT，TERM，CHLD信号恢复成默认，然后也取消信号掩码。 
		#  然后子进程调用 do_scan()函数进行扫描和报警，处理完后就写日志并退出 
		} else { 
			$SIG{HUP} = $SIG{INT} = $SIG{TERM} = $SIG{CHLD} = 'DEFAULT'; 
			sigprocmask(SIG_UNBLOCK,$signals); 

			my $results = do_scan(); 
			do_warn($results) if @$results; 
			write_log("[$$]",">>>All scan finished<<<"); 

			exit 0; 
		} 
	} 
 
	#  父进程休眠 10 秒，并继续循环 
	sleep 10; 
} 
 
#------------------- 
#  下面定义子函数 
#------------------- 
 
#  使程序进入后台的函数，原理很简单，就是 fork 一个子进程，父进程 die 掉，子进程调用
#  setsid()使自己成为进程组的领导。然后重定向 3 个标准 I/O设备到/dev/null。 
sub daemon 
{ 
	my $child = fork(); 
	die "[EMERG] can't fork\n" unless defined $child; 
	exit 0 if $child; 
	setsid(); 

	open (STDIN, "</dev/null"); 
	open (STDOUT, ">/dev/null"); 
	open (STDERR,">&STDOUT"); 

	chdir $rundir; 
	umask(022); 
	$ENV{PATH}='/bin:/usr/bin:/sbin:/usr/sbin'; 

	return $$; 
} 

#  写日志的函数 
sub write_log 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$log_file); 
	flock (HDW,LOCK_EX); 
	print HDW $time,"  ",join ' ',@_,"\n"; 
	flock (HDW,LOCK_UN); 
	close HDW; 
} 
 
#  当调用die时，会执行这个函数。也就是先将异常消息写入错误日志，再真正的 die。 
sub log_die 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
	die @_; 
} 
 
#  当调用 warn 时，会执行这个函数。 
sub log_warn 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
} 
 
#  扫描函数 
sub do_scan 
{ 
	#  先读取配置文件，获取要扫描的 IP，以及扫描哪些选项 
	my $scan_cfg = get_config(); 
	#  这个数组用来记录扫描结果 
	my @results; 

	#  在 for循环里逐台扫描 
	for my $hid (keys %{$scan_cfg}) { 
		#  在 eval 里执行扫描，并设置超时 30 秒。如果 30 秒内客户端未返回结果（客户端所在的
		#  主机负载很重时，可能会这样），则记录扫描异常的结果。 
		eval { 
			local  $SIG{ALRM}  =  sub  {die  "Scan  Timeout,$scan_cfg->{$hid}->{IP}  is wrong\n"}; 
			alarm 30;  
			my $re = scan_a_host($scan_cfg->{$hid}); 
			@results = (@results,@$re); 
			alarm 0; 
		}; 
		push @results,"Scan Timeout,$scan_cfg->{$hid}->{IP} is wrong" if $@; 
	} 
	return \@results; 
} 

#  单独扫描某台机的函数 
sub scan_a_host 
{ 
	my $host = shift;    # a hash ref 
	my @results; 
 
	#  创建到客户端的 socket 
        my $sock=IO::Socket::INET->new(PeerAddr => $host->{IP}, 
                                       PeerPort => $agent_port, 
                                       Proto    => 'tcp'); 

	#  如果创建 socket 不成功，则说明客户端的监听端口可能 down 了 
        unless (defined $sock) { 
		push @results, "$host->{IP}: monitor client seems down"; 
		warn("[WARN] $host->{IP}: monitor client seems down\n"); 
		return \@results; 
        }  
     
        write_log("[$$]", "prepare to do_scan for $host->{IP}"); 

	#  把配置文件里定义的扫描选项，发送到 client 
        for my $key (keys %{$host}) { 
		print $sock "$key  $host->{$key}\n" 
        } 

	#  发送完后关闭写 socket，这步很重要，否则 client 不知道 server 已写完，会阻塞在那里等
	#  待，并造成和 server的交互阻塞。 
        $sock->shutdown(1); 
 
	#  在 while 循环里读取客户端返回的扫描结果 
        while(<$sock>) { 
		chomp; 
		push @results,$_; 
        } 
 
	#  关闭 socket 并返回结果给调用者 
        $sock->close; 
        return \@results; 
} 

#  该函数用来读取配置文件，并将结果放入一个 Hash。纯文本处理，没有特殊的技巧。请
#  对照配置文件的格式阅读该函数。 
sub get_config 
{ 
	my %config; 
        open (HDR,$cfg_file) or die "[EMERG] can't open cfg_file: $!\n"; 
 
	while(<HDR>) 
	{ 
		next if /^$/; 
		next if /^\s*\#/; 

		if ( my ($hid) = /\[HOST (\d+)\]/ ) { 
			while (<HDR>) { 
				next if /^$/; 
				next if /^\s*\#/; 
				last if /\[\/HOST\]/; 
				chomp; 

				my ($cfg_key,$cfg_value) = split /=/; 
				$cfg_key =~ s/^\s+|\s+$//g; 

				$cfg_value =~ s/\#.*$//; 
				$cfg_value =~ s/^\s+|\s+$//g; 
				$cfg_value =~ s/^\"|\"$//g; 
				$cfg_value =~ s/^\'|\'$//g; 

				$config{$hid}->{$cfg_key} = $cfg_value; 
			} 
		} 
	} 

	close HDR; 
	return \%config; 
} 

#  告警函数，若扫描有异常，则一方面写入日志，另一方面发送电子邮件报警 
sub do_warn 
{ 
	my $warns = shift; 

	for (@$warns) { 
		write_log($_); 
	} 
	sendmail($warns); 
} 
 
#  发送电子邮件的函数 
sub sendmail 
{ 
        my $msg = shift; 
        return unless @emails; 
 
        my $smtp = Net::SMTP->new('Host'=>$mtahost,'Port'=>$mtaport); 
         
        if(defined $smtp) 
        { 
                $smtp->mail("monitor\@sample-inc.com"); 
                $smtp->recipient(@emails); 
                $smtp->data(); 
 
                $smtp->datasend("From: Server Monitor <monitor\@sample-inc.com>\n"); 
                $smtp->datasend("To: SA Team <sa\@sample-inc.com>\n"); 
                $smtp->datasend("Subject: Server Warnings\n"); 
                $smtp->datasend("\n"); 
 
                for (@$msg) { 
                    $smtp->datasend("$_\n"); 
                } 
 
                $smtp->dataend(); 
                $smtp->quit; 
 
        } else { 
                warn("[WARN] Can't connect to SMTP host\n"); 
        } 
} 

#  发送 SIGTERM 信号，killall 子进程，并 sleep 直到所有子进程都退出 
sub kill_children 
{ 
	kill TERM => keys %status; 
	sleep while %status; 
} 
 
#  在遇到 SIGHUP 信号时，执行本函数 reload自身 
sub relaunch 
{ 
	chdir $rundir; 
	unlink $pid_file; 
	exec 'perl','monsvr'; 
} 

#  处理 SIGHUP 信号 
sub do_hup 
{ 
	warn "[INFO] received SIGHUP,prepare to reload...\n"; 
	kill_children(); 
 
	relaunch(); 
        die "[EMERG] reload failed\n"; 
} 

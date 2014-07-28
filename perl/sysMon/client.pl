#!/usr/bin/perl 
use strict; 
use IO::Socket; 
use POSIX qw(:signal_h WNOHANG setsid); 
use Fcntl qw(:DEFAULT :flock); 
 
#  如下是扫描系统的外部命令，如前所述，你也可以改成系统内部调用 
#  请自行调整外部命令的路径 
my $NC = '/usr/bin/nc'; 
my $CAT = '/bin/cat'; 
my $PING = '/bin/ping'; 
my $NETSTAT = '/bin/netstat'; 
my $UPTIME = '/usr/bin/uptime'; 
my $IFCONFIG = '/sbin/ifconfig'; 
my $DF = '/bin/df'; 
my $FREE = '/usr/bin/free'; 
 
#  程序运行目录 
my $rundir = '/home/afoo/monagt'; 
# PID文件及配置文件 
my $pid_file = $rundir . "/monagt.pid"; 
my $err_log = $rundir. "/monagt.err"; 
my $log_file = $rundir. "/monagt.log"; 
#  监听端口 
my $agent_port = 7780; 
#  主循环退出的条件，跟 server一样 
my $DONE = 0; 
#  记录子进程的状态表 
my %status; 
 
#  重载信号处理器，跟 server一样 
$SIG{CHLD}=sub {while((my $child=waitpid(-1,WNOHANG))>0){delete $status{$child}}}; 
$SIG{TERM}=$SIG{INT}=sub {$DONE++}; 
$SIG{HUP}=\&do_hup; 
$SIG{__DIE__}=\&log_die; 
$SIG{__WARN__}=\&log_warn; 

#  运行前先获取进程状态，跟 server 一样
if (-e $pid_file) 
{ 
        open (PIDFILE,$pid_file) or die "[EMERG] $!\n"; 
	my $pid=<PIDFILE>; 
	close PIDFILE; 
 
        die "[EMERG] process is still run\n" if kill 0 => $pid; 
        die "[EMERG] can't remove pid file\n" unless -w $pid_file && unlink $pid_file; 
} 
 
#  程序进入后台 
open (HDW,">",$pid_file) or die "[EMERG] $!\n"; 
my $pid=daemon(); 
print HDW $pid; 
close HDW; 
 
#  获取内外网 IP。如前所述，监控客户端为了安全起见，运行在内网 IP 上。这里假设内网
#  IP段是 192.168.xx.xx。如果不是，请修改成自己的 IP格式。 
#  $inner_addr是内网 IP，$exter_addr是外网 IP。如果没有外网 IP，则都使用内网 IP。 
my @ifconfig = `$IFCONFIG`; 
my ($inner_line) = grep {/inet addr\:192\.168\./} @ifconfig; 
my ($exter_line) = grep {/inet addr\:/ && ! /192\.168\./ && ! /127\.0\.0\./} @ifconfig; 
my ($inner_addr) = $inner_line =~ /inet addr\:(\d+\.\d+\.\d+\.\d+)/; 
my ($exter_addr) = $exter_line =~ /inet addr\:(\d+\.\d+\.\d+\.\d+)/; 
$exter_addr = $inner_addr unless $exter_addr; 

#  创建一个基于 TCP的监听 socket，监听在内网地址的$agent_port 端口 
my $listen_socket = IO::Socket::INET->new(   
                                           LocalAddr => $inner_addr, 
                                           LocalPort => $agent_port, 
                                           Listen    => SOMAXCONN, 
                                           Proto     => 'tcp', 
                                           Reuse     => 1, 
                                           Timeout   => 30, 
                                         ); 
die "[EMERG] can't create socket: $@\n" unless defined $listen_socket; 
 
#  主循环 
while (!$DONE) 
{ 
	#  如果没有accept 到 server端发过来的请求，则 next 过去 
        next unless my $sock = $listen_socket->accept; 
     
	#  如果有请求，则 fork子进程处理这个请求。fork 之前先设置信号掩码，跟 server一样。 
	my $signals = POSIX::SigSet->new(SIGHUP,SIGINT,SIGTERM,SIGCHLD); 
	sigprocmask(SIG_BLOCK,$signals); 
 
	my $child = fork(); 
        die "[EMERG] can't fork $!\n" unless defined $child; 
 
	#  在父进程里取消信号掩码，并关闭连接 socket 
	if ($child) { 
		$status{$child} = 1; 
		sigprocmask(SIG_UNBLOCK,$signals); 
 
                $sock->close or die "[EMERG] can't close established socket\n"; 

	#  在子进程里先恢复默认信号处理器，再取消信号掩码 
	} else { 
                $SIG{HUP} = $SIG{INT} = $SIG{TERM} = $SIG{CHLD} = 'DEFAULT'; 
		sigprocmask(SIG_UNBLOCK,$signals); 
 
		#  子进程里关闭监听 socket 
                $listen_socket->close or die "[EMERG] can't close listen socket\n"; 
 
		#  循环读取 socket，获取 server发过来的扫描选项，并根据这些选项，调用相关函数进行系
		#  统扫描。 
		my @warnings; 
		while (<$sock>) { 
			chomp; 
			my ($key,$value) = split; 
 
			#  扫描端口 
			if ($key eq 'PORT') { 
				my $re = scan_ports($value); 
				my $warn = "$exter_addr: ports dropped: " . join ',',@$re; 
				push @warnings,$warn if @$re; 
      
			#  检查CPU负载 
			} elsif ($key eq 'CPU') { 
				my $warn = get_cpu_load($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  检查 free内存的大小 
			} elsif ($key eq 'FREEMEM') { 
				my $warn = get_free_mem($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  检查并发连接数 
			} elsif ($key eq 'CONCONN') { 
				my $warn = get_con_conn($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  检查网关 
                        } elsif ($key eq 'CHECKGW' && $value == 1) { 
				my $warn = check_gw(); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  检查可用磁盘空间 
			} elsif ($key eq 'FREEDISK') { 
				my $re = check_disk($value); 
				my $warn = "$exter_addr: disk warnings: " . join ';',@$re; 
				push @warnings,$warn if @$re; 
			#  检查已用交换内存 
			} elsif ($key eq 'SWAPUSED') { 
				my $warn = check_swap($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
 
			} 
		} 

		# client 将扫描的结果，通过 socket返回给 server，并关闭连接 socket。 
		print $sock $_,"\n"  for (@warnings); 
		$sock->close or die "[EMERG] can't close established socket\n"; 
	 
		exit 0; 
	} 
} 
 
#------------------- 
#  下面定义子函数 
#------------------- 
#  使程序进入后台的函数，与 server 同 
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

#  写日志的函数，与 server同 
sub write_log 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$log_file); 
	flock (HDW,LOCK_EX); 
	print HDW $time,"  ",join ' ',@_,"\n"; 
	flock (HDW,LOCK_UN); 
	close HDW; 
} 
 
#  重载die 的函数，与 server同 
sub log_die 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
	die @_; 
} 

#  重载 warn的函数，与 server同 
sub log_warn 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
} 
 
# killall 子进程，与 server 同 
sub kill_children 
{ 
        kill TERM => keys %status; 
	sleep while %status; 
} 

# reload 自身，与 server同 
sub relaunch 
{ 
	chdir $rundir; 
	unlink $pid_file; 
	exec 'perl','monagt'; 
} 
 
#  处理 SIGHUP 的函数，与 server同 
sub do_hup 
{ 
	warn "[INFO] received SIGHUP,prepare to reload...\n"; 
	kill_children(); 

	relaunch(); 
        die "[EMERG] reload failed\n"; 
} 

#  端口扫描的函数，如果指定端口 drop 了，则返回异常报警。 
#  调用了nc命令，请 man nc 
sub scan_ports 
{ 
	my @results; 
 
        for my $port (split/,/,shift) { 
		my $result = `$NC -nzv 127.0.0.1 $port 2>&1`; 
		if ($result =~ /Connection refused/) { 
			$result = `$NC -nzv $inner_addr $port 2>&1`; 
			if ($result =~ /Connection refused/) { 
				$result = `$NC -nzv $exter_addr $port 2>&1`; 
				if ($result =~ /Connection refused/) { 
					push @results,$port; 
				} 
			} 
		} 
	} 

	return \@results; 
} 
 
#  检查CPU负载的函数，如果负载大于指定阀值，则返回异常报警 
#  调用了uptime 命令，请 man uptime 
sub get_cpu_load 
{ 
	my $arg = shift; 
	my ($sign,$load) = $arg =~ /([+-])([\d\.]+)/; 

	my $warn; 
	unless (defined $sign && defined $load) { 
		$warn = "uncorrect argument in config file"; 
		return $warn; 
	} 

	my $result = `$UPTIME`; 
	my ($curr_load) = $result =~ /load average: (\d+\.\d+),/; 

	if ($sign eq '+' && $curr_load > $load) { 
		$warn = "CPU Load large than $load\%"; 

	} elsif ($sign eq '-' && $curr_load < $load) { 
		$warn = "CPU Load less than $load\%"; 

	} 

	return $warn; 
} 
 
#  检查 free内存大小的函数，如果 free 内存小于指定阀值，则返回异常报警 
#  调用了cat命令，请 man cat 
sub get_free_mem 
{ 
	my $arg = shift; 
	my ($sign,$mem_free) = $arg =~ /([+-])([\d\.]+)/; 

	my $warn; 
	unless (defined $sign && defined $mem_free) { 
		$warn = "uncorrect argument in config file"; 
		return $warn; 
	} 

	my @meminfo = `$CAT /proc/meminfo`; 

	my ($total,$free); 
	for (@meminfo) { 
		if (/^MemTotal/) { 
			$total = (split)[1]; 
		}elsif (/^MemFree/) { 
			$free = (split)[1]; 
		} 
	} 

	my $curr_free = ($free / $total) * 100; 

	if ($sign eq '+' && $curr_free > $mem_free) { 
		$warn = "Free Mem large than $mem_free\%"; 

	} elsif ($sign eq '-' && $curr_free < $mem_free) { 
		$warn = "Free Mem less than $mem_free\%"; 
	} 

	return $warn; 
} 
 
#  检查并发连接数的函数，如果并发连接数大于指定阀值，则返回异常报警 
#  调用了netstat 命令，请 man netstat 
sub get_con_conn 
{ 
	my $arg = shift; 
	my ($sign,$conn) = $arg =~ /([+-])(\d+)/; 

	my $warn; 
	unless (defined $sign && defined $conn) { 
		$warn = "uncorrect argument in config file"; 
		return $warn; 
	} 

	my @netstat = `$NETSTAT -ts`; 
	my ($estab) = grep {/connections established/} @netstat; 
	my ($estab_num) = $estab =~ /(\d+)/; 

	if ($sign eq '+' && $estab_num > $conn) { 
		$warn = "Established Connections large than $conn"; 

	} elsif ($sign eq '-' && $estab_num < $conn) { 
		$warn = "Established Connections less than $conn"; 

	} 

	return $warn; 
} 
 
#  检查交换内存使用的函数，如果交换内存使用大于指定阀值，则返回异常报警 
#  调用了 free 命令，请 man free 
sub check_swap 
{ 
	my $arg = shift; 
	my ($sign,$swap) = $arg =~ /([+-])(\d+)/; 

	my $warn; 
	unless (defined $sign && defined $swap) { 
		$warn = "uncorrect argument in config file"; 
		return $warn; 
	} 

	my @meminfo = `$FREE`; 
	my ($swap_line) = grep {/^Swap/} @meminfo; 
	my ($swap_used) = (split/\s+/,$swap_line)[2]; 

	if ($sign eq '+' && $swap_used > $swap) { 
		$warn = "Used SWAP large than $swap KB"; 

	} elsif ($sign eq '-' && $swap_used < $swap) { 
		$warn = "Used SWAP less than $swap KB"; 

	} 

	return $warn; 
} 
 
#  检查网关的函数，如果网关不通，则返回异常报警 
#  调用了ping 命令，请 man ping 
sub check_gw 
{ 
	my @routes = `$NETSTAT -nr`; 
	my ($gw_line) = grep {/\s+UG\s+/} @routes; 
	my $gw = (split/\s+/,$gw_line)[1]; 

	my $warn; 
	`$PING -c 1 $gw`; 
	if ($? != 0) { 
		$warn = "Network to GW $gw disconnected"; 
	} 

	return $warn; 
} 

#  检查磁盘空间的函数，如果可用磁盘空间小于指定阀值，则返回异常报警 
#  调用了df命令，请 man df 
sub check_disk 
{ 
	my $arg = shift; 
	my ($sign,$disk_free) = $arg =~ /([+-])([\d\.]+)/; 

	my @warns; 
	unless (defined $sign && defined $disk_free) { 
		push @warns,"uncorrect argument in config file"; 
		return \@warns; 
	} 

	my @df = `$DF -h`; 
	for (@df) { 
		chomp; 
		my ($used,$mount) = (split)[4,5]; 
		$used =~ s/\%//; 

		if ( $sign eq '+' && (100 - $used) > $disk_free ) { 
			push @warns, "Free Disk on $mount large than $disk_free\%"; 

		}elsif ( $sign eq '-' && (100 - $used) < $disk_free ) { 
			push @warns, "Free Disk on $mount less than $disk_free\%"; 

		} 
	} 

	return \@warns; 
} 
 

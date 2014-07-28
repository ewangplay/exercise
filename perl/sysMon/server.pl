#!/usr/bin/perl 
use strict; 
use IO::Socket; 
use POSIX qw(:signal_h WNOHANG setsid); 
use Net::SMTP; 
use Fcntl qw(:DEFAULT :flock); 
 
#  �����ʼ���ַ���������ܱ��� 
my @emails = ( 
		'sa@sample-inc.com', 
		'dba@sample-inc.com', 
		#  ����email��ַ 
	    ); 
#  �������е���Ŀ¼��������д���ģ���Ҫ�޸ĳ��Լ���Ŀ¼����д�������ļ� 
my $rundir = '/home/afoo/monsvr'; 
#  �������е� PID�ļ� 
my $pid_file = $rundir . "/monsvr.pid"; 
#  �����ļ���������ͻ��˵� IP��ɨ����� 
my $cfg_file = $rundir . "/monsvr.cf"; 
# 2 ����־�ļ���������־��������־ 
my $err_log = $rundir. "/monsvr.err"; 
my $log_file = $rundir. "/monsvr.log"; 
#  �ͻ��˵����ж˿� 
my $agent_port = 7780; 
#  ��ѭ���˳������������� 0 ���˳������� 0�˳� 
my $DONE = 0; 
#  ÿ10 ����ִ��һ��ɨ�� 
my $scan_inter = 10;   
#  ���һ��ɨ���ʱ�� 
my $last_scan_time = 0; 
#  ��¼�ӽ��� ID��״̬�� 
my %status; 
# MTA������ IP���˿ڣ��������ͱ����ʼ��� 
# Linux Ĭ�ϰ�װ�� sendmail���������ɡ� 
my $mtahost = '127.0.0.1'; 
my $mtaport = 25; 
 
#  ��װ�Լ����źŴ����� 
#  �ӽ����˳�ʱ����״̬����ɾ���ӽ��� ID 
$SIG{CHLD}=sub {while((my $child=waitpid(-1,WNOHANG))>0){delete $status{$child}}}; 
# SIGTERM�� SIGINT �źŵ��³����˳� 
$SIG{TERM}=$SIG{INT}=sub {$DONE++}; 
#  ���� HUP �źſ��ó��� reload ����kill �CHUP `cat monsvr.pid`�� 
$SIG{HUP}=\&do_hup; 
# die �� warn����ʱ��������ض�����־�ļ� 
$SIG{__DIE__}=\&log_die; 
$SIG{__WARN__}=\&log_warn; 

#  ��ȡ����״̬�����ȴ�PID�ļ����ȡ�������еĽ���ID ������еĻ��������kill 0 =>$pid
#  �����棬���ʾ�����������У�����ܾ���������� PID�ļ�����д������Ҳ�ܾ������� 
if (-e $pid_file) 
{ 
	open (PIDFILE,$pid_file) or die "[EMERG] $!\n"; 
	my $pid=<PIDFILE>; 
	close PIDFILE; 
 
        die "[EMERG] process is still run\n" if kill 0 => $pid; 
        die "[EMERG] can't remove pid file\n" unless -w $pid_file && unlink $pid_file; 
} 
 
#  ��������̨����������Ľ��� IDд�� PID �ļ��� 
open (HDW,">",$pid_file) or die "[EMERG] $!\n"; 
my $pid=daemon(); 
print HDW $pid; 
close HDW; 
 
#  ��ѭ�� 
while (!$DONE) 
{ 
	#  �������һ��ɨ���ʱ���Ъ����$scan_inter����ķ��ӣ�����û��ɨ���ӽ��̴��ڣ���
	#  ����һ��ɨ���ӽ��� 
        if ( (time - $last_scan_time > $scan_inter * 60) && ! %status ) { 
		#  ����ɨ��󣬽����һ��ɨ���ʱ�䣬����Ϊ��ǰʱ�� 
		$last_scan_time = time; 
	 
		#  �����ź����룬����ǰ�����صļ����źţ���ֹ�⼸���ź��� fork��ʱ����� 
		my $signals = POSIX::SigSet->new(SIGHUP,SIGINT,SIGTERM,SIGCHLD); 
		sigprocmask(SIG_BLOCK,$signals); 

		# fork �ӽ��� 
		my $child = fork(); 
		die "can't fork $!" unless defined $child; 
	 
		#  ��������ȡ���ź����� 
		if ($child) { 
			$status{$child} =1; 
			sigprocmask(SIG_UNBLOCK,$signals); 
	 
		#  �ӽ������Ƚ� HUP��INT��TERM��CHLD�źŻָ���Ĭ�ϣ�Ȼ��Ҳȡ���ź����롣 
		#  Ȼ���ӽ��̵��� do_scan()��������ɨ��ͱ�������������д��־���˳� 
		} else { 
			$SIG{HUP} = $SIG{INT} = $SIG{TERM} = $SIG{CHLD} = 'DEFAULT'; 
			sigprocmask(SIG_UNBLOCK,$signals); 

			my $results = do_scan(); 
			do_warn($results) if @$results; 
			write_log("[$$]",">>>All scan finished<<<"); 

			exit 0; 
		} 
	} 
 
	#  ���������� 10 �룬������ѭ�� 
	sleep 10; 
} 
 
#------------------- 
#  ���涨���Ӻ��� 
#------------------- 
 
#  ʹ��������̨�ĺ�����ԭ��ܼ򵥣����� fork һ���ӽ��̣������� die �����ӽ��̵���
#  setsid()ʹ�Լ���Ϊ��������쵼��Ȼ���ض��� 3 ����׼ I/O�豸��/dev/null�� 
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

#  д��־�ĺ��� 
sub write_log 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$log_file); 
	flock (HDW,LOCK_EX); 
	print HDW $time,"  ",join ' ',@_,"\n"; 
	flock (HDW,LOCK_UN); 
	close HDW; 
} 
 
#  ������dieʱ����ִ�����������Ҳ�����Ƚ��쳣��Ϣд�������־���������� die�� 
sub log_die 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
	die @_; 
} 
 
#  ������ warn ʱ����ִ����������� 
sub log_warn 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
} 
 
#  ɨ�躯�� 
sub do_scan 
{ 
	#  �ȶ�ȡ�����ļ�����ȡҪɨ��� IP���Լ�ɨ����Щѡ�� 
	my $scan_cfg = get_config(); 
	#  �������������¼ɨ���� 
	my @results; 

	#  �� forѭ������̨ɨ�� 
	for my $hid (keys %{$scan_cfg}) { 
		#  �� eval ��ִ��ɨ�裬�����ó�ʱ 30 �롣��� 30 ���ڿͻ���δ���ؽ�����ͻ������ڵ�
		#  �������غ���ʱ�����ܻ������������¼ɨ���쳣�Ľ���� 
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

#  ����ɨ��ĳ̨���ĺ��� 
sub scan_a_host 
{ 
	my $host = shift;    # a hash ref 
	my @results; 
 
	#  �������ͻ��˵� socket 
        my $sock=IO::Socket::INET->new(PeerAddr => $host->{IP}, 
                                       PeerPort => $agent_port, 
                                       Proto    => 'tcp'); 

	#  ������� socket ���ɹ�����˵���ͻ��˵ļ����˿ڿ��� down �� 
        unless (defined $sock) { 
		push @results, "$host->{IP}: monitor client seems down"; 
		warn("[WARN] $host->{IP}: monitor client seems down\n"); 
		return \@results; 
        }  
     
        write_log("[$$]", "prepare to do_scan for $host->{IP}"); 

	#  �������ļ��ﶨ���ɨ��ѡ����͵� client 
        for my $key (keys %{$host}) { 
		print $sock "$key  $host->{$key}\n" 
        } 

	#  �������ر�д socket���ⲽ����Ҫ������ client ��֪�� server ��д�꣬�������������
	#  ��������ɺ� server�Ľ��������� 
        $sock->shutdown(1); 
 
	#  �� while ѭ�����ȡ�ͻ��˷��ص�ɨ���� 
        while(<$sock>) { 
		chomp; 
		push @results,$_; 
        } 
 
	#  �ر� socket �����ؽ���������� 
        $sock->close; 
        return \@results; 
} 

#  �ú���������ȡ�����ļ��������������һ�� Hash�����ı�����û������ļ��ɡ���
#  ���������ļ��ĸ�ʽ�Ķ��ú����� 
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

#  �澯��������ɨ�����쳣����һ����д����־����һ���淢�͵����ʼ����� 
sub do_warn 
{ 
	my $warns = shift; 

	for (@$warns) { 
		write_log($_); 
	} 
	sendmail($warns); 
} 
 
#  ���͵����ʼ��ĺ��� 
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

#  ���� SIGTERM �źţ�killall �ӽ��̣��� sleep ֱ�������ӽ��̶��˳� 
sub kill_children 
{ 
	kill TERM => keys %status; 
	sleep while %status; 
} 
 
#  ������ SIGHUP �ź�ʱ��ִ�б����� reload���� 
sub relaunch 
{ 
	chdir $rundir; 
	unlink $pid_file; 
	exec 'perl','monsvr'; 
} 

#  ���� SIGHUP �ź� 
sub do_hup 
{ 
	warn "[INFO] received SIGHUP,prepare to reload...\n"; 
	kill_children(); 
 
	relaunch(); 
        die "[EMERG] reload failed\n"; 
} 

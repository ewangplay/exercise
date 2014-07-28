#!/usr/bin/perl 
use strict; 
use IO::Socket; 
use POSIX qw(:signal_h WNOHANG setsid); 
use Fcntl qw(:DEFAULT :flock); 
 
#  ������ɨ��ϵͳ���ⲿ�����ǰ��������Ҳ���Ըĳ�ϵͳ�ڲ����� 
#  �����е����ⲿ�����·�� 
my $NC = '/usr/bin/nc'; 
my $CAT = '/bin/cat'; 
my $PING = '/bin/ping'; 
my $NETSTAT = '/bin/netstat'; 
my $UPTIME = '/usr/bin/uptime'; 
my $IFCONFIG = '/sbin/ifconfig'; 
my $DF = '/bin/df'; 
my $FREE = '/usr/bin/free'; 
 
#  ��������Ŀ¼ 
my $rundir = '/home/afoo/monagt'; 
# PID�ļ��������ļ� 
my $pid_file = $rundir . "/monagt.pid"; 
my $err_log = $rundir. "/monagt.err"; 
my $log_file = $rundir. "/monagt.log"; 
#  �����˿� 
my $agent_port = 7780; 
#  ��ѭ���˳����������� serverһ�� 
my $DONE = 0; 
#  ��¼�ӽ��̵�״̬�� 
my %status; 
 
#  �����źŴ��������� serverһ�� 
$SIG{CHLD}=sub {while((my $child=waitpid(-1,WNOHANG))>0){delete $status{$child}}}; 
$SIG{TERM}=$SIG{INT}=sub {$DONE++}; 
$SIG{HUP}=\&do_hup; 
$SIG{__DIE__}=\&log_die; 
$SIG{__WARN__}=\&log_warn; 

#  ����ǰ�Ȼ�ȡ����״̬���� server һ��
if (-e $pid_file) 
{ 
        open (PIDFILE,$pid_file) or die "[EMERG] $!\n"; 
	my $pid=<PIDFILE>; 
	close PIDFILE; 
 
        die "[EMERG] process is still run\n" if kill 0 => $pid; 
        die "[EMERG] can't remove pid file\n" unless -w $pid_file && unlink $pid_file; 
} 
 
#  ��������̨ 
open (HDW,">",$pid_file) or die "[EMERG] $!\n"; 
my $pid=daemon(); 
print HDW $pid; 
close HDW; 
 
#  ��ȡ������ IP����ǰ��������ؿͻ���Ϊ�˰�ȫ��������������� IP �ϡ������������
#  IP���� 192.168.xx.xx��������ǣ����޸ĳ��Լ��� IP��ʽ�� 
#  $inner_addr������ IP��$exter_addr������ IP�����û������ IP����ʹ������ IP�� 
my @ifconfig = `$IFCONFIG`; 
my ($inner_line) = grep {/inet addr\:192\.168\./} @ifconfig; 
my ($exter_line) = grep {/inet addr\:/ && ! /192\.168\./ && ! /127\.0\.0\./} @ifconfig; 
my ($inner_addr) = $inner_line =~ /inet addr\:(\d+\.\d+\.\d+\.\d+)/; 
my ($exter_addr) = $exter_line =~ /inet addr\:(\d+\.\d+\.\d+\.\d+)/; 
$exter_addr = $inner_addr unless $exter_addr; 

#  ����һ������ TCP�ļ��� socket��������������ַ��$agent_port �˿� 
my $listen_socket = IO::Socket::INET->new(   
                                           LocalAddr => $inner_addr, 
                                           LocalPort => $agent_port, 
                                           Listen    => SOMAXCONN, 
                                           Proto     => 'tcp', 
                                           Reuse     => 1, 
                                           Timeout   => 30, 
                                         ); 
die "[EMERG] can't create socket: $@\n" unless defined $listen_socket; 
 
#  ��ѭ�� 
while (!$DONE) 
{ 
	#  ���û��accept �� server�˷������������� next ��ȥ 
        next unless my $sock = $listen_socket->accept; 
     
	#  ����������� fork�ӽ��̴����������fork ֮ǰ�������ź����룬�� serverһ���� 
	my $signals = POSIX::SigSet->new(SIGHUP,SIGINT,SIGTERM,SIGCHLD); 
	sigprocmask(SIG_BLOCK,$signals); 
 
	my $child = fork(); 
        die "[EMERG] can't fork $!\n" unless defined $child; 
 
	#  �ڸ�������ȡ���ź����룬���ر����� socket 
	if ($child) { 
		$status{$child} = 1; 
		sigprocmask(SIG_UNBLOCK,$signals); 
 
                $sock->close or die "[EMERG] can't close established socket\n"; 

	#  ���ӽ������Ȼָ�Ĭ���źŴ���������ȡ���ź����� 
	} else { 
                $SIG{HUP} = $SIG{INT} = $SIG{TERM} = $SIG{CHLD} = 'DEFAULT'; 
		sigprocmask(SIG_UNBLOCK,$signals); 
 
		#  �ӽ�����رռ��� socket 
                $listen_socket->close or die "[EMERG] can't close listen socket\n"; 
 
		#  ѭ����ȡ socket����ȡ server��������ɨ��ѡ���������Щѡ�������غ�������ϵ
		#  ͳɨ�衣 
		my @warnings; 
		while (<$sock>) { 
			chomp; 
			my ($key,$value) = split; 
 
			#  ɨ��˿� 
			if ($key eq 'PORT') { 
				my $re = scan_ports($value); 
				my $warn = "$exter_addr: ports dropped: " . join ',',@$re; 
				push @warnings,$warn if @$re; 
      
			#  ���CPU���� 
			} elsif ($key eq 'CPU') { 
				my $warn = get_cpu_load($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  ��� free�ڴ�Ĵ�С 
			} elsif ($key eq 'FREEMEM') { 
				my $warn = get_free_mem($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  ��鲢�������� 
			} elsif ($key eq 'CONCONN') { 
				my $warn = get_con_conn($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  ������� 
                        } elsif ($key eq 'CHECKGW' && $value == 1) { 
				my $warn = check_gw(); 
				push @warnings,"$exter_addr: $warn" if $warn; 
			#  �����ô��̿ռ� 
			} elsif ($key eq 'FREEDISK') { 
				my $re = check_disk($value); 
				my $warn = "$exter_addr: disk warnings: " . join ';',@$re; 
				push @warnings,$warn if @$re; 
			#  ������ý����ڴ� 
			} elsif ($key eq 'SWAPUSED') { 
				my $warn = check_swap($value); 
				push @warnings,"$exter_addr: $warn" if $warn; 
 
			} 
		} 

		# client ��ɨ��Ľ����ͨ�� socket���ظ� server�����ر����� socket�� 
		print $sock $_,"\n"  for (@warnings); 
		$sock->close or die "[EMERG] can't close established socket\n"; 
	 
		exit 0; 
	} 
} 
 
#------------------- 
#  ���涨���Ӻ��� 
#------------------- 
#  ʹ��������̨�ĺ������� server ͬ 
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

#  д��־�ĺ������� serverͬ 
sub write_log 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$log_file); 
	flock (HDW,LOCK_EX); 
	print HDW $time,"  ",join ' ',@_,"\n"; 
	flock (HDW,LOCK_UN); 
	close HDW; 
} 
 
#  ����die �ĺ������� serverͬ 
sub log_die 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
	die @_; 
} 

#  ���� warn�ĺ������� serverͬ 
sub log_warn 
{ 
	my $time=scalar localtime; 
	open (HDW,">>",$err_log); 
	print HDW $time,"  ",@_; 
	close HDW; 
} 
 
# killall �ӽ��̣��� server ͬ 
sub kill_children 
{ 
        kill TERM => keys %status; 
	sleep while %status; 
} 

# reload ������ serverͬ 
sub relaunch 
{ 
	chdir $rundir; 
	unlink $pid_file; 
	exec 'perl','monagt'; 
} 
 
#  ���� SIGHUP �ĺ������� serverͬ 
sub do_hup 
{ 
	warn "[INFO] received SIGHUP,prepare to reload...\n"; 
	kill_children(); 

	relaunch(); 
        die "[EMERG] reload failed\n"; 
} 

#  �˿�ɨ��ĺ��������ָ���˿� drop �ˣ��򷵻��쳣������ 
#  ������nc����� man nc 
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
 
#  ���CPU���صĺ�����������ش���ָ����ֵ���򷵻��쳣���� 
#  ������uptime ����� man uptime 
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
 
#  ��� free�ڴ��С�ĺ�������� free �ڴ�С��ָ����ֵ���򷵻��쳣���� 
#  ������cat����� man cat 
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
 
#  ��鲢���������ĺ����������������������ָ����ֵ���򷵻��쳣���� 
#  ������netstat ����� man netstat 
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
 
#  ��齻���ڴ�ʹ�õĺ�������������ڴ�ʹ�ô���ָ����ֵ���򷵻��쳣���� 
#  ������ free ����� man free 
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
 
#  ������صĺ�����������ز�ͨ���򷵻��쳣���� 
#  ������ping ����� man ping 
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

#  �����̿ռ�ĺ�����������ô��̿ռ�С��ָ����ֵ���򷵻��쳣���� 
#  ������df����� man df 
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
 

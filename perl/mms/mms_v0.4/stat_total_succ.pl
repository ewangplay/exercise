############################################################################
#Desc: stat total success rate
#Usage:stat_total_succ.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/13
#Modify by wang xiaohui 2009/06/19 for adding log output
############################################################################
use Log::Log4perl;
use DBIx::Log4perl;
use Time::Local;
use POSIX qw(strftime);
use strict;


my $DBN = "DBI:Oracle:gpnms4";	#data source
my $USR = "nmsadm";		#login user
my $PASSWD = "nms_8899";	#login password
my $PROVNETWORK = 10000; 	#province network type
my $AREANETWORK = 10001; 	#province network type
my $PROVID = 1751711880; 	#province id
my $LOG_CONFIG = "../log/mylog.conf";	#log output config


my @driver_names;
my $dbh;
my $stat_row_hash;


main($ARGV[0], $ARGV[1]);

sub main
{
	my ($startdate, $enddate) = @_;

	# Initialize the logger object with config file
	Log::Log4perl->init($LOG_CONFIG);

	# Get logger object handler
	my $logger = Log::Log4perl->get_logger('main');

	$logger->info("Connecting to database $DBN with user $USR ...");

	# Connect to database
	@driver_names = DBIx::Log4perl->available_drivers;
	$dbh = DBIx::Log4perl->connect($DBN, $USR, $PASSWD, {PrintError => 0, RaiseError => 0, AutoCommit => 0}) 
		or die "Couldn't connect to database: " . DBIx::Log4perl->errstr . "\n"; 

	$logger->info("Connect database $DBN success!");

	# Enale auto-error checking on the database handle
	$dbh->{RaiseError} = 1;

	if ($startdate eq "" and $enddate eq "")
	{
		#my $startdate = strftime "%Y-%m-%d",localtime(time() - 86400) ;
		my $startdate = "2008-10-23";
		daily_dispose($startdate);
	}
	elsif($startdate eq "" and $enddate ne "")
	{
		die "endtim not be null";
	}
	elsif($startdate ne "" and $enddate eq "") 
	{
		die "starttime not be null";
	}
	else
	{
		my @date_array;
		$startdate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "starttime erroe ex:2009-01-01";
		$enddate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "endtim erroe ex:2009-01-01";
		@date_array = getdatearry($startdate,$enddate);
		foreach (@date_array)
		{
			daily_dispose($_);
		}
	}

	$logger->info("Disconnecting from database $DBN...");

	$dbh->disconnect();
	
	$logger->info("Disconnect database success!");

	exit(0);
}

sub getdatearry
{
	my @datearry;
	my $startdate = shift;
	my $enddate = shift;
	my @startstr = split(/-/,$startdate);
	my @endstr = split(/-/,$enddate);
	my $stims = timelocal("59","59","23",$startstr[2],($startstr[1]-1),$startstr[0]);
	my $etims = timelocal("59","59","23",$endstr[2],($endstr[1]-1),$endstr[0]);

	if($stims > $etims) 
	{
		@datearry=()
	}
	else
	{
		my $day = ($etims - $stims) / 86399;
		for(my $i=0;$i<$day;$i++)
		{
			$datearry[$i] = strftime "%Y-%m-%d", localtime($stims + 86399*$i);	
		}
	}

	return @datearry;
}

sub daily_dispose
{
	my $sql;
	my $startdate = shift;
	my $logger = Log::Log4perl->get_logger('main');

	$logger->info("Deleting outdated data at $startdate from database...");
					
	# delete the old data in this date section
	$sql = "delete from TSMD_TOTAL_SUCC" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	$logger->info("Delete outdated data success!");
	 
	$logger->info("Inserting new data at $startdate into database...");

	# stat area send num
	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (cdrtype in ('0','1','2'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
	stat_num($sql, 'mms_send_num');

	# stat area album num
	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " and statuscode in ('3400','3401','3402')" 
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
	stat_num($sql, 'mms_album_num');

	# stat area network submit fail num
	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " and statuscode=6000" 
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
	stat_num($sql, 'mms_network_submit_fail_num');

	# stat area user submit fail num
	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " and statuscode in ('6001','6003','6100','6101','6103')" 
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
	stat_num($sql, 'mms_user_submit_fail_num');

	# stat area network delv fail num
	$sql =  "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " and statuscode in ('4300','5303','6151','6300','6680')" 
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
	stat_num($sql, 'mms_network_delv_fail_num');

	# stat area user delv fail num
	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " and statuscode in ('4100','4200','4300','4400','4401','4402','4403'," 
		. " '4404','4406','4408','4441','4442','4443','4444','4448','6303','6311'," 
		. " '6601','6602','6607','6615','6616')" 
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
	stat_num($sql, 'mms_user_delv_fail_num');

	# stat total network success rate
	stat_ratio('mms_total_network_succ_ratio');

	# stat total user success rate
	stat_ratio('mms_total_user_succ_ratio');

	# insert area stat data 
	my ($pro_mms_send_num, $pro_mms_album_num) = (0, 0);
	my ($pro_mms_network_submit_fail_num, $pro_mms_user_submit_fail_num) = (0, 0);
	my ($pro_mms_network_delv_fail_num, $pro_mms_user_delv_fail_num) = (0, 0);
	my ($pro_mms_total_network_succ_ratio, $pro_mms_total_user_succ_ratio) = (0, 0);
	foreach my $key (keys %$stat_row_hash)
	{
		my ($mms_send_num, $mms_album_num);
		my ($mms_network_submit_fail_num, $mms_user_submit_fail_num);
		my ($mms_network_delv_fail_num, $mms_user_delv_fail_num);
		my ($mms_total_network_succ_ratio, $mms_total_user_succ_ratio);

		$mms_send_num = $stat_row_hash->{$key}->{'mms_send_num'} 
						? $stat_row_hash->{$key}->{'mms_send_num'} : 0;
		$mms_album_num = $stat_row_hash->{$key}->{'mms_album_num'} 
						? $stat_row_hash->{$key}->{'mms_album_num'} : 0;
		$mms_network_submit_fail_num = $stat_row_hash->{$key}->{'mms_network_submit_fail_num'} 
						? $stat_row_hash->{$key}->{'mms_network_submit_fail_num'} : 0;
		$mms_user_submit_fail_num = $stat_row_hash->{$key}->{'mms_user_submit_fail_num'} 
						? $stat_row_hash->{$key}->{'mms_user_submit_fail_num'} : 0;
		$mms_network_delv_fail_num = $stat_row_hash->{$key}->{'mms_network_delv_fail_num'} 
						? $stat_row_hash->{$key}->{'mms_network_delv_fail_num'} : 0;
		$mms_user_delv_fail_num = $stat_row_hash->{$key}->{'mms_user_delv_fail_num'} 
						? $stat_row_hash->{$key}->{'mms_user_delv_fail_num'} : 0;
		$mms_total_network_succ_ratio = $stat_row_hash->{$key}->{'mms_total_network_succ_ratio'} 
						? $stat_row_hash->{$key}->{'mms_total_network_succ_ratio'} : 0;
		$mms_total_user_succ_ratio = $stat_row_hash->{$key}->{'mms_total_user_succ_ratio'} 
						? $stat_row_hash->{$key}->{'mms_total_user_succ_ratio'} : 0;
		$pro_mms_send_num += $mms_send_num;
		$pro_mms_album_num += $mms_album_num;
		$pro_mms_network_submit_fail_num += $mms_network_submit_fail_num;
		$pro_mms_user_submit_fail_num += $mms_user_submit_fail_num;
		$pro_mms_network_delv_fail_num += $mms_network_delv_fail_num;
		$pro_mms_user_delv_fail_num += $mms_user_delv_fail_num;

		$sql = "insert into tsmd_total_succ(start_time, area_code, mms_send_num, mms_album_num," 
			. " mms_network_submit_fail_num, mms_user_submit_fail_num, mms_network_delv_fail_num," 
			. " mms_user_delv_fail_num, mms_total_network_succ_ratio, mms_total_user_succ_ratio, ne_typ)" 
			. " values (to_date('$startdate','yyyy-mm-dd'), $key, $mms_send_num, $mms_album_num," 
			. " $mms_network_submit_fail_num, $mms_user_submit_fail_num, $mms_network_delv_fail_num," 
			. " $mms_user_delv_fail_num, $mms_total_network_succ_ratio, $mms_total_user_succ_ratio, $AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit();

	# insert province stat data
	if ($pro_mms_send_num == 0)
	{
		$pro_mms_total_network_succ_ratio = 0;
		$pro_mms_total_user_succ_ratio = 0;
	}
	else
	{
		$pro_mms_total_network_succ_ratio = 
			(($pro_mms_send_num - $pro_mms_network_submit_fail_num - $pro_mms_network_delv_fail_num)/$pro_mms_send_num) * 1.0000;
		$pro_mms_total_user_succ_ratio = 
			(($pro_mms_send_num - $pro_mms_album_num - $pro_mms_network_submit_fail_num - $pro_mms_user_submit_fail_num - $pro_mms_network_delv_fail_num - $pro_mms_user_delv_fail_num) / $pro_mms_send_num) * 1.0000;
	}
	$sql = "insert into tsmd_total_succ(start_time, area_code, mms_send_num, mms_album_num," 
		. " mms_network_submit_fail_num, mms_user_submit_fail_num, mms_network_delv_fail_num," 
		. " mms_user_delv_fail_num, mms_total_network_succ_ratio, mms_total_user_succ_ratio, ne_typ)" 
		. " values (to_date('$startdate','yyyy-mm-dd'), $PROVID, $pro_mms_send_num, $pro_mms_album_num," 
		. " $pro_mms_network_submit_fail_num, $pro_mms_user_submit_fail_num, $pro_mms_network_delv_fail_num," 
		. " $pro_mms_user_delv_fail_num, $pro_mms_total_network_succ_ratio, $pro_mms_total_user_succ_ratio, $PROVNETWORK)";
	$dbh->do($sql);
	$dbh->commit();

	$logger->info("Insert new data success!");
}

sub stat_num
{
	my @row;
	my $sth;
	my ($sql,$col) = @_;

	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{$col} = $row[1];		
	}
	$sth->finish;
}

sub stat_ratio
{
	my ($mms_send_num,$mms_album_num);
	my ($mms_network_submit_fail_num, $mms_user_submit_fail_num);
	my ($mms_network_delv_fail_num, $mms_user_delv_fail_num);
	my $ratio= shift;

	if ($ratio eq 'mms_total_network_succ_ratio')
	{
		foreach my $key (keys %$stat_row_hash)
		{
			$mms_send_num = $stat_row_hash->{$key}->{'mms_send_num'};
			$mms_network_submit_fail_num = $stat_row_hash->{$key}->{'mms_network_submit_fail_num'};
			$mms_network_delv_fail_num = $stat_row_hash->{$key}->{'mms_network_delv_fail_num'};
			
			if($mms_send_num == 0 )
			{
				$stat_row_hash->{$key}->{$ratio} = 0;					
			}
			else
			{
				$stat_row_hash->{$key}->{$ratio} = (($mms_send_num - $mms_network_submit_fail_num - $mms_network_delv_fail_num) / $mms_send_num) * 1.0000;
			}
		}
	}
	elsif ($ratio eq 'mms_total_user_succ_ratio')
	{
		foreach my $key (keys %$stat_row_hash)
		{
			$mms_send_num = $stat_row_hash->{$key}->{'mms_send_num'};
			$mms_album_num = $stat_row_hash->{$key}->{'mms_album_num'};
			$mms_network_submit_fail_num = $stat_row_hash->{$key}->{'mms_network_submit_fail_num'};
			$mms_user_submit_fail_num = $stat_row_hash->{$key}->{'mms_user_submit_fail_num'};
			$mms_network_delv_fail_num = $stat_row_hash->{$key}->{'mms_network_delv_fail_num'};
			$mms_user_delv_fail_num = $stat_row_hash->{$key}->{'mms_user_delv_fail_num'};

			if ($mms_send_num == 0)
			{
				$stat_row_hash->{$key}->{$ratio} = 0;
			}
			else
			{
				$stat_row_hash->{$key}->{$ratio} = 
					(($mms_send_num - $mms_album_num - $mms_network_submit_fail_num - $mms_user_submit_fail_num - $mms_network_delv_fail_num - $mms_user_delv_fail_num) / $mms_send_num) * 1.0000;
			}
		}
	}
}

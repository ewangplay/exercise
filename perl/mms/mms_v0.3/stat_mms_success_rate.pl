############################################################################
#Desc: stat mms success rate
#Usage:stat_mms_success_rate.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/16
#Modify by wang xiaohui 2009/5/31 for optimizing framework
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
my $LOG_CONFIG = "mylog.conf";	#log output config


my @driver_names;
my $dbh;
my $stat_row_hash;


main($ARGV[0], $ARGV[1]);

sub main
{
	my ($startdate, $enddatee) = @_;

	# Initialize the logger object with config file
	Log::Log4perl->init($LOG_CONFIG);

	# Connect to database
	@driver_names = DBIx::Log4perl->available_drivers;
	$dbh = DBIx::Log4perl->connect($DBN, $USR, $PASSWD, {PrintError => 0, RaiseError => 0, AutoCommit => 0}) 
		or die "Couldn't connect to database: " . DBIx::Log4perl->errstr . "\n"; 

	# Enale auto-error checking on the database handle
	$dbh->{RaiseError} = 1;

	if ($startdate eq "" and $enddatee eq "")
	{
		#my $startdate = strftime "%Y-%m-%d",localtime(time() - 86400) ;
		my $startdate = "2008-10-23";
		daily_dispose($startdate);
	}
	elsif($startdate eq "" and $enddatee ne "")
	{
		die "enddate not be null";
	}
	elsif($startdate ne "" and $enddatee eq "") 
	{
		die "startdate not be null";
	}
	else
	{
		my @date_array;
		$startdate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "startdate erroe ex:2009-01-01";
		$enddatee =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "enddate erroe ex:2009-01-01";
		@date_array = getdatearry($startdate,$enddatee);
		foreach (@date_array)
		{
			daily_dispose($_);
		}
	}

	$dbh->disconnect();
	exit(0);
}

sub getdatearry
{
	my @datearry;
	my $startdate = shift;
	my $enddatee = shift;
	my @startstr = split(/-/,$startdate);
	my @endstr = split(/-/,$enddatee);
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

	# delete the old data in this date section
	$sql = "delete from TSMD_TOTAL_SUCC" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;
 
	stat_send_num($startdate);
	stat_album_num($startdate);
	stat_network_submit_fail_num($startdate);
	stat_user_submit_fail_num($startdate);
	stat_network_delv_fail_num($startdate); 
	stat_user_delv_fail_num($startdate);
	stat_all_success_rate();
	stat_user_success_rate(); 
	
	my ($provsendnum,$provnwsbfail,$provnwdelvfail,$provusrsbfail)=(0,0,0,0);
	my ($provusrdelvfail,$provalbum,$provallscssrate,$provusrscssrate)=(0,0,0,0);
	
	# stat and insert area data
	foreach my $areakey (keys %$stat_row_hash)
	{
		my ($sendnum,$nwsbfail,$nwdelvfail,$usrsbfail,$usrdelvfail,$album,$allscssrate,$usrscssrate);
		$sendnum = $stat_row_hash->{$areakey}->{'sendnum'} ? $stat_row_hash->{$areakey}->{'sendnum'} : 0;
		$nwsbfail = $stat_row_hash->{$areakey}->{'nwsbfail'} ? $stat_row_hash->{$areakey}->{'nwsbfail'} : 0;
		$nwdelvfail = $stat_row_hash->{$areakey}->{'nwdelvfail'} ? $stat_row_hash->{$areakey}->{'nwdelvfail'} : 0;
		$usrsbfail = $stat_row_hash->{$areakey}->{'usrsbfail'} ? $stat_row_hash->{$areakey}->{'usrsbfail'} : 0;
		$usrdelvfail = $stat_row_hash->{$areakey}->{'usrdelvfail'} ? $stat_row_hash->{$areakey}->{'usrdelvfail'} : 0;
		$album= $stat_row_hash->{$areakey}->{'album'} ? $stat_row_hash->{$areakey}->{'album'} : 0;
		$allscssrate = $stat_row_hash->{$areakey}->{'allscssrate'} ? $stat_row_hash->{$areakey}->{'allscssrate'} : 0;
		$usrscssrate = $stat_row_hash->{$areakey}->{'usrscssrate'} ? $stat_row_hash->{$areakey}->{'usrscssrate'} : 0;
		$provsendnum += $sendnum,
		$provnwsbfail += $nwsbfail,
		$provnwdelvfail += $nwdelvfail,
		$provusrsbfail += $usrsbfail,
		$provusrdelvfail += $usrdelvfail,
		$provalbum += $album ;
		my $sql = "insert into TSMD_TOTAL_SUCC(START_TIME,AREA_CODE,MMS_SEND_NUM,MMS_ALBUM_NUM,MMS_NETWORK_SUBMIT_FAIL_NUM,"
				. "MMS_USER_SUBMIT_FAIL_NUM,MMS_NETWORK_DELV_FAIL_NUM,MMS_USER_DELV_FAIL_NUM,MMS_TOTAL_NETWORK_SUCC_RATIO,"
				. "MMS_TOTAL_USER_SUCC_RATIO,NE_TYP) values(to_date('$startdate','yyyy-mm-dd'),$areakey,$sendnum,$album,$nwsbfail,"
				. "$usrsbfail,$nwdelvfail,$usrdelvfail,$allscssrate,$usrscssrate,$AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	# insert province stat data
	if($provsendnum <= 0)
	{
		$provallscssrate=0;
	}
	else
	{
		$provallscssrate = (( $provsendnum - $provnwsbfail - $provnwdelvfail ) / $provsendnum) * 1.00;
	}
	if($provsendnum <= 0)
	{
		$provusrscssrate=0;
	}
	else
	{
		$provusrscssrate = (( $provsendnum - $provnwsbfail - $provnwdelvfail - $provusrsbfail - $provusrdelvfail - $provalbum ) / $provsendnum) * 1.00;
	}
	
	$sql = "insert into TSMD_TOTAL_SUCC(START_TIME,AREA_CODE,MMS_SEND_NUM,MMS_ALBUM_NUM,MMS_NETWORK_SUBMIT_FAIL_NUM,"
			. "MMS_USER_SUBMIT_FAIL_NUM,MMS_NETWORK_DELV_FAIL_NUM,MMS_USER_DELV_FAIL_NUM,MMS_TOTAL_NETWORK_SUCC_RATIO,"
			. "MMS_TOTAL_USER_SUCC_RATIO,NE_TYP) values(to_date('$startdate','yyyy-mm-dd'),$PROVID,$provsendnum,$provalbum,$provnwsbfail,"
			. "$provusrsbfail,$provnwdelvfail,$provusrdelvfail,$provallscssrate,$provusrscssrate,$PROVNETWORK)";
	$dbh->do($sql);
	$dbh->commit;
}

sub stat_send_num
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (cdrtype in ('0','1','2'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{'sendnum'} = $row[1];		
	}
	$sth->finish;
}

sub stat_album_num
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (statuscode in ('3401','3402'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{'album'} = $row[1];		
	}
	$sth->finish;
}

sub stat_network_submit_fail_num
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and statuscode=6000"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{'nwsbfail'} = $row[1];		
	}
	$sth->finish;
}

sub stat_user_submit_fail_num
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (statuscode in ('6001','6003','6100','6101','6103'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{'usrsbfail'} = $row[1];		
	}
	$sth->finish;
}

sub stat_network_delv_fail_num
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (statuscode in ('4300','5303','6151','6300','6680'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{'nwdelvfail'} = $row[1];		
	}
	$sth->finish;
}

sub stat_user_delv_fail_num
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "select area_code,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (statuscode in ('4100','4200','4300','4400','4401','4402','4403','4404','4406','4408','4441','4442','4443','4444','4448','6303','6311','6601','6602','6607','6615','6616'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$row[0]}->{'usrdelvfail'} = $row[1];		
	}
	$sth->finish;
}

sub stat_all_success_rate
{
	my ($sendnum,$nwsbfail,$nwdelvfail);
	foreach my $areakey (keys %$stat_row_hash)
	{
		$sendnum = $stat_row_hash->{$areakey}->{'sendnum'};
		$nwsbfail = $stat_row_hash->{$areakey}->{'nwsbfail'};
		$nwdelvfail = $stat_row_hash->{$areakey}->{'nwdelvfail'};
		
		if($sendnum == 0 )
		{
			$stat_row_hash->{$areakey}->{'allscssrate'} = 0;					
		}
		else
		{
			$stat_row_hash->{$areakey}->{'allscssrate'} = (( $sendnum - $nwsbfail  - $nwdelvfail ) / $sendnum) * 1.00;
		}
	}
}

sub stat_user_success_rate
{
	my ($sendnum,$nwsbfail,$nwdelvfail,$usrsbfail,$usrdelvfail,$album);
	
	foreach my $areakey (keys %$stat_row_hash)
	{
		$sendnum = $stat_row_hash->{$areakey}->{'sendnum'};
		$nwsbfail = $stat_row_hash->{$areakey}->{'nwsbfail'};
		$nwdelvfail = $stat_row_hash->{$areakey}->{'nwdelvfail'};
		$usrsbfail = $stat_row_hash->{$areakey}->{'usrsbfail'};
		$usrdelvfail = $stat_row_hash->{$areakey}->{'usrdelvfail'};
		$album = $stat_row_hash->{$areakey}->{'album'};
		if($sendnum == 0 )
		{
			$stat_row_hash->{$areakey}->{'usrscssrate'} = 0;					
		}
		else
		{
			$stat_row_hash->{$areakey}->{'usrscssrate'} = (( $sendnum - $nwsbfail  - $nwdelvfail - $usrsbfail - $usrdelvfail - $album ) / $sendnum) * 1.00;
		}
	}	
}

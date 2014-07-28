############################################################################
#Desc: stat roaming total success rate.
#Usage:stat_roaming_overall.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/21
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
	my ($startdate, $enddate) = @_;

	# Initialize the logger object with config file
	Log::Log4perl->init($LOG_CONFIG);

	# Connect to database
	@driver_names = DBIx::Log4perl->available_drivers;
	$dbh = DBIx::Log4perl->connect($DBN, $USR, $PASSWD, {PrintError => 0, RaiseError => 0, AutoCommit => 0}) 
		or die "Couldn't connect to database: " . DBIx::Log4perl->errstr . "\n"; 

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
		die "startdate not be null";
	}
	else
	{
		my @date_array;
		$startdate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "startdate erroe ex:2009-01-01";
		$enddate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "endtim erroe ex:2009-01-01";
		@date_array = getdatearry($startdate,$enddate);
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
	my ($succ_num_local, $total_local, $ratio_local);
	my ($succ_num_provincial, $total_provincial, $ratio_provincial);
	my ($succ_num_national, $total_national, $ratio_national);
	my $startdate = shift;
						
	# delete the old data in this date section
	$sql = "delete from TSMD_ROAMING_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	#stat local success num
	$sql = "select count(*) from TSMC_MMSC where provno is null" 
		. " and statuscode in ('0000','0100','0300','0400','1000','1100','1100','4446')" 
		. " and (ReceiveTime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$succ_num_local = stat_num($sql);

	#stat local total num
	$sql = "select count(*) from TSMC_MMSC where provno is null" 
		. " and (ReceiveTime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$total_local = stat_num($sql);

	#calculate local success rate
	if($total_local == 0)
	{
		$ratio_local = 0;
	}
	else
	{
		$ratio_local = ($succ_num_local / $total_local) * 1.0000;
	}

	#stat roaming-in-province success num
	$sql = "select count(*) from TSMC_MMSC where provno=351" 
		. " and statuscode in ('0000','0100','0300','0400','1000','1100','1100','4446')" 
		. " and (ReceiveTime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$succ_num_provincial = stat_num($sql);

	#stat roaming-in-province total num
	$sql = "select count(*) from TSMC_MMSC where provno=351" 
		. " and (ReceiveTime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$total_provincial = stat_num($sql);

	#calculate roaming-in-province success rate
	if($total_provincial == 0)
	{
		$ratio_provincial = 0;
	}
	else
	{
		$ratio_provincial = ($succ_num_provincial / $total_provincial) * 1.0000;
	}

	#stat roaming-out-province success num
	$sql = "select count(*) from TSMC_MMSC where provno is not null and provno not in ('351')" 
		. " and statuscode in ('0000','0100','0300','0400','1000','1100','1100','4446')" 
		. " and (ReceiveTime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$succ_num_national = stat_num($sql);

	#stat roaming-out-province total num
	$sql = "select count(*) from TSMC_MMSC where provno is not null and provno not in ('351')" 
		. " and (ReceiveTime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$total_national = stat_num($sql);

	#calculate roaming-out-province success rate
	if($total_national == 0)
	{
		$ratio_national = 0;
	}
	else
	{
		$ratio_national = ($succ_num_national / $total_national) * 1.0000;
	}

	#insert data into db
	$sql = "insert into TSMD_ROAMING_OVERALL(START_TIME, AREA_CODE, NE_TYPE, SUCC_NUM_LOCAL," 
       		. " TOTAL_LOCAL, RATIO_LOCAL, SUCC_NUM_PROVINCIAL, TOTAL_PROVINCIAL, RATIO_PROVINCIAL," 
		. " SUCC_NUM_NATIONAL, TOTAL_NATIONAL, RATIO_NATIONAL)" 
		. " values(to_date('$startdate', 'yyyy-mm-dd'), $PROVID, $PROVNETWORK, $succ_num_local," 
		. " $total_local, $ratio_local, $succ_num_provincial, $total_provincial, $ratio_provincial," 
		. " $succ_num_national, $total_national, $ratio_national)";
	$dbh->do($sql);
	$dbh->commit();
}

sub stat_num
{
	my $sth;
	my @row;
	my $num;
	my $sql = shift;

	$sth = $dbh->prepare($sql);
	$sth->execute();
	@row = $sth->fetchrow_array;
	$num = shift @row;
	$sth->finish();
	return $num;
}

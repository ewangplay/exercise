############################################################################
#Desc: stat mmsc misc success rate
#Usage:stat_mmsc_misc_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/31
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
my $LOG_CONFIG = "../log/mylog.conf";	#log output config


my @driver_names;
my $dbh;
my $stat_row_hash;


main($ARGV[0], $ARGV[1]);

sub main
{
	my ($startdate, $enddatee) = @_;

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

	$logger->info("Disconnecting from database $DBN...");

	$dbh->disconnect();
	
	$logger->info("Disconnect database success!");

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

	my $logger = Log::Log4perl->get_logger('main');

	$logger->info("Deleting outdated data at $startdate from database...");

	# delete the old data in this date section
	$sql = "delete from TSMD_MMSC_MISC_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	$logger->info("Delete outdated data success!");
	 
	$logger->info("Inserting new data at $startdate into database...");

	$sql = "select area_code,count(*) from TSMC_DSMP,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and DSMP_RESULT = 0 and CDR_TYPE = 0 and SERVICE_TYPE = 5 and REMOTENO=66"
		. " and (substr(to_char(DST_MSISDN),1,9) = start_gt) group by area_code";
	stat_num($sql,"succ_auth");
	
	$sql = "select area_code,count(*) from TSMC_DSMP,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and CDR_TYPE = 0 and SERVICE_TYPE = 5 and REMOTENO=66"
		. " and DSMP_RESULT IN (0,101,102,107,108,110,115,116,140,182,-4)"
		. " and (substr(to_char(DST_MSISDN),1,9) = start_gt) group by area_code";
	stat_num($sql,"att_auth");

	stat_ratio("succ_auth","att_auth","auth_ratio");

	# stat and insert area data
	my ($prosucc_auth,$proatt_auth,$proauth_ratio)=(0,0,0);
	foreach my $key (keys %$stat_row_hash)
	{
		my ($succ_auth,$att_auth,$auth_ratio);

		$succ_auth= $stat_row_hash->{$key}->{'succ_auth'} ? $stat_row_hash->{$key}->{'succ_auth'} : 0;
		$att_auth = $stat_row_hash->{$key}->{'att_auth'} ? $stat_row_hash->{$key}->{'att_auth'} : 0;
		$auth_ratio = $stat_row_hash->{$key}->{'auth_ratio'} ? $stat_row_hash->{$key}->{'auth_ratio'} : 0;
		$prosucc_auth += $succ_auth;
		$proatt_auth += $att_auth;
		$sql = "insert into TSMD_MMSC_MISC_OVERALL(START_TIME,AREA_CODE,SUCC_AUTH,ATT_AUTH,RATIO_AUTH,"
				. "NE_TYP)"
				. " values (to_date('$startdate','yyyy-mm-dd'),$key,$succ_auth,$att_auth,$auth_ratio,"
				. "$AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	if($prosucc_auth <= 0)
	{
		$proauth_ratio=0;
	}
	else
	{
		$proauth_ratio = ($prosucc_auth / $proatt_auth) * 1.0000;
	}
	$sql = "insert into TSMD_MMSC_MISC_OVERALL(START_TIME,AREA_CODE,SUCC_AUTH,ATT_AUTH,RATIO_AUTH,"
			. "NE_TYP)"
			. " values (to_date('$startdate','yyyy-mm-dd'),$PROVID,$prosucc_auth,$proatt_auth,$proauth_ratio,"
			. "$PROVNETWORK)";
	$dbh->do($sql);
	$dbh->commit;

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
	my ($succ_act,$att_act);
	my ($numerator,$denominator,$ratio)= @_;
	foreach my $key (keys %$stat_row_hash)
	{
		$succ_act = $stat_row_hash->{$key}->{$numerator};
		$att_act = $stat_row_hash->{$key}->{$denominator};
		
		if($att_act == 0 )
		{
			$stat_row_hash->{$key}->{$ratio} = 0;					
		}
		else
		{
			$stat_row_hash->{$key}->{$ratio} = ($succ_act / $att_act) * 1.0000;
		}
	}
}

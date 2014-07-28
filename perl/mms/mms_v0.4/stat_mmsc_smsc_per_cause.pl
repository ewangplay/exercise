############################################################################
#Desc: stat mmsc smsc per cause
#Usage:stat_mmsc_smsc_per_cause.pl [start_date] [end_date]
#Create by xie jiayou  2009/1/4
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
my $stat_area_total_array;


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
	$sql = "delete from TSMD_MMSC_SMSC_PER_CAUSE" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;
 
	$logger->info("Delete outdated data success!");
	 
	$logger->info("Inserting new data at $startdate into database...");

	# stat and insert area data	
	$sql = "select area_code,RESULT,count(*) from TSMC_MMS_PUSH,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and RESULT IN (0,1042,-1)"
		. " and ('86'||substr(to_char(CALLED),1,7) = start_gt) group by area_code,RESULT";
	stat_num($sql);
	
	for (@$stat_area_total_array)
	{
		my ($area_code,$push_result,$num);
		
		$area_code = $_->[0] ? $_->[0] : 999;
		$push_result = $_->[1] ? $_->[1] : 0;
		$num = $_->[2] ? $_->[2] : 0;

		$sql = "insert into TSMD_MMSC_SMSC_PER_CAUSE(START_TIME,AREA_CODE,RESULT,"
				. "NUM,RATIO,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$area_code,$push_result,"
				. "$num,0,$AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;
	
	$sql = "select area_code,sum(NUM) from TSMD_MMSC_SMSC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by area_code";
	stat_area_total($sql,"total");

	stat_rate($startdate,$AREANETWORK);
		
	# insert province stat data
	$stat_area_total_array = [];
	$stat_row_hash = {};
	$sql = "select RESULT,sum(NUM) from TSMD_MMSC_SMSC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by RESULT";
	stat_num2($sql);
	
	for (@$stat_area_total_array)
	{
		my ($result,$num);
		
		$result = $_->[0] ? $_->[0] : 0;
		$num = $_->[1] ? $_->[1] : 0;

		$sql = "insert into TSMD_MMSC_SMSC_PER_CAUSE(START_TIME,AREA_CODE,RESULT,"
				. "NUM,RATIO,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$PROVID,$result,"
				. "$num,0,$PROVNETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	sleep(1);
	
	$sql = "select sum(NUM) from TSMD_MMSC_SMSC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	stat_prov_total($sql,"alltotal");

	stat_prov_rate($startdate,$PROVNETWORK);

	update_title($startdate);

	$logger->info("Insert new data success!");
}

sub stat_num
{
	my @row;
	my $sth;
	my $i;
	my ($sql) = @_;
   
	$sth = $dbh->prepare($sql);
	$sth->execute();

	$i=0;
	while(@row = $sth->fetchrow_array){
		$stat_area_total_array->[$i][0] = $row[0];		
		$stat_area_total_array->[$i][1]= $row[1];		
		$stat_area_total_array->[$i][2] = $row[2];		
		$i++;
	}
	$sth->finish;
}

sub stat_num2
{
	my @row;
	my $sth;
	my $i;
	my ($sql) = @_;
   
	$sth = $dbh->prepare($sql);
	$sth->execute();

	$i=0;
	while(@row = $sth->fetchrow_array){
		$stat_area_total_array->[$i][0] = $row[0];		
		$stat_area_total_array->[$i][1]= $row[1];		
		$i++;
	}
	$sth->finish;
}

sub stat_area_total
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

sub stat_prov_total
{
	my @row;
	my $sth;
	my ($sql,$col) = @_;

	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{'prov'}->{$col} = $row[0];		
	}
	$sth->finish;
}

sub stat_rate
{
	my ($total,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'total'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_MMSC_SMSC_PER_CAUSE set RATIO = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$key and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_MMSC_SMSC_PER_CAUSE set RATIO = (NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$key and NE_TYP=$ne_type";

		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub stat_prov_rate
{
	my ($total,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'alltotal'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_MMSC_SMSC_PER_CAUSE set RATIO = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$PROVID and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_MMSC_SMSC_PER_CAUSE set RATIO = (NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$PROVID and NE_TYP=$ne_type";

		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub update_title
{
	my $startdate = shift ;
	my $sql;

	$sql = "update TSMD_MMSC_SMSC_PER_CAUSE a set RESULT_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=170)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$dbh->do($sql);
	$dbh->commit;	
}

############################################################################
#Desc: stat gb success per cause
#Usage:stat_gb_per_cause.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/24
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
	$sql = "delete from TSMD_GB_PER_CAUSE" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;
 
	$logger->info("Delete outdated data success!");
	 
	$logger->info("Inserting new data at $startdate into database...");

	# stat and insert  data	
	$sql = "select gdrtype,result,count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and gdrtype in (1,5,65,70) group by gdrtype,result";
	stat_num($sql);
	
	for (@$stat_area_total_array)
	{
		my ($gdrtype,$result,$num);
		
		$gdrtype = $_->[0] ? $_->[0] : 0;
		$result = $_->[1] ? $_->[1] : 0;
		$num = $_->[2] ? $_->[2] : 0;

		my $sql = "insert into TSMD_GB_PER_CAUSE(START_TIME,AREA_CODE,RESULT,SIGNALLING_MSG_TYPE,"
				. "NUM,RATIO,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$PROVID,$result,$gdrtype,"
				. "$num,0,$PROVNETWORK)";
		$dbh->do($sql);
		
	}
	$dbh->commit;

	sleep(2);
	
	$sql = "select SIGNALLING_MSG_TYPE,sum(NUM) from TSMD_GB_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by SIGNALLING_MSG_TYPE";
	stat_area_total($sql,"total");

	stat_rate($startdate,$PROVNETWORK);
		
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

sub stat_rate
{
	my ($num,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $gdrtype (keys %$stat_row_hash)
	{
		$num = $stat_row_hash->{$gdrtype}->{'total'};
		
		if($num == 0 )
		{
			$sql = "update TSMD_GB_PER_CAUSE set RATIO = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and SIGNALLING_MSG_TYPE=$gdrtype and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_GB_PER_CAUSE set RATIO = (NUM / $num) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and SIGNALLING_MSG_TYPE=$gdrtype and NE_TYP=$ne_type";

		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub update_title
{
	my $startdate = shift ;
	my $sql;

	$sql = "update TSMD_GB_PER_CAUSE a set RESULT_TITLE = (select DESCRIPTION_EN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=125)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$dbh->do($sql);
	$dbh->commit;	

	$sql = " update TSMD_GB_PER_CAUSE a set RESULT_TITLE = (select DESCRIPTION_EN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=126)"
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$dbh->do($sql);
	$dbh->commit;
}

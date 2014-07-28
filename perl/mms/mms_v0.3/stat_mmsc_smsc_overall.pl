############################################################################
#Desc: stat mmsc smsc success rate
#Usage:stat_mmsc_smsc_overall.pl [start_date] [end_date]
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
	$sql = "delete from TSMD_MMSC_SMSC_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	$sql = "select area_code,count(*) from TSMC_MMS_PUSH,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and RESULT = 0 "
		. " and ('86'||substr(to_char(CALLED),1,7) = start_gt) group by area_code";
	stat_num($sql,"succ_push");

	$sql = "select area_code,count(*) from TSMC_MMS_PUSH,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and RESULT IN (0,1042,-1)"
		. " and ('86'||substr(to_char(CALLED),1,7) = start_gt) group by area_code";
	stat_num($sql,"att_push");

	stat_ratio("succ_push","att_push","push_ratio");

	# stat and insert area data
	my ($prosucc_push,$proatt_push,$propush_ratio)=(0,0,0);
	foreach my $key (keys %$stat_row_hash)
	{
		my ($succ_push,$att_push,$push_ratio);

		$succ_push= $stat_row_hash->{$key}->{'succ_push'} ? $stat_row_hash->{$key}->{'succ_push'} : 0;
		$att_push = $stat_row_hash->{$key}->{'att_push'} ? $stat_row_hash->{$key}->{'att_push'} : 0;
		$push_ratio = $stat_row_hash->{$key}->{'push_ratio'} ? $stat_row_hash->{$key}->{'push_ratio'} : 0;
		$prosucc_push += $succ_push;
		$proatt_push += $att_push;
		$sql = "insert into TSMD_MMSC_SMSC_OVERALL(START_TIME,AREA_CODE,SUCC_PUSH_SEND,ATT_PUSH_SEND,RATIO_PUSH_SEND,"
				. "NE_TYP)"
				. " values (to_date('$startdate','yyyy-mm-dd'),$key,$succ_push,$att_push,$push_ratio,"
				. "$AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	if($prosucc_push <= 0)
	{
		$propush_ratio=0;
	}
	else
	{
		$propush_ratio = ($prosucc_push / $proatt_push) * 1.0000;
	}
	
	$sql = "insert into TSMD_MMSC_SMSC_OVERALL(START_TIME,AREA_CODE,SUCC_PUSH_SEND,ATT_PUSH_SEND,RATIO_PUSH_SEND,"
			. "NE_TYP)"
			. " values (to_date('$startdate','yyyy-mm-dd'),$PROVID,$prosucc_push,$proatt_push,$propush_ratio,"
			. "$PROVNETWORK)";
	$dbh->do($sql);
	$dbh->commit;
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

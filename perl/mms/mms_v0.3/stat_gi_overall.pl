############################################################################
#Desc: stat gi success rate
#Usage:stat_gi_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/25
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
		die "enddate not be null";
	}
	elsif($startdate ne "" and $enddate eq "") 
	{
		die "startdate not be null";
	}
	else
	{
		my @date_array;
		$startdate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "startdate erroe ex:2009-01-01";
		$enddate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "enddate erroe ex:2009-01-01";
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
	my $startdate = shift;
	
	# delete the old data in this date section
	$sql = "delete from TSMD_GI_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	$sql = "select area_code,count(*) from TSMC_MMS_MO,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (MMSE_RESULT=128) and cdr_type=0 and REMOTENO=66"
		. " and substr(to_char(CALLING),1,9) = start_gt group by area_code";
	stat_num($sql,"succ_mo");

	$sql = "select area_code,count(*) from TSMC_MMS_MO,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and cdr_type=0 and REMOTENO=66"
		. " and substr(to_char(CALLING),1,9) = start_gt group by area_code";
	stat_num($sql,"att_mo");

	stat_ratio("succ_mo","att_mo","mo_ratio");

	$sql = "select area_code,count(*) from TSMC_MMS_MT,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (MMSE_RESULT=129) and cdr_type=0 and REMOTENO=66"
		. " and ((substr(to_char(CALLED),1,9) = start_gt) or (substr(to_char(CALLED),1,7) = substr(to_char(start_gt),3,7))) group by area_code";
	stat_num($sql,"succ_mt");

	$sql = "select area_code,count(*) from TSMC_MMS_MT,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and cdr_type=0 and REMOTENO=66"
		. " and ((substr(to_char(CALLED),1,9) = start_gt) or (substr(to_char(CALLED),1,7) = substr(to_char(start_gt),3,7))) group by area_code";
	stat_num($sql,"att_mt");

	stat_ratio("succ_mt","att_mt","mt_ratio");

	# stat and insert area data
	my ($prosucc_mo,$proatt_mo,$promo_ratio,$prosucc_mt,$proatt_mt,$promt_ratio)=(0,0,0,0,0,0);
	foreach my $key (keys %$stat_row_hash)
	{
		my ($succ_mo,$att_mo,$mo_ratio,$succ_mt,$att_mt,$mt_ratio);

		$succ_mo = $stat_row_hash->{$key}->{'succ_mo'} ? $stat_row_hash->{$key}->{'succ_mo'} : 0;
		$att_mo = $stat_row_hash->{$key}->{'att_mo'} ? $stat_row_hash->{$key}->{'att_mo'} : 0;
		$mo_ratio = $stat_row_hash->{$key}->{'mo_ratio'} ? $stat_row_hash->{$key}->{'mo_ratio'} : 0;
		$succ_mt= $stat_row_hash->{$key}->{'succ_mt'} ? $stat_row_hash->{$key}->{'succ_mt'} : 0;
		$att_mt = $stat_row_hash->{$key}->{'att_mt'} ? $stat_row_hash->{$key}->{'att_mt'} : 0;
		$mt_ratio = $stat_row_hash->{$key}->{'mt_ratio'} ? $stat_row_hash->{$key}->{'mt_ratio'} : 0;
		$prosucc_mo += $succ_mo;
		$proatt_mo += $att_mo;
		$prosucc_mt += $succ_mt;
		$proatt_mt += $att_mt;
		my $sql = "insert into TSMD_GI_OVERALL(START_TIME,AREA_CODE,SUCC_MO,ATT_MO,RATIO_MO,"
				. "SUCC_MT,ATT_MT,RATIO_MT,NE_TYP)"
				. " values (to_date('$startdate','yyyy-mm-dd'),$key,$succ_mo,$att_mo,$mo_ratio,"
				. "$succ_mt,$att_mt,$mt_ratio,$AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	# insert province stat data
	if($prosucc_mo <= 0)
	{
		$promo_ratio=0;
	}
	else
	{
		$promo_ratio = ($prosucc_mo / $proatt_mo) * 1.0000;
	}
	if($prosucc_mt <= 0)
	{
		$promt_ratio=0;
	}
	else
	{
		$promt_ratio = ($prosucc_mt / $proatt_mt) * 1.0000;
	}
	
	my $sql = "insert into TSMD_GI_OVERALL(START_TIME,AREA_CODE,SUCC_MO,ATT_MO,RATIO_MO,"
			. "SUCC_MT,ATT_MT,RATIO_MT,NE_TYP)"
			. " values (to_date('$startdate','yyyy-mm-dd'),$PROVID,$prosucc_mo,$proatt_mo,$promo_ratio,"
			. "$prosucc_mt,$proatt_mt,$promt_ratio,$PROVNETWORK)";
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

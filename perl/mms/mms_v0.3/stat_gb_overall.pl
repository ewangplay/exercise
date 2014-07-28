############################################################################
#Desc: stat gb success rate
#Usage:stat_gb_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/23
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
	$sql = "delete from TSMD_GB_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=65)"
		. " and (result=254)";
	stat_num($sql,"succ_act");		

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=65)";
	stat_num($sql,"att_act");					 

	stat_ratio("succ_act","att_act","act_ratio");

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=70)"
		. " and (result=254)";
	stat_num($sql,"succ_deact");		

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=70)";
	stat_num($sql,"att_deact");					 

	stat_ratio("succ_deact","att_deact","deact_ratio");

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=1)"
		. " and (result=254)";
	stat_num($sql,"succ_gprs");		

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=1)";
	stat_num($sql,"att_gprs");					 

	stat_ratio("succ_gprs","att_gprs","gprs_ratio");
	
	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=5)"
		. " and (result=254)";
	stat_num($sql,"succ_gprs_deact");		

	$sql = "Select count(*) from TSMG_GPRS_GB" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype=5)";
	stat_num($sql,"att_gprs_deact");					 

	stat_ratio("succ_gprs_deact","att_gprs_deact","deact_gprs_ratio");

	# stat and insert area data
	foreach my $key (keys %$stat_row_hash)
	{
		my ($succ_act,$att_act,$succ_deact,$att_deact,$act_ratio,$deact_ratio);
		my ($succ_gprs,$att_gprs,$succ_gprs_deact,$att_gprs_deact,$gprs_ratio,$deact_gprs_ratio);
		
		$succ_act = $stat_row_hash->{$key}->{'succ_act'} ? $stat_row_hash->{$key}->{'succ_act'} : 0;
		$att_act = $stat_row_hash->{$key}->{'att_act'} ? $stat_row_hash->{$key}->{'att_act'} : 0;
		$succ_deact = $stat_row_hash->{$key}->{'succ_deact'} ? $stat_row_hash->{$key}->{'succ_deact'} : 0;
		$att_deact= $stat_row_hash->{$key}->{'att_deact'} ? $stat_row_hash->{$key}->{'att_deact'} : 0;
		$act_ratio = $stat_row_hash->{$key}->{'act_ratio'} ? $stat_row_hash->{$key}->{'act_ratio'} : 0;
		$deact_ratio = $stat_row_hash->{$key}->{'deact_ratio'} ? $stat_row_hash->{$key}->{'deact_ratio'} : 0;
		$succ_gprs = $stat_row_hash->{$key}->{'succ_gprs'} ? $stat_row_hash->{$key}->{'succ_gprs'} : 0;
		$att_gprs = $stat_row_hash->{$key}->{'att_gprs'} ? $stat_row_hash->{$key}->{'att_gprs'} : 0;
		$succ_gprs_deact = $stat_row_hash->{$key}->{'succ_gprs_deact'} ? $stat_row_hash->{$key}->{'succ_gprs_deact'} : 0;
		$att_gprs_deact= $stat_row_hash->{$key}->{'att_gprs_deact'} ? $stat_row_hash->{$key}->{'att_gprs_deact'} : 0;
		$gprs_ratio = $stat_row_hash->{$key}->{'gprs_ratio'} ? $stat_row_hash->{$key}->{'gprs_ratio'} : 0;
		$deact_gprs_ratio = $stat_row_hash->{$key}->{'deact_gprs_ratio'} ? $stat_row_hash->{$key}->{'deact_gprs_ratio'} : 0;
		my $sql = "insert into TSMD_GB_OVERALL(START_TIME,AREA_CODE,SUCC_ACT_PDP_CONTEXT_MS,ATT_ACT_PDP_CONTEXT_MS,RATIO_ACT_PDP_CONTEXT_MS,"
				. "SUCC_DEACT_PDP_CONTEXT_MS,ATT_DEACT_PDP_CONTEXT_MS,RATIO_DEACT_PDP_CONTEXT_MS,"
				. "SUCC_GPRS_ATTACH,ATT_GPRS_ATTACH,RATIO_GPRS_ATTACH,SUCC_GPRS_DEATTACH,ATT_GPRS_DEATTACH,RATIO_GPRS_DEATTACH,NE_TYP)"
				. " values (to_date('$startdate','yyyy-mm-dd'),$key,$succ_act,$att_act,$act_ratio,"
				. "$succ_deact,$att_deact,$deact_ratio,"
				. "$succ_gprs,$att_gprs,$gprs_ratio,$succ_gprs_deact,$att_gprs_deact,$deact_gprs_ratio,$PROVNETWORK)";
		$dbh->do($sql);
	}
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
		$stat_row_hash->{$PROVID}->{$col} = $row[0];		
	}
	$sth->finish;
}

sub stat_ratio
{
	my ($succ_act,$att_act);
	my ($numerator,$denominator,$ratio)= @_;

	foreach my $areakey (keys %$stat_row_hash)
	{
		$succ_act = $stat_row_hash->{$areakey}->{$numerator};
		$att_act = $stat_row_hash->{$areakey}->{$denominator};
		
		if($att_act == 0 )
		{
			$stat_row_hash->{$areakey}->{$ratio} = 0;					
		}
		else
		{
			$stat_row_hash->{$areakey}->{$ratio} = ($succ_act / $att_act) * 1.00;
		}
	}
}

############################################################################
#Desc: stat gn success rate
#Usage:stat_gn_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/18
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
	$sql = "delete from TSMD_GN_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;
 
	stat_att_act_pdp_context_ms($startdate);
	stat_succ_act_pdp_context_ms($startdate);
	stat_att_deact_pdp_context_ms($startdate);
	stat_succ_deact_pdp_context_ms($startdate);
	stat_ratio_act_pdp_context_ms();
	stat_ratio_deact_pdp_context_ms(); 
	
	# stat and insert area data
	foreach my $areakey (keys %$stat_row_hash)
	{
		my ($succ_act,$att_act,$succ_deact,$att_deact,$ratio_act,$ratio_deact);
		$succ_act = $stat_row_hash->{$areakey}->{'succ_act'} ? $stat_row_hash->{$areakey}->{'succ_act'} : 0;
		$att_act = $stat_row_hash->{$areakey}->{'att_act'} ? $stat_row_hash->{$areakey}->{'att_act'} : 0;
		$succ_deact = $stat_row_hash->{$areakey}->{'succ_deact'} ? $stat_row_hash->{$areakey}->{'succ_deact'} : 0;
		$att_deact= $stat_row_hash->{$areakey}->{'att_deact'} ? $stat_row_hash->{$areakey}->{'att_deact'} : 0;
		$ratio_act = $stat_row_hash->{$areakey}->{'ratio_act'} ? $stat_row_hash->{$areakey}->{'ratio_act'} : 0;
		$ratio_deact = $stat_row_hash->{$areakey}->{'ratio_deact'} ? $stat_row_hash->{$areakey}->{'ratio_deact'} : 0;
		my $sql = "insert into TSMD_GN_OVERALL(START_TIME,AREA_CODE,SUCC_ACT_PDP_CONTEXT_MS,ATT_ACT_PDP_CONTEXT_MS,RATIO_ACT_PDP_CONTEXT_MS,"
				. "SUCC_DEACT_PDP_CONTEXT_MS,ATT_DEACT_PDP_CONTEXT_MS,RATIO_DEACT_PDP_CONTEXT_MS,NE_TYP)"
				. " values (to_date('$startdate','yyyy-mm-dd'),$areakey,$succ_act,$att_act,$ratio_act,"
				. "$succ_deact,$att_deact,$ratio_deact,$PROVNETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub stat_succ_act_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='16')"
		. " and (result='128')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$PROVID}->{'succ_act'} = $row[0];		
	}
	$sth->finish;
}

sub stat_att_act_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='16')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$PROVID}->{'att_act'} = $row[0];		
	}
	$sth->finish;
}

sub stat_succ_deact_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='20')"
		. " and (result='128')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$PROVID}->{'succ_deact'} = $row[0];		
	}
	$sth->finish;
}

sub stat_att_deact_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($startdate) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='20')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$PROVID}->{'att_deact'} = $row[0];		
	}
	$sth->finish;
}

sub stat_ratio_act_pdp_context_ms
{
	my ($succ_act,$att_act);
	foreach my $areakey (keys %$stat_row_hash)
	{
		$succ_act = $stat_row_hash->{$areakey}->{'succ_act'};
		$att_act = $stat_row_hash->{$areakey}->{'att_act'};
		
		if($att_act == 0 )
		{
			$stat_row_hash->{$areakey}->{'ratio_act'} = 0;					
		}
		else
		{
			$stat_row_hash->{$areakey}->{'ratio_act'} = ($succ_act / $att_act) * 1.00;
		}
	}
}

sub stat_ratio_deact_pdp_context_ms
{
	my ($succ_deact,$att_deact);
	
	foreach my $areakey (keys %$stat_row_hash)
	{
		$succ_deact = $stat_row_hash->{$areakey}->{'succ_deact'};
		$att_deact = $stat_row_hash->{$areakey}->{'att_deact'};
		if($att_deact == 0 )
		{
			$stat_row_hash->{$areakey}->{'ratio_deact'} = 0;					
		}
		else
		{
			$stat_row_hash->{$areakey}->{'ratio_deact'} = ($succ_deact / $att_deact) * 1.00;
		}
	}	
}

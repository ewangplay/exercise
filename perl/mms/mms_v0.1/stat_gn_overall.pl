############################################################################
#Desc: stat gn success rate
#Usage:stat_gn_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/18
############################################################################

use DBI;
use Time::Local;
use POSIX qw(strftime);
use strict;

my @driver_names;
my $dbh;


my $dbn="DBI:Oracle:gpnms4";
my $usr="nmsadm";
my $passwd="nms_8899";
my $provnetwork=10000; #province network type
my $provid=1751711880; #area network type

my $stat_row_hash;
my ($starttime,$endtime);

$starttime = $ARGV[0];
$endtime = $ARGV[1];
 

@driver_names = DBI->available_drivers;

$dbh = DBI->connect($dbn, $usr, $passwd,
        { RaiseError => 1, AutoCommit => 0 }) or die "Couldn't connect to database: " . DBI->errstr; 

if ($starttime eq "" and $endtime eq "")
{
	my $startdate = "2008-10-23";
	#my $startdate = strftime "%Y-%m-%d",localtime(time() - 86400) ;
	main($startdate);
}
elsif($starttime eq "" and $endtime ne "")
{
	die "endtim not be null";
}
elsif($starttime ne "" and $endtime eq "") 
{
	die "starttime not be null";
}
else
{
	my @date_array;
	$starttime =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "starttime erroe ex:2009-01-01";
	$endtime =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "endtim erroe ex:2009-01-01";
	@date_array = getdatearry($starttime,$endtime);
	for(@date_array)
	{
		main($_);
	}
	
}
sub getdatearry
{
	my @datearry;
	my $starttime = shift;
	my $endtime = shift;
	my @startstr = split(/-/,$starttime);
	my @endstr = split(/-/,$endtime);
	my $stims = timelocal("59","59","23",$startstr[2],($startstr[1]-1),$startstr[0]);
	my $etims = timelocal("59","59","23",@endstr[2],(@endstr[1]-1),@endstr[0]);
	if($stims>$etims) {@datearry=()}
	my $day = ($etims - $stims) / 84600;
	#$datearry[0] = $starttime;
	for(my $i=0;$i<$day;$i++)
	{
		$datearry[$i] = strftime "%Y-%m-%d", localtime($stims + 84600*$i);	
	}
	return @datearry;
}

sub main
{
	my $sth;
	my $startdate = shift; 
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
				. "$succ_deact,$att_deact,$ratio_deact,$provnetwork)";
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}

	$dbh->disconnect;
	exit(0);
}
sub stat_succ_act_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($starttime) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='16')"
		. " and (result='128')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$provid}->{'succ_act'} = $row[0];		
	}
	$sth->finish;
}

sub stat_att_act_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($starttime) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='16')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$provid}->{'att_act'} = $row[0];		
	}
	$sth->finish;
}

sub stat_succ_deact_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($starttime) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='20')"
		. " and (result='128')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$provid}->{'succ_deact'} = $row[0];		
	}
	$sth->finish;
}

sub stat_att_deact_pdp_context_ms
{
	my @row;
	my $sql;
	my $sth;
	my ($starttime) = @_;

	$sql = "Select count(*) from TSMG_GPRS_GN" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (gdrtype='20')";
		
	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{$provid}->{'att_deact'} = $row[0];		
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

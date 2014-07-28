############################################################################
#Desc: stat mmsc wapgw success rate
#Usage:stat_mmsc_wapgw_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/29
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
my $areanetwork=10001; #province network type
my $provid=1751711880; #province id

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
	my $sql;
	my $starttime = shift;
	
	$sql = "select area_code,count(*) from TSMC_MMS_MO,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (MMSE_RESULT=128) and cdr_type=1 and REMOTENO=66"
		. " and substr(to_char(CALLING),1,9) = start_gt group by area_code";
	stat_num($sql,"succ_mo");
	$sql = "select area_code,count(*) from TSMC_MMS_MO,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and cdr_type=1 and REMOTENO=66"
		. " and substr(to_char(CALLING),1,9) = start_gt group by area_code";
	stat_num($sql,"att_mo");
	stat_ratio("succ_mo","att_mo","mo_ratio");

	$sql = "select area_code,count(*) from TSMC_MMS_MT,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and (MMSE_RESULT=129) and cdr_type=1 and REMOTENO=66"
		. " and ((substr(to_char(CALLED),1,9) = start_gt) or (substr(to_char(CALLED),1,7) = substr(to_char(start_gt),3,7))) group by area_code";
	stat_num($sql,"succ_mt");
	$sql = "select area_code,count(*) from TSMC_MMS_MT,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and cdr_type=1 and REMOTENO=66"
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
		my $sql = "insert into TSMD_MMSC_WAPGW_OVERALL(START_TIME,AREA_CODE,SUCC_MO,ATT_MO,RATIO_MO,"
				. "SUCC_MT,ATT_MT,RATIO_MT,NE_TYP)"
				. " values (to_date('$starttime','yyyy-mm-dd'),$key,$succ_mo,$att_mo,$mo_ratio,"
				. "$succ_mt,$att_mt,$mt_ratio,$areanetwork)";
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
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
	
	my $sql = "insert into TSMD_MMSC_WAPGW_OVERALL(START_TIME,AREA_CODE,SUCC_MO,ATT_MO,RATIO_MO,"
			. "SUCC_MT,ATT_MT,RATIO_MT,NE_TYP)"
			. " values (to_date('$starttime','yyyy-mm-dd'),$provid,$prosucc_mo,$proatt_mo,$promo_ratio,"
			. "$prosucc_mt,$proatt_mt,$promt_ratio,$provnetwork)";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$dbh->commit;

	$dbh->disconnect;
	exit(0);
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

############################################################################
#Desc: stat mmsc misc success rate
#Usage:stat_mmsc_misc_overall.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/31
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
	

	$sql = "select area_code,count(*) from TSMC_DSMP,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and DSMP_RESULT = 0 and CDR_TYPE = 0 and SERVICE_TYPE = 5 and REMOTENO=66"
		. " and (substr(to_char(DST_MSISDN),1,9) = start_gt) group by area_code";
	stat_num($sql,"succ_auth");
	$sql = "select area_code,count(*) from TSMC_DSMP,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
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
		my $sql = "insert into TSMD_MMSC_MISC_OVERALL(START_TIME,AREA_CODE,SUCC_AUTH,ATT_AUTH,RATIO_AUTH,"
				. "NE_TYP)"
				. " values (to_date('$starttime','yyyy-mm-dd'),$key,$succ_auth,$att_auth,$auth_ratio,"
				. "$areanetwork)";
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
	if($prosucc_auth <= 0)
	{
		$proauth_ratio=0;
	}
	else
	{
		$proauth_ratio = ($prosucc_auth / $proatt_auth) * 1.0000;
	}
	
	my $sql = "insert into TSMD_MMSC_MISC_OVERALL(START_TIME,AREA_CODE,SUCC_AUTH,ATT_AUTH,RATIO_AUTH,"
			. "NE_TYP)"
			. " values (to_date('$starttime','yyyy-mm-dd'),$provid,$prosucc_auth,$proatt_auth,$proauth_ratio,"
			. "$provnetwork)";
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

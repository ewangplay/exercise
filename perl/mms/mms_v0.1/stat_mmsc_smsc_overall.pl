############################################################################
#Desc: stat mmsc smsc success rate
#Usage:stat_mmsc_smsc_overall.pl [start_date] [end_date]
#Create by xie jiayou  2009/1/4
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
	

	$sql = "select area_code,count(*) from TSMC_MMS_PUSH,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and RESULT = 0 "
		. " and ('86'||substr(to_char(CALLED),1,7) = start_gt) group by area_code";
	stat_num($sql,"succ_push");
	$sql = "select area_code,count(*) from TSMC_MMS_PUSH,TSMS_START_GT" 
		. " where (start_time between to_date('" . $starttime . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $starttime . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
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
		my $sql = "insert into TSMD_MMSC_SMSC_OVERALL(START_TIME,AREA_CODE,SUCC_PUSH_SEND,ATT_PUSH_SEND,RATIO_PUSH_SEND,"
				. "NE_TYP)"
				. " values (to_date('$starttime','yyyy-mm-dd'),$key,$succ_push,$att_push,$push_ratio,"
				. "$areanetwork)";
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
	if($prosucc_push <= 0)
	{
		$propush_ratio=0;
	}
	else
	{
		$propush_ratio = ($prosucc_push / $proatt_push) * 1.0000;
	}
	
	my $sql = "insert into TSMD_MMSC_SMSC_OVERALL(START_TIME,AREA_CODE,SUCC_PUSH_SEND,ATT_PUSH_SEND,RATIO_PUSH_SEND,"
			. "NE_TYP)"
			. " values (to_date('$starttime','yyyy-mm-dd'),$provid,$prosucc_push,$proatt_push,$propush_ratio,"
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

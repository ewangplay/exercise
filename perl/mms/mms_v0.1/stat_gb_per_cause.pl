############################################################################
#Desc: stat gb success per cause
#Usage:stat_gb_per_cause.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/24
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
my $areanetwork=10001; #area network type
my $provid=1751711880; 

my $stat_row_hash;
my $stat_area_total_array;


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
	my $startdate = shift;
	 
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
				. " values(to_date('$startdate','yyyy-mm-dd'),$provid,$result,$gdrtype,"
				. "$num,0,$provnetwork)";
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
		
	}
	sleep(2);
	
	$sql = "select SIGNALLING_MSG_TYPE,sum(NUM) from TSMD_GB_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by SIGNALLING_MSG_TYPE";
	stat_area_total($sql,"total");

	stat_rate($startdate,$provnetwork);
		
	update_title($startdate);
	
	$dbh->disconnect;
	exit(0);
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
	my $sth;
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
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
}

sub update_title
{
	my $startdate = shift ;
	my $sql;
	my $sth;	
	$sql = "update TSMD_GB_PER_CAUSE a set RESULT_TITLE = (select DESCRIPTION_EN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=125)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$dbh->commit;	
	$sql = " update TSMD_GB_PER_CAUSE a set RESULT_TITLE = (select DESCRIPTION_EN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=126)"
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$dbh->commit;
}

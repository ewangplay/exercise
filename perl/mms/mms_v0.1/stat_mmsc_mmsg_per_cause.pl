############################################################################
#Desc: stat mmsc mmsg per cause
#Usage:stat_mmsc_mmsg_per_cause.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/30
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
my $provid=1751711880; #province id

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
	 
	# stat and insert area data	
	$sql = "select area_code,STATUS_TEXT,count(*) from TSMC_MMS_MM7,TSMS_START_GT" 
		. " where (start_time between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and STATUS_TEXT IN (1000,4446,4442,4441,4770,2000,4444,4443,6003,6103,0) and MM7_TYPE=7 and remoteno=66"
		. " and substr(to_char(called),2,9) = start_gt group by area_code,STATUS_TEXT";
		
	stat_num($sql);
	
	for (@$stat_area_total_array)
	{
		my ($area_code,$status_text,$num);
		
		$area_code = $_->[0] ? $_->[0] : 999;
		$status_text = $_->[1] ? $_->[1] : 0;
		$num = $_->[2] ? $_->[2] : 0;

		my $sql = "insert into TSMD_MMSC_MMSG_PER_CAUSE(START_TIME,AREA_CODE,RESULT,SIGNALLING_MSG_TYPE,"
				. "NUM,RATIO,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$area_code,$status_text,2,"
				. "$num,0,$areanetwork)";

		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
	
	$sql = "select SIGNALLING_MSG_TYPE,area_code,sum(NUM) from TSMD_MMSC_MMSG_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by SIGNALLING_MSG_TYPE,area_code";

	stat_area_total($sql,"total");
	stat_rate($startdate,$areanetwork);
		
	# insert province stat data
	$stat_area_total_array = [];
	$stat_row_hash = {};
	$sql = "select SIGNALLING_MSG_TYPE,RESULT,sum(NUM) from TSMD_MMSC_MMSG_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by SIGNALLING_MSG_TYPE,RESULT";
		
	stat_num($sql);
	
	for (@$stat_area_total_array)
	{
		my ($signalling_msg_type,$result,$num);
		
		$signalling_msg_type = $_->[0] ? $_->[0] : 0;
		$result = $_->[1] ? $_->[1] : 0;
		$num = $_->[2] ? $_->[2] : 0;

		my $sql = "insert into TSMD_MMSC_MMSG_PER_CAUSE(START_TIME,AREA_CODE,RESULT,SIGNALLING_MSG_TYPE,"
				. "NUM,RATIO,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$provid,$result,$signalling_msg_type,"
				. "$num,0,$provnetwork)";

		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
		
	}
	sleep(1);
	
	$sql = "select SIGNALLING_MSG_TYPE,sum(NUM) from TSMD_MMSC_MMSG_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by SIGNALLING_MSG_TYPE";

	stat_prov_total($sql,"alltotal");

	stat_prov_rate($startdate,$provnetwork);
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
		$stat_row_hash->{$row[0] . ":" . $row[1]}->{$col} = $row[2];		
	}
	$sth->finish;
}
sub stat_prov_total
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
	my ($total,$sql);
	my $sth;
	my $startdate = shift ;
	my $ne_type = shift;
	foreach my $key (keys %$stat_row_hash)
	{
		my($gdrtype,$areacode)= split(/:/,$key);
		$total = $stat_row_hash->{$key}->{'total'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_MMSC_MMSG_PER_CAUSE set RATIO = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areacode and SIGNALLING_MSG_TYPE= $gdrtype and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_MMSC_MMSG_PER_CAUSE set RATIO = (NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areacode and SIGNALLING_MSG_TYPE= $gdrtype and NE_TYP=$ne_type";

		}
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
}
sub stat_prov_rate
{
	my ($total,$sql);
	my $sth;
	my $startdate = shift ;
	my $ne_type = shift;
	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'alltotal'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_MMSC_MMSG_PER_CAUSE set RATIO = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$provid and SIGNALLING_MSG_TYPE= $key and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_MMSC_MMSG_PER_CAUSE set RATIO = (NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$provid and SIGNALLING_MSG_TYPE= $key and NE_TYP=$ne_type";

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
	$sql = "update TSMD_MMSC_MMSG_PER_CAUSE a set RESULT_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=150)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$dbh->commit;	
}

############################################################################
#Desc: stat cdr mm7 ao fail per cause
#Usage:stat_cdr_mm7_ao_fcaa.pl [start_date] [end_date]
#Create by xie jiayou  2009/01/12
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
		
	$sql = "Select A3.area_code,A2.Mmse_result, A1.statuscode, count(*) from TSMC_MMSC A1,TSMC_MMS_MO A2, TSMS_START_GT A3" 
		. " where (A1.sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and A2.cdr_type=1 and remoteno=66"
		. " and mmse_result in (128,130,135,136,-1)"
		. " and A1.statuscode=6001"
		. " and A1.receivetime>=A2.start_time"
		. " and A1.receivetime<=A2.start_time+ interval '20' second"
		. " and substr(to_char(A1.sendAddress),3,13)=substr(to_char(A2.calling),1,13)"
		. " and substr(to_char(A2.calling),1,9) = A3.start_gt"
		. " group by A3.area_code, A1.statuscode, A2.Mmse_result";
		
	stat_num1($sql);
	
	for (@$stat_area_total_array)
	{
		my ($area_code,$mmse_result,$statuscode,$num);
		
		$area_code = $_->[0] ? $_->[0] : 999;
		$mmse_result = $_->[1] ? $_->[1] : 0;
		$statuscode = $_->[2] ? $_->[2] : 0;
		$num = $_->[3] ? $_->[3] : 0;

		my $sql = "insert into TSMD_CDR_MM7_AO_FCAA(START_TIME,AREA_CODE,RESULT,MMS_STATUS_CODE,"
				. "FCAA_NUM,RATIO_IN_TOTAL,AVG_RATIO_IN_TOTAL,NE_TYPE)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$area_code,$mmse_result,$statuscode,"
				. "$num,0,0,$areanetwork)";

		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
	
	$sql = "select MMS_STATUS_CODE,area_code,sum(FCAA_NUM) from TSMD_CDR_MM7_AO_FCAA" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by MMS_STATUS_CODE,area_code";

	stat_area_total($sql,"total");
	stat_rate($startdate,$areanetwork);

	$stat_row_hash = {};
	$sql = "select area_code,sum(FCAA_NUM) from TSMD_CDR_MM7_AO_FCAA" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by area_code";

	stat_total($sql,"resulttotal");
	stat_avg_rate($startdate,$areanetwork);
		
	# insert province stat data
	$stat_area_total_array = [];
	$stat_row_hash = {};
	$sql = "select MMS_STATUS_CODE,RESULT,sum(FCAA_NUM) from TSMD_CDR_MM7_AO_FCAA" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by MMS_STATUS_CODE,RESULT";
		
	stat_num2($sql);
	
	for (@$stat_area_total_array)
	{
		my ($mmse_result,$statuscode,$num);
		
		$statuscode = $_->[0] ? $_->[0] : 0;
		$mmse_result = $_->[1] ? $_->[1] : 0;
		$num = $_->[2] ? $_->[2] : 0;

		my $sql = "insert into TSMD_CDR_MM7_AO_FCAA(START_TIME,AREA_CODE,RESULT,MMS_STATUS_CODE,"
				. "FCAA_NUM,RATIO_IN_TOTAL,AVG_RATIO_IN_TOTAL,NE_TYPE)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$provid,$mmse_result,$statuscode,"
				. "$num,0,0,$provnetwork)";
		
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
		
	}
	sleep(1);
	
	$sql = "select MMS_STATUS_CODE,sum(FCAA_NUM) from TSMD_CDR_MM7_AO_FCAA" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss')) and ne_type = 10000 "
		. " group by MMS_STATUS_CODE";

	stat_total($sql,"alltotal");
	stat_prov_rate($startdate,$provnetwork);
	
	$stat_row_hash = {};
	$sql = "select sum(FCAA_NUM) from TSMD_CDR_MM7_AO_FCAA" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))";

	stat_prov_total($sql,"avgtotal");
	stat_prov_avg_rate($startdate,$provnetwork);

	update_title($startdate);
	
	$dbh->disconnect;
	exit(0);
}
sub stat_num1
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
		$stat_area_total_array->[$i][3] = $row[3];		
		$i++;
	}
	$sth->finish;
}
sub stat_num2
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

sub stat_total
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
sub stat_prov_total
{
	my @row;
	my $sth;
	my ($sql,$col) = @_;

	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array){
		$stat_row_hash->{'prov'}->{$col} = $row[0];		
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
			$sql = "update TSMD_CDR_MM7_AO_FCAA set RATIO_IN_TOTAL = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areacode and MMS_STATUS_CODE= $gdrtype and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_MM7_AO_FCAA set RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areacode and MMS_STATUS_CODE= $gdrtype and NE_TYPE=$ne_type";

		}
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
}
sub stat_avg_rate
{
	my ($total,$sql);
	my $sth;
	my $startdate = shift ;
	my $ne_type = shift;
	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'resulttotal'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_CDR_MM7_AO_FCAA set AVG_RATIO_IN_TOTAL = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$key and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_MM7_AO_FCAA set AVG_RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$key and NE_TYPE=$ne_type";

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
			$sql = "update TSMD_CDR_MM7_AO_FCAA set RATIO_IN_TOTAL = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$provid and MMS_STATUS_CODE= $key and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_MM7_AO_FCAA set RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$provid and MMS_STATUS_CODE= $key and NE_TYPE=$ne_type";

		}
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$dbh->commit;
	}
}
sub stat_prov_avg_rate
{
	my ($total,$sql);
	my $sth;
	my $startdate = shift ;
	my $ne_type = shift;
	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'avgtotal'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_CDR_MM7_AO_FCAA set AVG_RATIO_IN_TOTAL = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$provid  and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_MM7_AO_FCAA set AVG_RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$provid and NE_TYPE=$ne_type";

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
	$sql = "update TSMD_CDR_MM7_AO_FCAA a set RESULT_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=180)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$dbh->commit;	
	
	$sql = "update TSMD_CDR_MM7_AO_FCAA a set MMS_STATUS_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b where a.MMS_STATUS_CODE>=b.BEGIN_ID and a.MMS_STATUS_CODE<=b.END_ID and b.title_id=100)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.MMS_STATUS_TITLE is null";
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$dbh->commit;	
}

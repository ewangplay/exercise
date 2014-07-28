############################################################################
#Desc: stat total success per cause
#Usage:stat_total_succ_per_cause.pl [start_date] [end_date]
#Create by xie jiayou  2008/12/19
#Modify by wang xiaohui 2009/5/31
############################################################################
use DBI;
use Time::Local;
use POSIX qw(strftime);
use strict;


my $DBN = "DBI:Oracle:gpnms4";	#data source
my $USR = "nmsadm";		#login user
my $PASSWD = "nms_8899";	#login password
my $PROVNETWORK = 10000; 	#province network type
my $AREANETWORK = 10001; 	#province network type
my $PROVID = 1751711880; 	#province id


my @driver_names;
my $dbh;
my $stat_row_hash;
my $stat_area_total_array;


main($ARGV[0], $ARGV[1]);

sub main
{
	my ($startdate, $enddate) = @_;

	@driver_names = DBI->available_drivers;

	$dbh = DBI->connect($DBN, $USR, $PASSWD, {PrintError => 0, RaiseError => 0, AutoCommit => 0}) 
		or die "Couldn't connect to database: " . DBI->errstr . "\n"; 

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
		die "starttime not be null";
	}
	else
	{
		my @date_array;
		$startdate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "starttime erroe ex:2009-01-01";
		$enddate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "endtim erroe ex:2009-01-01";
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
	$sql = "delete from TSMD_TOTAL_SUCC_PER_CAUSE" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;
 
	# stat and insert area data	
	$sql = "select area_code,cdrtype,statuscode,count(*) from TSMC_MMSC,TSMS_START_GT" 
		. " where (sendtime between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and substr(to_char(ReceiveAddress),3,9) = start_gt group by area_code,cdrtype,statuscode";
	stat_num($sql);
	
	for (@$stat_area_total_array)
	{
		my ($area_code,$cdrtype,$statuscode,$num);
		
		$area_code = $_->[0] ? $_->[0] : 999;
		$cdrtype = $_->[1] ? $_->[1] : 0;
		$statuscode = $_->[2] ? $_->[2] : 0;
		$num = $_->[3] ? $_->[3] : 0;

		my $sql = "insert into TSMD_TOTAL_SUCC_PER_CAUSE(START_TIME,AREA_CODE,MMS_STATUS_CODE,MMS_NUM,CDR_TYPE,"
				. "RATIO_IN_TOTAL,RATIO_IN_FAIL,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$area_code,$statuscode,$num,$cdrtype,"
				. "0,0,$AREANETWORK)";
		$dbh->do($sql);
		
	}
	$dbh->commit;

	sleep(2);
	
	$sql = "select area_code,sum(MMS_NUM) from TSMD_TOTAL_SUCC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by area_code";
	stat_area_total($sql,"total");

	$sql = "select area_code,sum(MMS_NUM) from TSMD_TOTAL_SUCC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and MMS_STATUS_CODE in ('3401','3402','6000','6001','6003','6100','6101','6103','4300','5303','6151','6300','6680','4100','4200','4300','4400','4401','4402','4403','4404','4406','4408','4441','4442','4443','4444','4448','6303','6311','6601','6602','6607','6615','6616')"
		. " group by area_code";
	stat_area_total($sql,"fail");

	stat_rate($startdate,$AREANETWORK);
		
	# insert province stat data
	$stat_area_total_array = [];
	$stat_row_hash = {};
	$sql = "select $PROVID,CDR_TYPE,MMS_STATUS_CODE,sum(MMS_NUM) from TSMD_TOTAL_SUCC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by CDR_TYPE,MMS_STATUS_CODE";
	stat_num($sql);
	
	for (@$stat_area_total_array)
	{
		my ($area_code,$cdrtype,$statuscode,$num);
		
		$area_code = $_->[0] ? $_->[0] : 0;
		$cdrtype = $_->[1] ? $_->[1] : 0;
		$statuscode = $_->[2] ? $_->[2] : 0;
		$num = $_->[3] ? $_->[3] : 0;

		my $sql = "insert into TSMD_TOTAL_SUCC_PER_CAUSE(START_TIME,AREA_CODE,MMS_STATUS_CODE,MMS_NUM,CDR_TYPE,"
				. "RATIO_IN_TOTAL,RATIO_IN_FAIL,NE_TYP)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$area_code,$statuscode,$num,$cdrtype,"
				. "0,0,$PROVNETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	sleep(2);
	
	$sql = "select $PROVID,sum(MMS_NUM) from TSMD_TOTAL_SUCC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and area_code=$PROVID and NE_TYP=$PROVNETWORK";
	stat_area_total($sql,"total");

	$sql = "select $PROVID,sum(MMS_NUM) from TSMD_TOTAL_SUCC_PER_CAUSE" 
		. " where (START_TIME between to_date('" . $startdate . " 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('" . $startdate . " 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and MMS_STATUS_CODE in ('3401','3402','6000','6001','6003','6100','6101','6103','4300','5303','6151','6300','6680','4100','4200','4300','4400','4401','4402','4403','4404','4406','4408','4441','4442','4443','4444','4448','6303','6311','6601','6602','6607','6615','6616')"
		. " and area_code=$PROVID and NE_TYP=$PROVNETWORK";
	stat_area_total($sql,"fail");

	stat_rate($startdate,$PROVNETWORK);

	update_title($startdate);
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
		$stat_area_total_array->[$i][3] = $row[3];		
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
	my ($num,$fail,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $areakey (keys %$stat_row_hash)
	{
		$num = $stat_row_hash->{$areakey}->{'total'};
		$fail = $stat_row_hash->{$areakey}->{'fail'};
		
		if($num == 0 )
		{
			$sql = "update TSMD_TOTAL_SUCC_PER_CAUSE set RATIO_IN_TOTAL = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areakey and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_TOTAL_SUCC_PER_CAUSE set RATIO_IN_TOTAL = (MMS_NUM / $num) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areakey and NE_TYP=$ne_type";

		}
		$dbh->do($sql);
		$dbh->commit;

		if($fail == 0 )
		{
			$sql = "update TSMD_TOTAL_SUCC_PER_CAUSE set RATIO_IN_FAIL = 0"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areakey and NE_TYP=$ne_type";
		}
		else
		{
			$sql = "update TSMD_TOTAL_SUCC_PER_CAUSE set RATIO_IN_FAIL = (MMS_NUM / $fail) * 1.0000"
    		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
			. " and AREA_CODE=$areakey and NE_TYP=$ne_type";
		}
		$dbh->do($sql);
		$dbh->commit;
	}
}

sub update_title
{
	my $startdate = shift ;
	my $sql;

#	$sql = "update TSMD_TOTAL_SUCC_PER_CAUSE a set MMS_STATUS_TITLE = (select description from tsms_mms_status_code b where a.MMS_STATUS_CODE=b.statuscode)"
#  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$sql = "update TSMD_TOTAL_SUCC_PER_CAUSE a set MMS_STATUS_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b where a.MMS_STATUS_CODE>=b.BEGIN_ID and a.MMS_STATUS_CODE<=b.END_ID and b.title_id=100)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";

	$dbh->do($sql);
	$dbh->commit;
}

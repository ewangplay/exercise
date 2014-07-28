############################################################################
#Desc: stat cdr gi mt fail per cause
#Usage:stat_cdr_gi_mt_fcaa.pl [start_date] [end_date]
#Create by wang xiaohui 2009/05/25
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
my $stat_area_total_array;


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
	$sql = "delete from TSMD_CDR_GI_MT_FCAA" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit; 
 
	# stat fcaa num grouped by area, mms result and mms status
	$sql = "select C.area_code,B.Mmse_result, A.statuscode, count(*)" 
       		. " from TSMC_MMSC A,TSMC_MMS_MO B, TSMS_START_GT C" 
		. " where (A.sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " and B.cdr_type=1 and remoteno=66"
		. " and mmse_result in (128,130,135,136,-1)"
		. " and A.statuscode=6001"
		. " and A.receivetime>=B.start_time"
		. " and A.receivetime<=B.start_time+ interval '20' second"
		. " and substr(to_char(A.sendAddress),3,13)=substr(to_char(B.calling),1,13)"
		. " and substr(to_char(B.calling),1,9) = C.start_gt"
		. " group by C.area_code, A.statuscode, B.Mmse_result";
	stat_num_by_area($sql);
	
	# insert fcaa num into db
	for (@$stat_area_total_array)
	{
		my ($area_code,$mmse_result,$statuscode,$num);
		
		$area_code = $_->[0] ? $_->[0] : 999;
		$mmse_result = $_->[1] ? $_->[1] : 0;
		$statuscode = $_->[2] ? $_->[2] : 0;
		$num = $_->[3] ? $_->[3] : 0;

		my $sql = "insert into TSMD_CDR_GI_MT_FCAA(START_TIME,AREA_CODE,RESULT,MMS_STATUS_CODE,"
				. "FCAA_NUM,RATIO_IN_TOTAL,AVG_RATIO_IN_TOTAL,NE_TYPE)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$area_code,$mmse_result," 
				. " $statuscode,$num,0,0,$AREANETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;
	
	# stat fcaa num by area and mms status
	$sql = "select MMS_STATUS_CODE,area_code,sum(FCAA_NUM) from TSMD_CDR_GI_MT_FCAA" 
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by MMS_STATUS_CODE,area_code";
	stat_total_by_area($sql,"area_total_by_status");
	stat_rate_by_area($startdate,$AREANETWORK);

	# stat fcaa num by area
	$stat_row_hash = {};
	$sql = "select area_code,sum(FCAA_NUM) from TSMD_CDR_GI_MT_FCAA" 
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by area_code";
	stat_total($sql,"area_total");
	stat_avg_rate_by_area($startdate,$AREANETWORK);
		
	# stat fcaa num by mms status and mms result
	$stat_area_total_array = [];
	$stat_row_hash = {};
	$sql = "select MMS_STATUS_CODE,RESULT,sum(FCAA_NUM) from TSMD_CDR_GI_MT_FCAA" 
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
		. " group by MMS_STATUS_CODE,RESULT";
	stat_num_by_prov($sql);
	
	# insert fcaa num into db
	for (@$stat_area_total_array)
	{
		my ($mmse_result,$statuscode,$num);
		
		$statuscode = $_->[0] ? $_->[0] : 0;
		$mmse_result = $_->[1] ? $_->[1] : 0;
		$num = $_->[2] ? $_->[2] : 0;

		my $sql = "insert into TSMD_CDR_GI_MT_FCAA(START_TIME,AREA_CODE,RESULT,MMS_STATUS_CODE,"
				. "FCAA_NUM,RATIO_IN_TOTAL,AVG_RATIO_IN_TOTAL,NE_TYPE)"
				. " values(to_date('$startdate','yyyy-mm-dd'),$PROVID,$mmse_result,$statuscode,"
				. "$num,0,0,$PROVNETWORK)";
		$dbh->do($sql);
	}
	$dbh->commit;

	sleep(1);
	
	# stat fcaa num by mms status
	$sql = "select MMS_STATUS_CODE,sum(FCAA_NUM) from TSMD_CDR_GI_MT_FCAA" 
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss')) and ne_type = 10000 "
		. " group by MMS_STATUS_CODE";
	stat_total($sql,"prov_total_by_status");
	stat_rate_by_prov($startdate,$PROVNETWORK);
	
	# stat total fcaa num
	$stat_row_hash = {};
	$sql = "select sum(FCAA_NUM) from TSMD_CDR_GI_MT_FCAA" 
		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	stat_total_by_prov($sql,"prov_total");
	stat_avg_rate_by_prov($startdate,$PROVNETWORK);

	# update mmse result title and mms status title
	update_title($startdate);
}

sub stat_num_by_area
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

sub stat_num_by_prov
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

sub stat_total_by_area
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

sub stat_total_by_prov
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

sub stat_rate_by_area
{
	my ($total,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $key (keys %$stat_row_hash)
	{
		my($gdrtype,$areacode)= split(/:/,$key);
		$total = $stat_row_hash->{$key}->{'area_total_by_status'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set RATIO_IN_TOTAL = 0"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$areacode and MMS_STATUS_CODE= $gdrtype and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$areacode and MMS_STATUS_CODE= $gdrtype and NE_TYPE=$ne_type";

		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub stat_avg_rate_by_area
{
	my ($total,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'area_total'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set AVG_RATIO_IN_TOTAL = 0"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$key and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set AVG_RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$key and NE_TYPE=$ne_type";

		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub stat_rate_by_prov
{
	my ($total,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'prov_total_by_status'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set RATIO_IN_TOTAL = 0"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$PROVID and MMS_STATUS_CODE= $key and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$PROVID and MMS_STATUS_CODE= $key and NE_TYPE=$ne_type";

		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub stat_avg_rate_by_prov
{
	my ($total,$sql);
	my $startdate = shift ;
	my $ne_type = shift;

	foreach my $key (keys %$stat_row_hash)
	{
		$total = $stat_row_hash->{$key}->{'prov_total'};
		
		if($total == 0 )
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set AVG_RATIO_IN_TOTAL = 0"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$PROVID  and NE_TYPE=$ne_type";
		}
		else
		{
			$sql = "update TSMD_CDR_GI_MT_FCAA set AVG_RATIO_IN_TOTAL = (FCAA_NUM / $total) * 1.0000"
    				. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
				. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
				. " and AREA_CODE=$PROVID and NE_TYPE=$ne_type";
		}
		$dbh->do($sql);
	}
	$dbh->commit;
}

sub update_title
{
	my $startdate = shift ;
	my $sql;

	$sql = "update TSMD_CDR_GI_MT_FCAA a" 
       		. " set RESULT_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b" 
	       	. " where a.RESULT>=b.BEGIN_ID and a.RESULT<=b.END_ID and b.title_id=180)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.RESULT_TITLE is null";
	$dbh->do($sql);
	$dbh->commit;	
	
	$sql = "update TSMD_CDR_GI_MT_FCAA a" 
       		. " set MMS_STATUS_TITLE = (select DESCRIPTION_CN from TSMS_MMS_STATIC_DATA b" 
	       	. " where a.MMS_STATUS_CODE>=b.BEGIN_ID and a.MMS_STATUS_CODE<=b.END_ID and b.title_id=100)"
  		. " where (START_TIME between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))"
  		. " and a.MMS_STATUS_TITLE is null";
	$dbh->do($sql);
	$dbh->commit;	
}

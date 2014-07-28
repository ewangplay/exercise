############################################################################
#Desc: stat AO per cause rate of each SP.
#Usage:stat_sp_per_cause.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/18
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
	$sql = "delete from TSMD_SP_PER_CAUSE" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	#stat ao per cause num
	$sql = "select srealvaspid, srealvasid, srealservicecode, statuscode, count(*) from TSMC_MMSC" 
		. " where statuscode not in ('0100','0400') and cdrtype='2'and SREALVASPID is not null" 
		. " and (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by srealvaspid, srealvasid, srealservicecode, statuscode order by count(*)";
	stat_num($sql);

	#stat ao total cause num
	my ($vaspid, $vasid, $service, $statuscode);
	my ($stat_vas_hash, $stat_service_hash, $stat_statuscode_hash);
	my $ao_total_cause_num = 0;

	foreach $vaspid (keys %$stat_row_hash)
	{
		next if $vaspid eq "";

		$stat_vas_hash = $stat_row_hash->{$vaspid};
		foreach $vasid (keys %$stat_vas_hash)
		{
			next if $vasid eq "";

			$stat_service_hash = $stat_vas_hash->{$vasid};
			foreach $service (keys %$stat_service_hash)
			{
				next if $service eq "";

				$stat_statuscode_hash = $stat_service_hash->{$service};
				foreach $statuscode (keys %$stat_statuscode_hash)
				{
					next if $statuscode eq "";

					my $ao_per_cause_num;

					$ao_per_cause_num = $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{$statuscode} 
							? $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{$statuscode} : 0;
					$ao_total_cause_num += $ao_per_cause_num;
				}
			}
		}
	}
	
	#stat ao per cause rate and insert into db
	foreach $vaspid (keys %$stat_row_hash)
	{
		next if $vaspid eq "";

		$stat_vas_hash = $stat_row_hash->{$vaspid};
		foreach $vasid (keys %$stat_vas_hash)
		{
			next if $vasid eq "";

			$stat_service_hash = $stat_vas_hash->{$vasid};
			foreach $service (keys %$stat_service_hash)
			{
				next if $service eq "";

				$stat_statuscode_hash = $stat_service_hash->{$service};
				foreach $statuscode (keys %$stat_statuscode_hash)
				{
					next if $statuscode eq "";

					my ($ao_per_cause_num, $ao_per_cause_rate);

					$ao_per_cause_num = $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{$statuscode} 
							? $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{$statuscode} : 0;

					if ($ao_total_cause_num == 0)
					{
						$ao_per_cause_rate = 0;
					}
					else
					{
						$ao_per_cause_rate = ($ao_per_cause_num / $ao_total_cause_num) * 1.0000;
					}

					$sql = "insert into TSMD_SP_PER_CAUSE(START_TIME, AREA_CODE, NE_TYPE," 
						. " VASP_ID, VAS_ID, STATUS_CODE, NUM, RATIO)" 
						. " values(to_date('$startdate', 'yyyy-mm-dd'), $PROVID, $PROVNETWORK," 
						. " $vaspid, $vasid, $statuscode, $ao_per_cause_num, $ao_per_cause_rate)";
					$dbh->do($sql);
				}
			}
		}
	}
	$dbh->commit();
}

sub stat_num
{
	my @row;
	my $sth;
	my $sql = shift;

	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array)
	{
		$stat_row_hash->{$row[0]}->{$row[1]}->{$row[2]}->{$row[3]} = $row[4];
	}
	$sth->finish();
}


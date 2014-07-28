############################################################################
#Desc: stat AO per cause rate of each SP.
#Usage:stat_sp_per_cause.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/18
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
	#my $startdate = strftime "%Y-%m-%d",localtime(time() - 86400) ;
	my $startdate = "2008-10-23";
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
	foreach (@date_array)
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

	#stat ao per cause num
	$sql = "select srealvaspid, srealvasid, srealservicecode, statuscode, count(*) from TSMC_MMSC" 
		. " where statuscode not in ('0100','0400') and cdrtype='2'and SREALVASPID is not null" 
		. " and (sendtime between to_date('$starttime 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$starttime 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
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
						. " values(to_date('$starttime', 'yyyy-mm-dd'), $provid, $provnetwork," 
						. " $vaspid, $vasid, $statuscode, $ao_per_cause_num, $ao_per_cause_rate)";
					$sth = $dbh->prepare($sql);
					$sth->execute();
					#$dbh->commit();
				}
			}
		}
	}
	$dbh->commit();

	$dbh->disconnect();
	exit(0);
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


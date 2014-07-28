############################################################################
#Desc: stat AO total success rate of each SP.
#Usage:stat_sp_overall.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/15
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

	#stat ao successful send num
	$sql = "select srealvaspid, srealvasid, srealservicecode,count(*) from TSMC_MMSC" 
		. " where statuscode in ('0100','0400') and cdrtype='2' and VaspID is not null" 
		. " and (sendtime between to_date('$starttime 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$starttime 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by srealvaspid, srealvasid, srealservicecode order by count(*)";
	stat_num($sql, 'succ_ao_send');

	#stat ao total send num
	$sql = "select srealvaspid, srealvasid, srealservicecode,count(*) from TSMC_MMSC" 
		. " where cdrtype='2' and VaspID is not null" 
		. " and (sendtime between to_date('$starttime 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$starttime 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by srealvaspid, srealvasid, srealservicecode order by count(*)";
	stat_num($sql, 'ao_send');

	#stat ao successful send rate and insert into db
	my ($vaspid, $vasid, $service);
	my ($stat_vas_hash, $stat_service_hash);

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

				my ($succ_ao_send, $ao_send, $ao_succ_rate);

				$succ_ao_send = $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{'succ_ao_send'} 
						? $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{'succ_ao_send'} : 0;
				$ao_send = $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{'ao_send'} 
						? $stat_row_hash->{$vaspid}->{$vasid}->{$service}->{'ao_send'} : 0;

				if ($ao_send == 0)
				{
					$ao_succ_rate = 0;
				}
				else
				{
					$ao_succ_rate = ($succ_ao_send/$ao_send) * 1.0000;
				}

				$sql = "insert into TSMD_SP_OVERALL(start_time, area_code, ne_type, vasp_id," 
					. " vas_id, service_code, succ_ao_send, ao_send, ratio_ao_send)" 
					. " values(to_date('$starttime', 'yyyy-mm-dd'), $provid, $provnetwork," 
					. " $vaspid, $vasid, $service, $succ_ao_send, $ao_send, $ao_succ_rate)";
				$sth = $dbh->prepare($sql);
				$sth->execute();
				#$dbh->commit();
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
	my ($sql, $col) = @_;

	$sth = $dbh->prepare($sql);
	$sth->execute();
	while(@row = $sth->fetchrow_array)
	{
		$stat_row_hash->{$row[0]}->{$row[1]}->{$row[2]}->{$col} = $row[3];
	}
	$sth->finish();
}


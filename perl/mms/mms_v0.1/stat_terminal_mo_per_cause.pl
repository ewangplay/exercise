############################################################################
#Desc: stat terminal mo per cause rate.
#Usage:stat_terminal_mo_per_cause.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/19
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

	# stat terminal mo per cause num
	$sql = "select  TerminalName,statuscode, count(*) from TSMC_MMSC" 
		. " where cdrtype='0' and statuscode not in ('0000','0300','1000') and terminalname is not null" 
		. " and (sendtime between to_date('$starttime 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$starttime 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by TerminalName,statuscode order by count(*)";
	stat_num($sql);

	# stat terminal mo total cause num
	my ($terminal, $statuscode);
	my $stat_statuscode_hash;
	my $mo_total_cause_num = 0;

	foreach $terminal (keys %$stat_row_hash)
	{
		$stat_statuscode_hash = $stat_row_hash->{$terminal};
		foreach $statuscode (keys %$stat_statuscode_hash)
		{
			next if $statuscode eq "";

			my $mo_per_cause_num;

			$mo_per_cause_num = $stat_row_hash->{$terminal}->{$statuscode} 
						? $stat_row_hash->{$terminal}->{$statuscode} : 0;

			$mo_total_cause_num += $mo_per_cause_num;
		}
	}

	# stat terminal mo per cause rate and insert data into db
	foreach $terminal (keys %$stat_row_hash)
	{
		$stat_statuscode_hash = $stat_row_hash->{$terminal};
		foreach $statuscode (keys %$stat_statuscode_hash)
		{
			next if $statuscode eq "";

			my ($mo_per_cause_num, $ratio_mo);

			$mo_per_cause_num = $stat_row_hash->{$terminal}->{$statuscode} 
						? $stat_row_hash->{$terminal}->{$statuscode} : 0;

			if ($mo_total_cause_num == 0)
			{
				$ratio_mo = 0;
			}
			else
			{
				$ratio_mo = ($mo_per_cause_num / $mo_total_cause_num) * 1.0000;
			}

			$sql = "insert into TSMD_TERMINAL_MO_PER_CAUSE(START_TIME, AREA_CODE, NE_TYPE," 
				. " TERMINAL_NAME, STATUS_CODE, NUM, RATIO_MO)" 
				. " values(to_date('$starttime', 'yyyy-mm-dd'), $provid, $provnetwork," 
				. " '$terminal', $statuscode, $mo_per_cause_num, $ratio_mo)";
			$sth = $dbh->prepare($sql);
			$sth->execute();
			#$dbh->commit();
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
		$stat_row_hash->{$row[0]}->{$row[1]} = $row[2];
	}
	$sth->finish();
}

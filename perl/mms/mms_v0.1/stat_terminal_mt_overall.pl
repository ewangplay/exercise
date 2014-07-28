############################################################################
#Desc: stat terminal mt total success rate.
#Usage:stat_terminal_mt_overall.pl [start_date] [end_date]
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

	#stat mt success num
	$sql = "select TerminalName,count(*) from TSMC_MMSC" 
		. " where cdrtype='3' and statuscode='1000'" 
		. " and (sendtime between to_date('$starttime 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$starttime 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by TerminalName order by count(*)";
	stat_num($sql, 'succ_num');

	#stat mt total num
	$sql = "select TerminalName,count(*) from TSMC_MMSC" 
		. " where cdrtype='3' and (sendtime between to_date('$starttime 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$starttime 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by TerminalName order by count(*)";
	stat_num($sql, 'total_num');

	#stat mt success rate and insert into db
	foreach my $terminal (keys %$stat_row_hash)
	{
		next if $terminal eq "";

		my ($succ_num, $total_num, $ratio_mt);

		$succ_num = $stat_row_hash->{$terminal}->{'succ_num'} 
				? $stat_row_hash->{$terminal}->{'succ_num'} : 0;
		$total_num = $stat_row_hash->{$terminal}->{'total_num'} 
				? $stat_row_hash->{$terminal}->{'total_num'} : 0;

		if ($total_num == 0)
		{
			$ratio_mt = 0;
		}
		else
		{
			$ratio_mt = ($succ_num / $total_num) * 1.0000;
		}

		$sql = "insert into TSMD_TERMINAL_MT_OVERALL(START_TIME, AREA_CODE, NE_TYPE," 
	       		. " TERMINAL_NAME, SUCC_NUM, TOTAL_NUM, RATIO_MT)" 
			. " values(to_date('$starttime', 'yyyy-mm-dd'), $provid, $provnetwork,"
			. " '$terminal', $succ_num, $total_num, $ratio_mt)";
		$sth = $dbh->prepare($sql);
		$sth->execute();
		#$dbh->commit();
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
		$stat_row_hash->{$row[0]}->{$col} = $row[1];
	}
	$sth->finish();
}


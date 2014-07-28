############################################################################
#Desc: stat terminal mt per cause rate.
#Usage:stat_terminal_mt_per_cause.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/19
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
	$sql = "delete from TSMD_TERMINAL_MT_PER_CAUSE" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	# stat terminal mt per cause num
	$sql = "Select  TerminalName,statuscode, count(*) from TSMC_MMSC" 
		. " where cdrtype='3' and statuscode not in ('0000','0300','1000') and terminalname is not null" 
		. " and (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by TerminalName,statuscode order by count(*)";
	stat_num($sql);

	# stat terminal mt total cause num
	my ($terminal, $statuscode);
	my $stat_statuscode_hash;
	my $mt_total_cause_num = 0;

	foreach $terminal (keys %$stat_row_hash)
	{
		$stat_statuscode_hash = $stat_row_hash->{$terminal};
		foreach $statuscode (keys %$stat_statuscode_hash)
		{
			next if $statuscode eq "";

			my $mt_per_cause_num;

			$mt_per_cause_num = $stat_row_hash->{$terminal}->{$statuscode} 
						? $stat_row_hash->{$terminal}->{$statuscode} : 0;

			$mt_total_cause_num += $mt_per_cause_num;
		}
	}

	# stat terminal mt per cause rate and insert data into db
	foreach $terminal (keys %$stat_row_hash)
	{
		$stat_statuscode_hash = $stat_row_hash->{$terminal};
		foreach $statuscode (keys %$stat_statuscode_hash)
		{
			next if $statuscode eq "";

			my ($mt_per_cause_num, $ratio_mt);

			$mt_per_cause_num = $stat_row_hash->{$terminal}->{$statuscode} 
						? $stat_row_hash->{$terminal}->{$statuscode} : 0;

			if ($mt_total_cause_num == 0)
			{
				$ratio_mt = 0;
			}
			else
			{
				$ratio_mt = ($mt_per_cause_num / $mt_total_cause_num) * 1.0000;
			}

			$sql = "insert into TSMD_TERMINAL_MT_PER_CAUSE(START_TIME, AREA_CODE, NE_TYPE," 
				. " TERMINAL_NAME, STATUS_CODE, NUM, RATIO_MT)" 
				. " values(to_date('$startdate', 'yyyy-mm-dd'), $PROVID, $PROVNETWORK," 
				. " '$terminal', $statuscode, $mt_per_cause_num, $ratio_mt)";
			$dbh->do($sql);
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
		$stat_row_hash->{$row[0]}->{$row[1]} = $row[2];
	}
	$sth->finish();
}


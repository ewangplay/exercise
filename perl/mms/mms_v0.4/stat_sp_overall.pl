############################################################################
#Desc: stat AO total success rate of each SP.
#Usage:stat_sp_overall.pl [start_date] [end_date]
#Create by wang xiaohui  2009/5/15
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
my $LOG_CONFIG = "../log/mylog.conf";	#log output config


my @driver_names;
my $dbh;
my $stat_row_hash;


main($ARGV[0], $ARGV[1]);

sub main
{
	my ($startdate, $enddate) = @_;

	# Initialize the logger object with config file
	Log::Log4perl->init($LOG_CONFIG);

	# Get logger object handler
	my $logger = Log::Log4perl->get_logger('main');

	$logger->info("Connecting to database $DBN with user $USR ...");

	# Connect to database
	@driver_names = DBIx::Log4perl->available_drivers;
	$dbh = DBIx::Log4perl->connect($DBN, $USR, $PASSWD, {PrintError => 0, RaiseError => 0, AutoCommit => 0}) 
		or die "Couldn't connect to database: " . DBIx::Log4perl->errstr . "\n"; 

	$logger->info("Connect database $DBN success!");

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
		die "startdate not be null";
	}
	else
	{
		my @date_array;
		$startdate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/  || die "startdate erroe ex:2009-01-01";
		$enddate =~ /20\d{2}-[01]\d{1}-[03]\d{1}/ || die "endtim erroe ex:2009-01-01";
		@date_array = getdatearry($startdate,$enddate);
		foreach (@date_array)
		{
			daily_dispose($_);
		}
	}

	$logger->info("Disconnecting from database $DBN...");

	$dbh->disconnect();
	
	$logger->info("Disconnect database success!");

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
	
	my $logger = Log::Log4perl->get_logger('main');

	$logger->info("Deleting outdated data at $startdate from database...");
					
	# delete the old data in this date section
	$sql = "delete from TSMD_SP_OVERALL" 
	 	. " where (start_time between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
	 	. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))";
	$dbh->do($sql);
	$dbh->commit;

	$logger->info("Delete outdated data success!");
	 
	$logger->info("Inserting new data at $startdate into database...");

	#stat ao successful send num
	$sql = "select srealvaspid, srealvasid, srealservicecode,count(*) from TSMC_MMSC" 
		. " where statuscode in ('0100','0400') and cdrtype='2' and VaspID is not null" 
		. " and (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
		. " group by srealvaspid, srealvasid, srealservicecode order by count(*)";
	stat_num($sql, 'succ_ao_send');

	#stat ao total send num
	$sql = "select srealvaspid, srealvasid, srealservicecode,count(*) from TSMC_MMSC" 
		. " where cdrtype='2' and VaspID is not null" 
		. " and (sendtime between to_date('$startdate 00:00:00','yyyy-mm-dd hh24:mi:ss')" 
		. " and to_date('$startdate 23:59:59','yyyy-mm-dd hh24:mi:ss'))" 
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
					. " values(to_date('$startdate', 'yyyy-mm-dd'), $PROVID, $PROVNETWORK," 
					. " $vaspid, $vasid, $service, $succ_ao_send, $ao_send, $ao_succ_rate)";
				$dbh->do($sql);
			}
		}
	}
	$dbh->commit();

	$logger->info("Insert new data success!");
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


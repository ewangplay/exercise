use strict;
use Net::FTP;

my $LOCAL_DIR = 'F:\ftp_root\tsmd';
my $REMOTE_DIR = '/home/oracle/wxh/MMS';
my $HOST = '10.0.2.138';
my $USER = 'oracle';
my $PASSWD = 'oracle';

my $ftp;
my $files;

$ftp = Net::FTP->new($HOST) || die "can't connect to ftp server $!\n";
$ftp->login($USER, $PASSWD);
$ftp->cwd($REMOTE_DIR);

$files = $ftp->ls;
for my $file (@$files)
{
	if($file =~ /^\w+.pl$/)
	{
		$ftp->get($file, "$LOCAL_DIR\\$file") || die "Get files failed", $ftp->message;
	}
}

$ftp->quit();

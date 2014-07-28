use strict;
use Mail::POP3Client;
use MIME::Parser;
use MIME::Entity;
use IO::File;
use Time::HiRes qw(gettimeofday tv_interval);

my $start_time = [gettimeofday];

my $pop = new Mail::POP3Client( USER     => "wangxiaohui",
			   PASSWORD => "wxhljh#",
			   HOST     => "boco.com.cn" );
my $parser = MIME::Parser->new;
my $fh = IO::File->new;

for( my $i = 1; $i <= $pop->Count(); $i++ ) {
	my $file = "f:\\google_upload\\msg" . "$i.txt";
	$fh->open($file, 'w');
	$parser->decode_headers(1);
	$parser->decode_bodies(1);
	$pop->HeadAndBodyToFile($fh, $i);
	$fh->close;
}

$pop->Close();

my $interval = tv_interval($start_time, [gettimeofday]);
print "it takes the time: $interval seconds\n";

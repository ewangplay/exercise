use strict;
use Mail::POP3Client;
use MIME::Parser;
use MIME::Entity;
use Time::HiRes qw(gettimeofday tv_interval);

my $start_time = [gettimeofday];

my $pop = new Mail::POP3Client( USER     => "wangxiaohui",
			   PASSWORD => "wxhljh#",
			   HOST     => "boco.com.cn" );
my $parser = MIME::Parser->new;

for( my $i = 1; $i <= $pop->Count(); $i++ ) {
	my $headandbody = $pop->HeadAndBody($i);
	my $entity = $parser->parse_data($headandbody);

	$parser->decode_headers(1);
	print "From = ", $entity->head->get('From'), "\n";
	print "To = ", $entity->head->get('To'), "\n";
	print "CC = ", $entity->head->get('Cc'), "\n";
	print "Subject = ", $entity->head->get('Subject'), "\n";
	print "MIME type = ", $entity->mime_type, "\n";
	print "Parts = ", scalar $entity->parts, "\n";
	my $part_num = scalar $entity->parts;
	for my $part ($entity->parts) {
		print "\t", $part->mime_type, "\t", $part->bodyhandle, "\n";
	}
}

$pop->Close();

my $interval = tv_interval($start_time, [gettimeofday]);
print "it takes the time: $interval seconds\n";

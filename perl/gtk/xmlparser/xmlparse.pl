use strict;
use XML::Simple;
use encoding 'utf8';

my $PATH = 'http://api.follow5.com/api/statuses/public_timeline.xml';
my $CMD = 'curl';
my $API_KEY = '84010F88F2EA60D8';

my $xml = new XML::Simple;

my $xml_string = `$CMD $PATH?api_key=$API_KEY`;
my $data = $xml->XMLin($xml_string);

# print Dumper($data);

my $username;
my $created_time;
my $share_object;
my $share_type;
my $share_content;
for my $key1 (keys %$data) {
	my $status = $data->{$key1};
	for my $key2 (keys %$status) {
		my $shares = $status->{$key2};
		for my $key3 (keys %$shares) {
			if ($key3 eq 'user') {
				my $user = $shares->{$key3};
				for my $key4 (keys %$user) {	
					if ($key4 eq 'name') {
						$username = $user->{$key4};
					}
				}
			}
			if ($key3 eq 'created_at') {
				$created_time = $shares->{$key3};
			}
			if ($key3 eq 'receiver') {
				$share_object = $shares->{$key3};
			}
			if ($key3 eq 'source') {
				$share_type = $shares->{$key3};
			}
			if ($key3 eq 'text') {
				$share_content = $shares->{$key3};
			}
		}
		print "$username 在 $created_time 通过 $share_type 分享给 $share_object\n";
		print "$share_content\n\n";
	}
}



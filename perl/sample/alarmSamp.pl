use strict;

my $count = 0;

$SIG{ALRM} = sub {die "time out\n";};
alarm 10;
while (1) {
	print "$count\n";
	$count++;
	if($count == 4) {
		last;
	}
	sleep 2;
}
alarm 0;
print "ok!\n";


use strict;
use threads;
use threads::shared;

my $var1 : shared = 0;

my $thr = threads->create(\&callback);
$thr->join;

print "$var1\n";

sub callback {
	$var1 = 2;
}

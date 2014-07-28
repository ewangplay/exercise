use strict;
use threads;
use threads::shared;

use MyClass;

my $myclass : shared = new MyClass;

my $thr = threads->create(\&callback);
$thr->join;

print $myclass->name;

sub callback {
	$myclass->name('Mary');
}


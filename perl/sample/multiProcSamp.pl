use strict;

my $child_id = fork();

if ($child_id) {
	sleep 2;
	print "I am parent, I create a child.\n";
	# exit 0;
}
else {
	print "Hello, I am child.\n";
}

print "Child and Parent can reach here!\n";
exit 1;

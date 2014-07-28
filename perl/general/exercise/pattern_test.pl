#!/usr/bin/perl -w

while(<>) {
	chomp;
	if(/(\w+a\b)/g) {
		do {
			print "|$`<$&>$'|\n";
			print "\$1 contains $1\n";
		} while(/(\w+a\b)/g);
	}
	else {
		print "no match!\n";
	}
}


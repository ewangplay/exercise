#!/usr/bin/perl -w
use strict;

my $key1 = shift(@ARGV);
my $key2 = shift(@ARGV);
my $file = shift(@ARGV);
my $line = "";
my $count = 0;

open(MYFILE, $file) || die("$!");

while($line = <MYFILE>) {
	$count++;
	chomp($line);
	if($line =~ /$key1.*$key2|$key2.*$key1/) {
		print "[$count]$line\n";
	}
}

close(MYFILE);

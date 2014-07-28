#/usr/bin/perl -w
use strict;

my %word_stat = ();
my $word = "";
my $num = 0;

while(<>) {
	chomp;
	foreach $word (split(/[ \t]/, $_)) {
		$word_stat{$word}++;
	}
}

while(($word, $num) = each(%word_stat)) {
	print "$word\t\t$num\n";
}


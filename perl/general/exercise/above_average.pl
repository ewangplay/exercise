#!/usr/bin/perl -w
use strict;

my @numbers = <STDIN>;
chomp(@numbers);
print "@numbers\n";

my @above = &above_average(@numbers);
print "@above\n";

sub above_average {	
	my @num = @_;
	my $average = &average(@num);
	my @above_average = ();
	my $num = 0;
	foreach $num (@num) {
		if($num >$average) {
			push(@above_average, $num);
		}
	}
	return @above_average;
}

sub average {
	my @nums = @_;
	my $sum = 0;
	my $num = 0;
	foreach $num (@nums) {
		$sum += $num;
	}
	return $sum/@nums;
}

#!/usr/bin/perl -w

$input = $ARGV[0];

$line = "";

open(INPUT_FILE, $input) || die("error!");

while($line = <INPUT_FILE>)
{
	chomp($line);
	$line =~ s/\d$//g;
	# print($line."\n") if(length($line) <= 3);
	print($line."\n") if(length($line) <= 4);
}

close(INPUT_FILE);

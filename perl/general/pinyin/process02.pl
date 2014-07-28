#!/usr/bin/perl -w

$input = $ARGV[0];

$line = "";
%pinyin = ();

open(INPUT_FILE, $input) || die("error!");

while($line = <INPUT_FILE>)
{
	chomp($line);
	$pinyin{"$line"} = "";
}

foreach $key (keys(%pinyin))
{
	print $key."\n";
}

close(INPUT_FILE);


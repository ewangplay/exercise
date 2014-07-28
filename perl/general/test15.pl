#!/usr/bin/perl

$file1 = $ARGV[0];
$file2 = $ARGV[1];

open(FILE1, $file1) || die("file error!");
open(FILE2, $file2) || die("file error!");

while($line1 = <FILE1>)
{
	$line2 = <FILE2>;
	if($line1 ne $line2)
	{
		print "not match!\n";
		last;
	}
}

close(FILE1);
close(FILE2);


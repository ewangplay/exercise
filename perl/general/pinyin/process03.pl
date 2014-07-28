#!/usr/bin/perl -w

$file1 = $ARGV[0];
$file2 = $ARGV[1];

$line1 = "";
$line2 = "";

open(FILE1, $file1) && open(FILE2, $file2) || die("error!");

while($line1 = <FILE1>)
{
	chomp($line1);
	seek(FILE2, 0, 0);
	while($line2 = <FILE2>)
	{
		chomp($line2);
		print "$line1---$line2\n";
	}
}

close(FILE1);
close(FILE2);

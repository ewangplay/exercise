#!/usr/bin/perl

$filename = $ARGV[0];
$logfile = $ARGV[1];

open(MYFILE, $filename) || die("error!");
open(LOGFILE, ">".$logfile) || die("error!");

binmode(MYFILE);
binmode(LOGFILE);

while($line = <MYFILE>)
{
	print LOGFILE ($line);
	chop($line);
	chop($line);
	print length($line)."\n";
}	

close(MYFILE);
close(LOGFILE);


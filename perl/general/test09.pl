#!/usr/bin/perl

unless(open(MYFILE, ">log.txt"))
{
	die("Can't open the log file\n");
}

while($line = <>)
{
	print(length($line), ": ");
	print($line);
	print MYFILE ($line);
}

close(MYFILE);


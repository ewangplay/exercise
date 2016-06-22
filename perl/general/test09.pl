#!/usr/bin/perl

unless(open(MYFILE, ">log.txt"))
{
	die("Can't open the log file\n");
}

while($line = <>)
{
    chomp($line);

    if($line eq "exit") 
    {
        last;
    }

	print(length($line), ": ");
	print($line, "\n");
	print MYFILE ($line, "\n");
}

close(MYFILE);


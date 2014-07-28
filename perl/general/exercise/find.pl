#!/usr/bin/perl -w
use strict;

if(@ARGV < 2)
{
	die("Usage: Find.pl [options] \"string\" filename\n");
}

my $file = "";
my $search_string = "";
my $line = "";
my $count = 0;
my $match_count = 0;
my $caseflag = 0;
my $numflag = 0;
my $result = "";

$file = pop(@ARGV);
$search_string = pop(@ARGV);

if(grep(/-i/, @ARGV))
{
	$caseflag = 1;
}

if(grep(/-n/, @ARGV))
{
	$numflag = 1;
}

open(FIND_FILE, $file) || die("error!");

while($line = <FIND_FILE>)
{
	$count++;
	chomp($line);
	if($caseflag)
	{
		$result = ($line =~ /$search_string/gi);
	}
	else
	{	
		$result = ($line =~ /$search_string/g);
	}
	if($result)
	{
		if($numflag)
		{
			print "[$count]";
		}
		$match_count++;
		print $line."\n";
	}
}

if(grep(/-c/, @ARGV))
{
	print "--------Total match lines:[$match_count]--------\n";
}

close(FIND_FILE);


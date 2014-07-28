#!/usr/bin/perl

$string = "bacadaeaFAgaHA123";

while($string =~ /\wa/gi)
{
	$match = $&;
	print($match, "\n");
}


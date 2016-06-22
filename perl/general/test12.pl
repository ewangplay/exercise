#!/usr/bin/perl

$string = "abcdef123ghifed123DEF";

print($string, "\n");

$string =~ s/([\d]+)/$1\.456/g;
print($string, "\n");

$string =~ tr/def/wxh/;
print($string, "\n");


#!/usr/bin/perl -w

$^I = ".bak";

while(<>) {
	s/wilma/wxh/g;
	print;
}


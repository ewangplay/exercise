#!/usr/bin/perl

$str1 = "hello";
$str2 = "world";

if($str1 eq str2)
{
	print($str1, " is equal to ", $str2, "\n");
}
else
{
	print($str1, " is not equal to ", $str2, "\n");
}

$result = $str1 cmp $str2;
if($result > 0)
{
	print("greater than\n");
}
elsif($result < 0)
{
	print("less than\n");
}
else
{
	print("equal to\n");
}


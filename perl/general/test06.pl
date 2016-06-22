#!/usr/bin/perl

$str1 = "hello";
$str2 = "world!";

$str3 = $str1.$str2;
print($str3, "\n");

$str3 .= " I am a boy.\n";
print($str3, "\n");

$str3 = $str3 x 5;
print($str3);



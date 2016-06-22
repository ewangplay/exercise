#!/usr/bin/perl

print("Please intput the first num:");
$num1 = <STDIN>;
print("Please input the second num:");
$num2 = <STDIN>;

$result = $num1 <=> $num2;

print("The max number is:");
if($result > 0)
{
	print($num1);
}
elsif($result < 0)
{
	print($num2)
}
else
{
	print($num2);
}


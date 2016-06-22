#!/usr/bin/perl

BEGIN
{
	print("hello, welcome to perl world!\n");
}

AUTOLOAD
{
	print("sub $AUTOLOAD is not found.\n");
}

END
{
	print("Bye-bye!\n");
}

print "Please input the first number:";
$num1 = <STDIN>;
print "Please input the second number:";
$num2 = <STDIN>;

$result = max($num1, $num2);
print("max number of input is:", $result, "\n");

$result = min($num1, $num2);

sub max
{
	my($num1, $num2) = @_;
	if($num1 > $num2)
	{
		return $num1;
	}
	else
	{
		return $num2;
	}
}


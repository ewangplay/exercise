#!/usr/bin/perl

@array = ("This", "is", "a", "example");

print(@array, "\n");
print("@array\n");
for($index = 0; $index < @array; $index++)
{
	print($array[$index], " ");
}


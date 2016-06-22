#!/usr/bin/perl

@arr1 = ("this", "is", "a", "example");
print("@arr1\n");
@arr2 = sort(@arr1);
print("@arr2\n");
@arr2 = reverse(@arr1);
print("@arr2\n");
@arr2 = reverse sort(@arr1);
print("@arr2\n");
chop(@arr1);
print("@arr1\n");

$result = join(" ", "This", "is", "a", "exemple");
print($result, "\n");
@arr3 = split(/ /, $result);
print("@arr3\n");


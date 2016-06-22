#!usr/bin/perl -w

$string = "hello world!";
@array = (1, 3, "Tom", "Marry");
%hash = ("apple" => 1, "Banana" => 2, "peach" =>3);

$pointer1 = \$string;
$pointer2 = \@array;
$pointer3 = \%hash;

print "The address of \$string is ".$pointer1."\n";
print "The address of \@array is ".$pointer2."\n";
print "The address of %hash is ".$pointer3."\n";

print $$pointer1."\n";

for($index = 0; $index < @$pointer2; $index++)
{
	print $$pointer2[$index]."\n";
}

foreach $key (sort keys(%$pointer3))
{
	print $$pointer3{$key}."\n";
}



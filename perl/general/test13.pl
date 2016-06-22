#!/usr/bin/perl

%age = ();

$age{Tom} = 23;
$age{Merry} = 22;
$age{Harry} = 24;

foreach $person (sort keys(%age))
{
	$value = $age{$person};
	print $person, ":";
	print $value, "\n";
}

while(($person, $value) = each(%age))
{
	print $person.":".$value."\n";
}

delete($age{Tom});

while(($person, $value) = each(%age))
{
	print $person.":".$value."\n";
}


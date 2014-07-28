use strict;

my %data = ('name', 'wangxiaohi',
	'password', 'wxhljh');

my $refData = \%data;

my @arr = %$refData;

print "@arr\n";

my $num = %data;

print "$num\n";

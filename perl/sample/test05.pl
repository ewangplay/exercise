use strict;
use Data::Dumper;

my @keys = ('a', 'b', 'c');
my @values = (1, 2, 3);

my $data;

for my $name ('Tom', 'Mary') {
	@{$data->{$name}}{@keys} = @values;
}

print Dumper($data);


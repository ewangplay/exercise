package MyClass;

use strict;
use threads;
use threads::shared;

sub new {
	my $class = shift;
	my %this : shared = ();
	$this{'name'} = '';
	bless \%this, $class;
	return \%this;
}

sub name {
	my $this = shift;
	$this->{'name'} = shift if @_;
	return $this->{'name'};
}

1;

package Student;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(setName getName setAge getAge setMajor getMajor);

sub new {
	my $type = shift;
	my %param = @_;
	my $this = {};
	$this->{"name"} = $param{"name"};
	$this->{"age"} = $param{"age"};
	$this->{"major"} = $param{"major"};
	bless $this, $type;
	return $this;
}

sub setName {
	my ($this, $name) = @_;
	$this->{"name"} = $name;
	print "set name to $name\n";
}

sub getName {
	my $this = shift;
	return $this->{"name"};
}

sub setAge {
	my ($this, $age) = @_;
	$this->{"age"} = $age;
	print "set age to $age\n";
}

sub getAge {
	my $this = shift;
	return $this->{"age"};
}

sub setMajor {
	my ($this, $major) = @_;
	$this->{"major"} = $major;
	print "set major to $major\n";
}

sub getMajor {
	my $this = shift;
	return $this->{"major"};
}

1;	#terminate the package with 1

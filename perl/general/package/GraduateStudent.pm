package GraduateStudent;
require Exporter;
require Student;
@ISA = qw(Exporter Student);
@EXPORT = qw(setDoctor getDoctor);

sub new {
	my $type = shift;
	my %param = @_;
	my $this = Student->new("name"=>$param{"name"}, "age"=>$param{"age"}, "major"=>$param{"major"});
	$this->{"doctor"} = $param{"doctor"};
	bless $this, $type;
	return $this;
}

sub setDoctor {
	my ($this, $doctor) = @_;
	$this->{"doctor"} = $doctor;
	print "Set doctor to ".$this->{"doctor"}."\n";
}

sub getDoctor {
	my $this = shift;
	return $this->{"doctor"};
}

1;	#terminate this package with 1

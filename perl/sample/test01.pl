use strict;

main();

sub main
{
	my $str = "hello, world!";
	print "$str\n";

	print "Please input the name:";
	my $name = <STDIN>;

	print "Please input the password:";
	my $password = <STDIN>;

	if (($name eq 'wang') and ($password eq 'wang'))
	{
		print "successfully login.\n";
	}
	else
	{
		print "failed to login.\n";
	}
	exit(0);
}


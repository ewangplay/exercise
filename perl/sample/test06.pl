use strict;
use Encode qw/encode decode/;
use FileHandle;

my $result_file = $ARGV[0];

my $fh = new FileHandle("$result_file") || die "Can not open $result_file\n";
while(my $line = <$fh>) {
	my $pattern = 'Ŀ���������';
	if ($line =~ /^\s*$pattern\s*=\s*(\S+)\s*$/) {
		print "$pattern = $1\n";
	}
}
close($fh);

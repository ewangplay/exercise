use strict;
use FileHandle;

my $testfile_r = "test_r.txt";
my $testfile_w = "test_w.txt";

main();

sub main {
	my $begin_time = time;
	for (my $i = 1; $i < 20; $i++) {
		gen_task($i);
	}
	my $end_time = time;
	my $use_time = $end_time - $begin_time;
	print "Use Time: $use_time\n";
}

sub gen_task {
	my $task_id = shift;

	#read data from file 
	my $fr = new FileHandle("$testfile_r") || die "Can't open file $testfile_r\n";
	sleep 1;
	my @lines = <$fr>;
	sleep 1;
	close($fr);

	# write data to file
	my $fw = new FileHandle(">>$testfile_w") || die "Can't write file $testfile_w\n";
	for my $line (@lines) {
		print $fw ("$task_id --- $line");
	}
	close($fw);
}

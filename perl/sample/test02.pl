use POSIX qw(strftime);

my $now_string = strftime "%Y-%m-%d %H-%M-%S", localtime;
print "$now_string\n"

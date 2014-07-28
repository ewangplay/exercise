use strict;
use HTTP::Date qw(time2str str2time time2iso time2isoz);   
    
my $stringGMT = 'Fri, 9 May 2003 12:20:03 +0800';   
my $time = str2time($stringGMT);
my $stringISO = time2iso($time);   
print "$stringISO\n";


use strict;
use HTTP::Date qw(time2str str2time time2iso time2isoz);   
    
my $stringGMT = '19-MAY-2009 14:12:02';   
my $time = str2time($stringGMT);
my $stringISO = time2iso($time);   
print "$stringISO\n";


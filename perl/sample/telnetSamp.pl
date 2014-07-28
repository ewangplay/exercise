use strict;
use Net::Telnet ();

my $HOST = '10.0.2.138';
my $USER = 'oracle';
my $PASSWD = 'oracle';

my $t;
my @lines;

$t = Net::Telnet->new;

$t->open($HOST);
$t->login($USER, $PASSWD);

@lines = $t->cmd("who");
print @lines;

$t->cmd("cd /home/oracle/wxh/MMS");
@lines = $t->cmd("ls -l");
print @lines;

$t->close();


use strict;
use Net::POP3;

print "Input Mail Server:";
my $mail_host = <STDIN>;

print "Input user name:";
my $user = <STDIN>;

print "Input password:";
my $passwd = <STDIN>;

my $conn = Net::POP3->new($mail_host) or die("Error: unable to connect.");

print "connect successfully!\n";

my $msgNum = $conn->login($user, $passwd) or die("Error: unable to login.");

print "login successfully!\n";

if($msgNum > 0) {
	print "Mailbox has $msgNum mails.\n";
} else {
	print "Mailbox is empty.\n";
}

$conn->quit();



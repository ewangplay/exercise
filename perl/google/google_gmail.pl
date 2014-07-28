use strict;
use Mail::Webmail::Gmail;
use Term::ReadPassword::Win32;

# print "Input your gmail account:";
# my $username = <STDIN>;
# my $password = read_password("Input your gmail password: ");

my $gmail = Mail::Webmail::Gmail->new(username=>'ewangplay@gmail.com', password=>'yalpgnawe#');

my $messages = $gmail->get_messages(label=>$Mail::Webmail::Gmail::FOLDERS{'INBOX'});

foreach (@{$messages}) {
	if ($_->{'new'} ) {
		print "Subject: " . $_->{'subject'} . "/ Blurb: " . $_->{'blurb'} . "\n";
	}
}


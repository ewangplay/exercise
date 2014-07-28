use strict;
use WWW::Google::Notebook;
use Term::ReadPassword::Win32;

# print "Input your google account: ";
# my $username = <STDIN>;
# my $password = read_password("Input your google password: ");

my $google = WWW::Google::Notebook->new(
  username => 'ewangplay@gmail.com',
  password => 'yalpgnawe#',
);

$google->login;

my $notebooks = $google->notebooks(); # WWW::Google::Notebook::Notebook object as arrayref
for my $notebook (@$notebooks) {
  print $notebook->title, "\n";
  my $notes = $notebook->notes(); # WWW::Google::Notebook::Note object as arrayref
  for my $note (@$notes) {
      print $note->content, "\n";
  }
}



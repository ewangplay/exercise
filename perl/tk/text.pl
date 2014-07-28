use strict;
use Tk;

my $window = new MainWindow;

$window->geometry("200x100");
$window->title("Text test.");

$window->Text(-background=>'blue', -foreground=>'white')->pack(-side=>'left');

MainLoop;

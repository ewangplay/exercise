use strict;
use Tk;

my $window = new MainWindow;

$window->geometry("200x100");
$window->title("Entry test.");

$window->Entry(-background=>'blue', -foreground=>'white')->pack(-side=>'top');

MainLoop;

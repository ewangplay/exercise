use strict;
use Tk;

my $window = new MainWindow;

$window->geometry("200x100");
$window->title("Frame test.");

$window->Frame(-background=>'red')->pack(-ipadx=>50, -side=>'left', -fill=>'y');
$window->Frame(-background=>'green')->pack(-ipadx=>50, -side=>'right', -fill=>'y');

MainLoop;

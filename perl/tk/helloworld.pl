use strict;
use Tk;

my $window = new MainWindow;

$window->geometry("200x100");
$window->title("hello,world");

$window->Label(-text=>"hello,world!")->pack;
$window->Button(-text=>"Close", -command=>sub{exit})->pack;

MainLoop;

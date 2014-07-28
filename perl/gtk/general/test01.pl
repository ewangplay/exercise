use strict;
use Gtk2;
use Encode qw(decode);

Gtk2->init;

my $window = Gtk2::Window->new('toplevel');
$window->set_title('hello,world');
$window->set_position('center_always');
$window->set_size_request(300, 200);
$window->signal_connect('delete_event' => sub {Gtk2->main_quit;});

my $label = Gtk2::Label->new(decode('utf8', '你好!'));
$window->add($label);
$window->show_all();
Gtk2->main;


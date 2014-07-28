use strict;
use Gtk2 -init;
use Glib qw/TRUE FALSE/;

my $window;
my $vbox;
my $label;
my $angle = 0;

$window = Gtk2::Window->new('toplevel');
$window->set_title('label rotating demo');
$window->set_border_width(5);
$window->set_size_request(400, 400);
$window->signal_connect('delete_event', sub {Gtk2->main_quit});
$window->set_position('center_always');

$vbox = Gtk2::VBox->new();

$label = Gtk2::Label->new();
$label->set_markup('<span foreground="DarkRed" size="x-large"><b>Rotating Label</b></span>');
$vbox->pack_start($label, TRUE, TRUE, 2);

Glib::Timeout->add(200, \&rotate_label);

$window->add($vbox);
$window->show_all;
Gtk2->main;

sub rotate_label {
	$angle += 5;
	($angle == 360) && ($angle = 0);
	$label->set_angle($angle);
	return TRUE;
}


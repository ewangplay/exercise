use strict;
use Gtk2 -init;
use Glib qw/TRUE FALSE/;
use Gtk2::Gdk::Keysyms;

my $window;
my $label;

$window = Gtk2::Window->new('toplevel');
$window->set_title('key press demo');
$window->set_size_request(300, 200);
$window->signal_connect('delete_event', sub {Gtk2->main_quit});
$window->signal_connect('key_press_event', \&test_key_press);

$label = Gtk2::Label->new();

$window->add($label);
$window->set_position('center_always');
$window->show_all;
Gtk2->main;


sub test_key_press {
	my ($widget, $event) = @_;
	my $key_val = $event->keyval();

	for my $key (keys %Gtk2::Gdk::Keysyms) {
		if($key_val == $Gtk2::Gdk::Keysyms{$key}) {
			$label->set_text("You press $key key.");
			last;
		}
	}
	return FALSE;
}

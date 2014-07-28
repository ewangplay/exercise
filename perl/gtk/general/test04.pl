use strict;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use Encode;

my $window;
my $button;
my %count;

#create main window
$window = Gtk2::Window->new('toplevel');
$window->set_title('button event demo');
$window->set_size_request(300, 200);
$window->signal_connect('delete_event', sub {Gtk2->main_quit});

$button = Gtk2::Button->new();
$button->signal_connect('button_press_event', \&test_button_press, \%count);

$window->add($button);

#display the main window
$window->show_all;
Gtk2->main;

sub test_button_press {
	my ($widget, $event, $count_ref) = @_;
	my $button_num = $event->button();

	if(not exists $count_ref->{$button_num}) {
		$count_ref->{$button_num} = 0;
	}
	$count_ref->{$button_num}++;

	$widget->set_label("Button $button_num press $count_ref->{$button_num} times");

	return FALSE;
}



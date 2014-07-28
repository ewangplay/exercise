use strict;
use Gtk2 '-init';
use Glib qw(TRUE FALSE);

my $window = Gtk2::Window->new('toplevel');
$window->set_title('vbox demo');
$window->set_size_request(300, 500);
$window->signal_connect('delete_event' => sub{ Gtk2->main_quit });

my $vbox = Gtk2::VBox->new(FALSE, 5);

my $button = Gtk2::Button->new('button 1');
$button->signal_connect('clicked' => \&button1_callback);
$vbox->pack_start($button, FALSE, FALSE, 2);

$button = Gtk2::Button->new('button 2');
$button->signal_connect('clicked' => \&button2_callback);
$vbox->pack_start($button, FALSE, FALSE, 2);

$button = Gtk2::Button->new('Exit');
$button->signal_connect('clicked' => sub{ Gtk2->main_quit });
$vbox->pack_start($button, FALSE, FALSE, 2);

$window->add($vbox);
$window->show_all();
Gtk2->main;

sub button1_callback {
	print "click button 1\n";
}

sub button2_callback {
	print "click button 2\n";
}



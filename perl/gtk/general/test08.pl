use Gtk2 -init;
use Gtk2::TrayIcon;
use strict;

my $icon = Gtk2::TrayIcon->new('test');

my $eventbox = Gtk2::EventBox->new;
$eventbox->signal_connect('enter-notify-event' => sub { print "enter tray icon\n"; });
$eventbox->signal_connect('leave-notify-event' => sub { print "leave tray icon\n"; });
$eventbox->signal_connect('button-press-event' => sub { print "click tray icon\n"; });

my $image = Gtk2::Image->new_from_file('test.png');

$eventbox->add($image);

$icon->add($eventbox);

$icon->show_all;

Gtk2->main;


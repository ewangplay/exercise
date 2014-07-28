use Gtk2 -init;
use strict;

my $icon = Gtk2::StatusIcon->new_from_file('test.png');
$icon->set_tooltip('test demo');

Gtk2->main;

use strict;
use Tkx;

my $mw = Tkx::widget->new(".");

$mw->new_label(-text => "User: ")->g_pack(-side => "left");
$mw->new_entry()->g_pack(-ipadx => 100);

$mw->new_label(-text => "Password: ")->g_pack(-side => "left");
$mw->new_entry()->g_pack(-ipadx => 100);

$mw->new_button(-text => "Submit", -command => sub { $mw->messageBox(-message => "submit", -type => "ok"); })->g_pack;
$mw->new_button(-text => "Exit", -command => sub { $mw->g_destroy; } )->g_pack;

Tkx::MainLoop();


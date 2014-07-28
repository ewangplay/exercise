use strict;
use Gtk2 '-init';
use Glib qw(TRUE FALSE);
use Encode;

my $window;
my $vbox;
my $table;
my $hbox;
my $label;
my $entry_user;
my $entry_passwd;
my $button;

#create main window
$window = Gtk2::Window->new('toplevel');
$window->set_title('login demo');
$window->set_size_request(300, 200);
$window->signal_connect('delete_event' => sub{ Gtk2->main_quit });

#create top vbox
$vbox = Gtk2::VBox->new(FALSE, 5);

#create table
$table = Gtk2::Table->new(3, 5);
$label = Gtk2::Label->new(decode('utf8', '用户名：'));
$table->attach_defaults($label, 0, 1, 0, 1);
$entry_user = Gtk2::Entry->new();
$table->attach_defaults($entry_user, 2, 5, 0, 1);
$label = Gtk2::Label->new(decode('utf8', '密码：'));
$table->attach_defaults($label, 0, 1, 2, 3);
$entry_passwd = Gtk2::Entry->new();
$table->attach_defaults($entry_passwd, 2, 5, 2, 3);

#pack the table into vbox
$vbox->pack_start($table, FALSE, FALSE, 10);

#create hbox 
$hbox = Gtk2::HBox->new(FALSE, 5);
$button = Gtk2::Button->new(decode('utf8', '清空'));
$button->signal_connect('clicked' => \&clear_content);
$hbox->pack_end($button, FALSE, FALSE, 15);
$button = Gtk2::Button->new(decode('utf8', '登录'));
$button->signal_connect('clicked' => \&login);
$hbox->pack_end($button, FALSE, FALSE, 15);

#pack the hbox into vbox
$vbox->pack_start($hbox, TRUE, FALSE, 10);

#add the vbox into window
$window->add($vbox);
$window->show_all();
Gtk2->main;

sub login {
	my $dialog;
	my $response;
	my $user = $entry_user->get_text();
	my $passwd = $entry_passwd->get_text();

	if ($user eq "" or $passwd eq "") {
		$dialog = Gtk2::MessageDialog->new($window,
			'destroy-with-parent',
			'error',
			'ok',
			"User and password can't be empty!");
		$response = $dialog->run;
		$dialog->destroy;
		return FALSE;
	}
	elsif(not($user eq "dahui")) {
		$dialog = Gtk2::MessageDialog->new($window,
			'destroy-with-parent',
			'error',
			'ok',
			"User error!");
		$response = $dialog->run;
		$dialog->destroy;
		return FALSE;
	}
	elsif(not($passwd eq "wxhljh")) {
		$dialog = Gtk2::MessageDialog->new($window,
			'destroy-with-parent',
			'error',
			'ok',
			"Password error!");
		$response = $dialog->run;
		$dialog->destroy;
		return FALSE;
	}

	$dialog = Gtk2::MessageDialog->new($window,
		'destroy-with-parent',
		'info',
		'ok',
		"Login successfully!");
	$response = $dialog->run;
	$dialog->destroy;
	return TRUE;
}

sub clear_content {
	$entry_user->set_text("");
	$entry_passwd->set_text("");
}


use strict;
use Tk;

my $window;

main();

sub main {
	$window = new MainWindow;

	$window->geometry("200x100");
	$window->title("Button test.");

	$window->Button(-text=>'hello,world', -command=>\&button1_click)->pack(-side=>'left');
	$window->Button(-text=>'Exit', -command=>\&button2_click)->pack(-side=>'right');

	MainLoop;
}

sub button1_click {
	$window->messageBox(-message=>'hello,world!', -type=>'ok');
}

sub button2_click {
	my $result = $window->messageBox(-message=>'Do you really exit?', -type=>'yesno', -icon=>'question');
	if($result eq 'Yes') {
		$window->messageBox(-message=>'bye-bye', -type=>'ok');
		exit;
	} else {
		$window->messageBox(-message=>'I do not think so.', -type=>'ok');
	}
}


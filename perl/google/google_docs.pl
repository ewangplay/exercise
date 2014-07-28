use strict;
use Tk;
use WWW::Google::Docs::Upload;

my $mw;
my $file;
my $entryFile;

$file = shift;

main();

sub main {
	$mw = MainWindow->new;
	$mw->geometry("500x100");
	$mw->title("Upload document to Google Docs");
	
	if ($file eq "") {
		$mw->messageBox(-message => "No specify upload file!", -type => "ok");
		exit;
	}

	my $topFrm = $mw->Frame()->pack(-ipadx => 400);
	my $bottomFrm = $mw->Frame()->pack(-ipadx => 60);

	$topFrm->Label(-text => "Be sure to upload: ")->pack(-side => "left");
	$entryFile = $topFrm->Entry(-text => "$file", -background => "white", -foreground => "black")->pack(-ipadx => 100);

	$bottomFrm->Button(-text=>"Upload", -command=>\&upload_doc)->pack(-side => "left");
	$bottomFrm->Button(-text=>"Cancel", -command=>sub{exit})->pack(-side => "right");

	MainLoop;
}

sub upload_doc {
	my $docs = WWW::Google::Docs::Upload->new(
	    email  => 'ewangplay@gmail.com',
	    passwd => 'yalpgnawe#'
	);
	my $alias = $entryFile->get();
	if ($file eq $alias) {
		$docs->upload($file);
	} else {
		$docs->upload($file, {name=>"$alias"});
	}	
	$mw->messageBox(-message=>"Successful to upload!", -type=>"ok");
	exit;
}


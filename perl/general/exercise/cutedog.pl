#!/usr/bin/perl -w

while(1) {
	print "login:";
	chomp($username = <STDIN>);
	if($username eq "root") {
		last;
	}
	else {
		warn "Error user name!\n";
	}
}

while(1) {
	print "password:";
	chomp($password = <STDIN>);
	if($password eq "123") {
		last;
	}
	else {
		warn "Error password!\n";
	}
}

@cmd_list = ("find", "type", "dir", "vim");
print "Welcome to cute dog system! Please input command.\n";
print "You can input \'help\' to list commands.\n";
while(1) {
	print ">>>";
	chomp($cmd = <STDIN>);
	if($cmd eq "help") {
		&print_cmd_list;
	}
	elsif($cmd eq "exit") {
		die("bye-bye!\n");
	}
	else {
		@cmds = split(/ /, $cmd);
		if(grep(/$cmds[0]/, @cmd_list)) {
			system(@cmds);
		}
		else {
			print "Error command.\n";
		}
	}
}

sub print_cmd_list {
	print "find\tFind string in sepecified file.\n";
	print "type\tDisplay the contents of the specified file.\n";
	print "dir\tDisplay the direcotries and files contained of specified directory.\n";
	print "vim\tRun the vi improve edior.\n";
	print "help\tList the available commands.\n";
	print "exit\tExit the cute dog system.\n";
}


use strict;

for(<*.pl>) {
	next if /auto_check|auto_exec/i;
	`perl $_`;
}


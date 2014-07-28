#include <stdio.h>
#include <unistd.h>
#include <term.h>

int main(int argc, char * argv[]) {
	initsrc();
	move(10, 10);
	printw("%s", "hello world!");
	sleep(2);
	endwin();

	return 0;
}

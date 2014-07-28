#include <iostream>
#include <list>
#include <algorithm>
#include "print.hpp"
using namespace std;

int main()
{
	list<int> col1;

	for(int i = 0; i < 9; ++i)
	{
		col1.push_back(i);
	}

	PRINT_ELEMENTS(col1, "set:");

	list<int>::iterator pos = col1.begin();
	cout << "first element: " << *pos << endl;

	advance(pos, 3);
	cout << "advance 3 step element: " << *pos << endl;

	advance(pos, -1);
	cout << "advance -1 step element: " << *pos << endl;

	return 0;
}


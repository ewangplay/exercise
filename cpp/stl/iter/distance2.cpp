//distance2.cpp
#include <iostream>
#include <list>
#include <algorithm>
#include "print.hpp"
using namespace std;

int main()
{
	list<int> col1;

	for(int i = -3; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	PRINT_ELEMENTS(col1, "list: ");

	list<int>::iterator pos = find(col1.begin(), col1.end(), 5);

	if(pos != col1.end())
	{
		cout << "distance from begin to " << *pos << " is " << distance(col1.begin(), pos) <<endl;
		cout << "distance from " << *pos << " to first is " << distance(pos, col1.begin()) << endl;
	}
	else
	{
		cout << "5 not found!" << endl;
	}
}


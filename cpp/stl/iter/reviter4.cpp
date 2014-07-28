//reviter4.cpp
#include <iostream>
#include <list>
#include <algorithm>
using namespace std;

int main()
{
	list<int> col1;

	//insert elements from 1 to 9
	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	//find the element with value 5
	list<int>::iterator pos = find(col1.begin(), col1.end(), 5);

	//print the element value
	cout << "pos: " << *pos << endl;

	//convert the pos to reverse iterator
	list<int>::reverse_iterator rpos(pos);

	//print the converted reverse iterator
	cout << "rpos: " << *rpos << endl;

	//convert reverse iterator back to normal iterator
	list<int>::iterator rrpos = rpos.base();

	//print the backed iterator value
	cout << "rrpos: " << *rrpos << endl;
}


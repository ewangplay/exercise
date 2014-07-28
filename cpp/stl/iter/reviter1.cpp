//reviter1.cpp
#include <iostream>
#include <list>
#include <algorithm>
using namespace std;

void print(int elem)
{
	cout << elem << ' ';
}

int main()
{
	list<int> col1;

	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	for_each(col1.begin(), col1.end(), print);
	cout << endl;

	for_each(col1.rbegin(), col1.rend(), print);
	cout << endl;
}

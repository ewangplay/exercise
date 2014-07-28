//removeif2.cpp
#include <iostream>
#include <list>
#include <algorithm>
#include "../print.hpp"
using namespace std;

class Mod
{
	public:
		Mod(int n): base(n) {}
		bool operator() (int elem) const
		{
			return !(elem % base);
		}

	private:
		int base;
};

int main()
{
	list<int> col1;

	//insert elements from 1 to 9
	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	PRINT_ELEMENTS(col1, "col1: ");

	//remove third element
	list<int>::iterator pos = remove_if(col1.begin(), col1.end(), Mod(3));
	col1.erase(pos, col1.end());

	PRINT_ELEMENTS(col1, "col1 processed: ");
}


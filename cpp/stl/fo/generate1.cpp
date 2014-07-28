//generate1.cpp
#include <iostream>
#include <list>
#include <algorithm>
#include "../print.hpp"
using namespace std;

class IntSequence
{
	public:
		//constructor
		IntSequence(int val): m_basevalue(val) {}

		//fuction call
		int operator() ()
		{
			return m_basevalue++;
		}

	private:
		int m_basevalue;
};

int main()
{
	//define a list container
	list<int> col1;

	//insert 1 to 9 into the col1
	generate_n(back_inserter(col1), 9, IntSequence(1));

	//print the col1
	PRINT_ELEMENTS(col1, "col1: ");

	//replase the elements from second to the end before
	generate(++col1.begin(), --col1.end(), IntSequence(42));

	//print the col1
	PRINT_ELEMENTS(col1, "col1: ");
}


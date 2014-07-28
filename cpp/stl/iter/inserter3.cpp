//inserter3.cpp
#include <iostream>
#include <set>
#include <list>
#include <algorithm>
#include "../print.hpp"
using namespace std;

int main()
{
	//define a set container col1
	set<int> col1;

	//create a general inserter for col1
	// - inconvenient way
	insert_iterator<set<int> > iter(col1, col1.begin());

	//insert some elements with inserter
	*iter = 3;
	iter++;
	*iter = 2;
	iter++;
	*iter = 1;
	iter ++;

	//print all elements of col1
	PRINT_ELEMENTS(col1, "col1: ");

	//create general inserter and insert elements
	// - convenient way
	inserter(col1, col1.begin()) = 44;
	inserter(col1, col1.end()) = 55;

	//print all elements of col1
	PRINT_ELEMENTS(col1, "col1: ");

	//define a list container col2
	list<int> col2;

	//copy all elements of col1 to col2 with inserter
	copy(col1.begin(), col1.end(), inserter(col2, col2.begin()));

	//print all elements of col2
	PRINT_ELEMENTS(col2, "col2: ");

	//copy all elements of col1 again to position befor the second element of col2
	copy(col1.begin(), col1.end(), inserter(col2, ++col2.begin()));

	//print all elements of col2
	PRINT_ELEMENTS(col2, "col2: ");
}


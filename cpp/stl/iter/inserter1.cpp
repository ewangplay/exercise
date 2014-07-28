//inserter1.cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include "../print.hpp"
using namespace std;

int main()
{
	//define vector container
	vector<int> col1;

	//create the back inserter for col1
	back_insert_iterator<vector<int> > back_iter(col1);

	//insert some elements with back inserter iterator
	*back_iter = 1;
	//back_iter++;
	*back_iter = 2;
	//back_iter++;
	*back_iter = 3;
	//back_iter++;

	//print all the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");

	//create the back inserter and insert new elements
	back_inserter(col1) = 44;
	back_inserter(col1) = 55;

	//print all the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");

	//copy the elements again
	copy(col1.begin(), col1.end(), back_inserter(col1));

	//print all the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");
}



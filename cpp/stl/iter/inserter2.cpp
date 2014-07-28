//inserter2.cpp
#include <iostream>
#include <list>
#include <algorithm>
#include "../print.hpp"
using namespace std;

int main()
{
	//define list container
	list<int> col1;

	//create the front inserter for col1
	front_insert_iterator<list<int> > front_iter(col1);

	//insert some elements with front inserter iterator
	front_iter = 1;
	//front_iter++;
	front_iter = 2;
	//front_iter++;
	front_iter = 3;
	//front_iter++;

	//print all the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");

	//create the front inserter and insert new elements
	front_inserter(col1) = 44;
	front_inserter(col1) = 55;

	//print all the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");

	//copy the elements again
	copy(col1.begin(), col1.end(), front_inserter(col1));

	//print all the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");
}



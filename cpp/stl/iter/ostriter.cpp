//ostriter.cpp
#include <iostream>
#include <iterator>
#include <vector>
#include <algorithm>
using namespace std;

int main()
{
	//create a ostream iterator for cout stream
	ostream_iterator<int> iter(cout, "\n");

	//write some elements to cout with ostream iterator
	*iter = 1;
	//iter++;
	*iter = 2;
	//iter++;
	*iter = 3;
	//iter++;

	//define a vecotr container col1
	vector<int> col1;

	//insert some elements into col1
	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	//copy all elements of col1 to standard output
	copy(col1.begin(), col1.end(), ostream_iterator<int>(cout));
	cout << endl;

	//copy all elements of col1 to standard output with " < " delim
	copy(col1.begin(), col1.end(), ostream_iterator<int>(cout, " < "));
	cout << endl;
}

//iostriter.cpp
#include <iostream>
#include <string>
#include <iterator>
#include <algorithm>
using namespace std;

int main()
{
	//create a istream iterator for cin stream object
	istream_iterator<string> iIter(cin);

	//create a ostream iterator for cout stream object
	ostream_iterator<string> oIter(cout, " ");

	copy(iIter, istream_iterator<string>(), oIter);
}

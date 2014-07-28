//istriter.cpp
#include <iostream>
#include <iterator>
using namespace std;

int main()
{
	//create a istream iterator for cin stream object
	istream_iterator<int> intReader(cin);

	//create a end-of-stream iterator
	istream_iterator<int> EndOfReader;

	while(intReader != EndOfReader)
	{
		cout << "once: " << *intReader << endl;
		cout << "agine: " << *intReader << endl;
		++intReader;
	}
}


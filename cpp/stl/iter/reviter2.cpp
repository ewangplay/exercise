//reviter2.cpp
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

void print(int elem)
{
	cout << elem << ' ';
}

int main()
{
	vector<int> col1;

	//insert elements from 1 to 9
	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	//find the position of element with value 5
	vector<int>::iterator pos = find(col1.begin(), col1.end(), 5);
	cout << "pos: " << *pos << endl;

	//convert the iterator pos to reverse iterator rpos
	vector<int>::reverse_iterator rpos(pos);
	cout << "rpos: " << *rpos << endl;
}
	


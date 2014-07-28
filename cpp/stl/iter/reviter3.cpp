#include <iostream>
#include <deque>
#include <algorithm>
using namespace std;

void print(int elem)
{
	cout << elem << ' ';
}

int main()
{
	deque<int> col1;

	//insert elements from 1 to 9
	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	//find the element with value 2
	deque<int>::iterator pos1 = find(col1.begin(), col1.end(), 2);

	//find the element with value 7
	deque<int>::iterator pos2 = find(col1.begin(), col1.end(), 7);

	//print the elements with range [pos1, pos2)
	for_each(pos1, pos2, print);
	cout << endl;

	//convert the pos1 & pos2 to reverse iterator
	deque<int>::reverse_iterator rpos1(pos1);
	deque<int>::reverse_iterator rpos2(pos2);

	//print the elements with range [rpos2, rpos1)
	for_each(rpos2, rpos1, print);
	cout << endl;
}



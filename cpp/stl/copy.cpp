#include <iostream>
#include <list>
#include <vector>
#include <deque>
#include <algorithm>

using namespace std;

int main()
{
    //define list collection col1 and vector collection col2
    list<int> col1;
    vector<int> col2;

    //insert some elements into col1
    for (int i = 0; i < 9; ++i)
    {
        col1.push_back(i);
    }

    //resize the col2 to have enough room for overwriting algorithm
    col2.resize(col1.size());

    //copy the elements of col1 to col2
    copy(col1.begin(), col1.end(), col2.begin());

    //print the elements of col2
    vector<int>::iterator pos;
    cout << "vector: ";
    for (pos = col2.begin(); pos != col2.end(); ++pos)
    {
        cout << *pos << ' ';
    }
    cout << endl;

    //create the deque collection col3 with enough room
    deque<int> col3(col1.size());
    copy(col1.begin(), col1.end(), col3.begin());

    //print the elements of col3
    deque<int>::iterator pos1;
    cout << "deque: ";
    for (pos1 = col3.begin(); pos1 != col3.end(); ++pos1)
    {
        cout << *pos1 << ' ';
    }
    cout << endl;
}

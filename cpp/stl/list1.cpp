#include <iostream>
#include <list>
#include <algorithm>

using namespace std;

int main()
{
    typedef list<int> IntList;

    IntList col1;

    for(int i = 20; i <= 40; ++i)
    {
        col1.push_back(i);
    }

    IntList::iterator pos;
    pos = find(col1.begin(), col1.end(), 30);
    reverse(pos, col1.end());

    for(pos = col1.begin(); pos != col1.end(); ++pos)
    {
        cout << *pos << ' ';
    }
    cout << endl;
}

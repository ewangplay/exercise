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

    reverse(col1.begin(), col1.end());

    IntList::iterator pos, pos25, pos35;
    pos25 = find(col1.begin(), col1.end(), 25);
    pos35 = find(col1.begin(), pos25, 35);

    if (pos35 != pos25)
    {
        reverse(pos35, pos25);
    }
    else
    {
        pos35 = find(pos25, col1.end(), 35);
        if (pos35 != col1.end())
        {
            reverse(pos25, pos35);
        }
    }

    for(pos = col1.begin(); pos != col1.end(); ++pos)
    {
        cout << *pos << ' ';
    }
    cout << endl;
}

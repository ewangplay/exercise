#include <iostream>
#include <set>
#include "print.hpp"
using namespace std;

int main()
{
    multiset<int> col1;

    col1.insert(2);
    col1.insert(5);
    col1.insert(4);
    col1.insert(6);
    col1.insert(1);
    col1.insert(5);

    PRINT_ELEMENTS(col1, "col1: ");
    cout << endl;

    multiset<int>::const_iterator pos;
    pair<multiset<int>::iterator, multiset<int>::iterator> range;

    cout << "lower_bound(3): " << *col1.lower_bound(3) << endl;
    cout << "upper_bound(3): " << *col1.upper_bound(3) << endl;
    range = col1.equal_range(3);
    cout << "equal_range(3): " << *range.first << " " << *range.second << endl;
    cout << "elements with value(3): ";
    for (pos = range.first; pos != range.second; ++pos)
    {
        cout << *pos << " ";
    }
    cout << endl;
    cout << endl;

    cout << "lower_bound(5): " << *col1.lower_bound(5) << endl;
    cout << "upper_bound(5): " << *col1.upper_bound(5) << endl;
    range = col1.equal_range(5);
    cout << "equal_range(5): " << *range.first << " " << *range.second << endl;
    cout << "elements with value(5): ";
    for (pos = range.first; pos != range.second; ++pos)
    {
        cout << *pos << " ";
    }
    cout << endl;
}

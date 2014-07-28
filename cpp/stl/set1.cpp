#include <iostream>
#include <set>
#include <algorithm>
#include "print.hpp"
using namespace std;

int main() {
    typedef set<int, greater<int> > IntSet;

    IntSet col1;

    col1.insert(2);
    col1.insert(4);
    col1.insert(6);
    col1.insert(5);
    col1.insert(1);
    col1.insert(3);
    col1.insert(4);

    //copy(col1.begin(), col1.end(), ostream_iterator<int>(cout, " "));
    PRINT_ELEMENTS(col1, "col: ");

    pair<IntSet::iterator, bool> result = col1.insert(4);
    if (result.second) {
        cout << "insert " << *(result.first) << "successfully!" << endl;
    }
    else {
        cout << "4 has already existed!" << endl;
    }

    set<int> col2(col1.begin(), col1.end());

    //copy(col2.begin(), col2.end(), ostream_iterator<int>(cout, " "));
    PRINT_ELEMENTS(col2, "col2: ");

    col2.erase(col2.begin(), col2.find(3));

    col2.erase(4);

    //copy(col2.begin(), col2.end(), ostream_iterator<int>(cout, " "));
    PRINT_ELEMENTS(col2, "col2: ");

    return 0;
}


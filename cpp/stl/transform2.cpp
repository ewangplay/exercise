#include <iostream>
#include <vector>
#include <set>
#include <algorithm>
#include "print.hpp"

using namespace std;

int main()
{
    //create set and vecotor collection
    set<int> col1;
    vector<int> col2;

    //insert some elements into col1
    for (int i = 1; i <= 9; ++i)
    {
        col1.insert(i);
    }

    PRINT_ELEMENTS(col1, "col1: ");

    col2.resize(col1.size());
    //transform elements in col1 to col2
    transform(col1.begin(), col1.end(),
           col1.begin(),
           col2.begin(), 
           multiplies<int>() );

    PRINT_ELEMENTS(col2, "col2: ");
}

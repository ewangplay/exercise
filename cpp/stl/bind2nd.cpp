//bind2nd.cpp
#include <iostream>
#include <set>
#include <deque>
#include <algorithm>
#include "print.hpp"
using namespace std;

int main()
{
    //create set collection col1
    //and deque cllection col2
    set<int, greater<int> > col1;
    deque<int> col2;

    //insert some elements into col1
    for (int i = 1; i <= 9; ++i)
    {
        col1.insert(i);
    }

    //print all elements of col1
    PRINT_ELEMENTS(col1, "orignal col1:");

    //transform elements of col1 to col3 with multiple 10
    transform(col1.begin(), col1.end(),
            back_inserter(col2),
            bind2nd(multiplies<int>(), 10));

    //print all elements of col2
    PRINT_ELEMENTS(col2, "orignal col2:");

    //replace the element which equal to 70 with 42
    replace_if(col2.begin(), col2.end(),
            bind2nd(equal_to<int>(), 70), 42);

    //print all elements of col2
    PRINT_ELEMENTS(col2, "after replace of col2:");

    //remove the element which value equal to 50
    col2.erase(remove_if(col2.begin(), col2.end(), bind2nd(less<int>(), 50)), col2.end());

    //print all elements of col2
    PRINT_ELEMENTS(col2, "after remove of col2:");
}

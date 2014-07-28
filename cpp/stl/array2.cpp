#include <iostream>
#include <algorithm>
#include "carray.hpp"
#include "print.hpp"
using namespace std;

int main()
{
    carray<int, 6> col1;
    col1[0] = 2;
    col1[1] = 4;
    col1[2] = 7;
    col1[3] = 5;
    col1[4] = 8;
    col1[5] = 1;

    PRINT_ELEMENTS(col1, "original array: ");

    transform(col1.begin(), col1.end(), 
            col1.begin(),
            col1.begin(),
            multiplies<int>());
    sort(col1.begin(), col1.end());

    PRINT_ELEMENTS(col1, "processed array: ");
}

#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include "print.hpp"
using namespace std;

class AddValue
{
    private:
        int add_value;
    public:
        AddValue(int rhv) : add_value(rhv) {}
        void operator() (int& elem)
        {
            elem += add_value;
        }
};

int main()
{
    //create a vector collection col1
    vector<int> col1;

    //insert some elements in col1
    for (int i = 1; i <= 9; ++i)
    {
        col1.push_back(i);
    }

    PRINT_ELEMENTS(col1, "before: ");
    cout << endl;

    //print all elements
    for (int i = 1; i <= 5; ++i)
    {
        for_each (col1.begin(), col1.end(), AddValue(i));
        char strPrefix[128];
        sprintf(strPrefix, "after add %d: ", i);
        PRINT_ELEMENTS(col1, strPrefix);
        cout << endl;
    }
}

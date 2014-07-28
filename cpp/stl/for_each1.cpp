#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

void print(int x)
{
    cout << x << ' ';
}

int main()
{
    //create a vector collection col1
    vector<int> col1;

    //insert some elements in col1
    for (int i = 1; i <= 9; ++i)
    {
        col1.push_back(i);
    }

    //print all elements
    for_each (col1.begin(), col1.end(), print);
    cout << endl;
}

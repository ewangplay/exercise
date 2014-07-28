#include <iostream>
#include <list>
#include <algorithm>
#include <cstdlib>
#include "print.hpp"

using namespace std;

bool isPrime(int num)
{
    num = abs(num);

    //0 and 1 are prime number
    if (num == 0 || num == 1)
    {
        return true;
    }

    int dision;
    for (dision = num / 2; num % dision != 0; --dision)
    {
        ;
    }

    return dision == 1;
}

int main()
{
    //create a list collection col1
    list<int> col1;

    //insert some elements into col1
    for (int i = 20; i <= 30; ++i)
    {
        col1.push_back(i);
    }

    //print all elements of col1
    PRINT_ELEMENTS(col1, "collection: ");

    //find the first prime number
    list<int>::iterator pos;
    pos = find_if(col1.begin(), col1.end(), isPrime);

    if (pos != col1.end())
    {
        cout << *pos << " is the first prime number found!" <<endl;
    }
    else
    {
        cout << "there is no prime number in this collection" <<endl;
    }
}

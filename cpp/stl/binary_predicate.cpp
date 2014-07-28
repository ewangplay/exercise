//binary_predicate.cpp
#include <iostream>
#include <string>
#include <deque>
#include <algorithm>
#include "member.hpp"

using namespace std;

bool memberSortCriterion(Member * ptr1, Member * ptr2)
{
    return ptr1->get_age() < ptr2->get_age();
}

int main()
{
    //create a deque collection col1
    deque<Member *> col1;
    deque<Member *>::iterator pos;

    //insert some members into col1
    col1.push_back(new Member("Tom", 23));
    col1.push_back(new Member("Mary", 26));
    col1.push_back(new Member("John", 20));
    col1.push_back(new Member("Jemssey", 30));
    col1.push_back(new Member("Loliy", 15));

    //print all the element of col1
    cout << "before sort:" << endl;
    for (pos = col1.begin(); pos != col1.end(); ++pos)
    {
        cout << (*pos)->get_name() << "\t" << (*pos)->get_age() << endl;
    }
    cout <<endl;

    //sort the collection
    sort(col1.begin(), col1.end(), memberSortCriterion);

    //print all the element of col1
    cout << "after sort:" << endl;
    for (pos = col1.begin(); pos != col1.end(); ++pos)
    {
        cout << (*pos)->get_name() << "\t" << (*pos)->get_age() << endl;
    }
    cout <<endl;

    //free all the member object
    for (pos = col1.begin(); pos != col1.end(); ++pos)
    {
        delete (*pos);
        *pos = NULL;
    }
}

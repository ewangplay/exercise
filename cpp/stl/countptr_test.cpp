#include <iostream>
#include <deque>
#include <list>
#include <algorithm>
#include "member.hpp"
#include "countptr.hpp"
using namespace std;

const char* members_name[4] = {
    "Tom",
    "Mary",
    "Jery",
    "Mark"
};

const int members_age[4] = {
    23,
    21,
    24,
    30
};

//type definitions
typedef CountedPtr<Member> MemberPtr;
typedef deque<MemberPtr> MemberDeque;
typedef list<MemberPtr> MemberList;

void PrintElement(MemberPtr& elem);

int main()
{
    //define collections
    MemberDeque col1;
    MemberList col2;

    //insert some elements 
    for(int i = 0; i < 4; ++i)
    {
        MemberPtr ptr(new Member(members_name[i], members_age[i]));
        col1.push_back(ptr);
        col2.push_front(ptr);
    } 
 
    //print all the elements of collection
    cout << "col1:" << endl;
    for_each(col1.begin(), col1.end(), PrintElement);
    cout << endl;
    cout << "col2:" << endl;
    for_each(col2.begin(), col2.end(), PrintElement);
    cout << endl;

    //modify the first element in col1
    (*col1.begin())->set_name("John");
    (*col1.begin())->set_age(45);

    //delete the last elemetn in col1
    col1.erase(col1.end()--);

    //print all the elements of collection
    cout << "col1:" << endl;
    for_each(col1.begin(), col1.end(), PrintElement);
    cout << endl;
    cout << "col2:" << endl;
    for_each(col2.begin(), col2.end(), PrintElement);
}

void PrintElement(MemberPtr& elem) 
{
        cout << *elem;
}

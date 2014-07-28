#include <iostream>
#include <set>
#include "print.hpp"
using namespace std;

template <typename T>
class RuntimeCmp 
{
    public:
        enum cmp_mode {normal, reverse};
    private:
        cmp_mode mode;
    public:
        RuntimeCmp(cmp_mode m = normal) : mode(m) {}

        bool operator() (const T& t1, const T& t2)
        {
            return mode == normal ? t1 < t2 : t1 > t2;
        }

        bool operator== (const T& rhv) 
        {
            return mode == rhv.mode;
        }
};

typedef set<int, RuntimeCmp<int> > IntSet;

//pre-declare
void fill(IntSet& col1);

int main()
{
    IntSet col1;
    fill(col1);
    PRINT_ELEMENTS(col1, "col1 ");

    RuntimeCmp<int> reverse_cmp(RuntimeCmp<int>::reverse);
    IntSet col2(reverse_cmp);
    fill(col2);
    PRINT_ELEMENTS(col2, "col2 ");

    if (col1 == col2) 
    {
        cout << "col1 and col2 is equal" <<endl;
    }
    else
    {
        if (col1 < col2) 
        {
            cout << "col1 is less than col2" << endl;
        }
        else 
        {
            cout << "col1 is greater than col2" << endl;
        }
    }
    return 0;
}

void fill(IntSet& col1) 
{
    col1.insert(2);
    col1.insert(3);
    col1.insert(6);
    col1.insert(5);
    col1.insert(1);
    col1.insert(4);
}

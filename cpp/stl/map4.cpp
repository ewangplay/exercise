#include <iostream>
#include <iomanip>
#include <map>
#include <algorithm>
using namespace std;

template <typename T>
class RuntimeStringCmp
{
    public:
        enum Cmp_Mode {normal, nocase};
        
    private:
        Cmp_Mode mode;
        static bool nocase_compare(char c1, char c2)
        {
            return toupper(c1) < toupper(c2);
        }

    public:
        RuntimeStringCmp(Cmp_Mode m=normal) : mode(m) {}
        bool operator() (const T& v1, const T& v2)
        {
            if (mode == normal)
            {
                return v1 < v2;
            }
            else
            {
                return lexicographical_compare(v1.begin(), v1.end(), 
                        v2.begin(), v2.end(), 
                        nocase_compare);
            }
        }
};

//type define
typedef map<string, float, RuntimeStringCmp<string> >  StringFloatMap;

//pre-declare fuction
void FillAndPrint(StringFloatMap m);

int main()
{
    StringFloatMap col1;
    FillAndPrint(col1);

    RuntimeStringCmp<string> nocase_cmp(RuntimeStringCmp<string>::nocase);
    StringFloatMap col2(nocase_cmp);
    FillAndPrint(col2);
}

void FillAndPrint(StringFloatMap m) 
{
    //insert some elements
    m["Deutschland"] = 60;
    m["deutsch"] = 72.5;
    m["Haken"] = 80;
    m["arbeiten"] = 65;
    m["Hund"] = 77;
    m["gehen"] = 88;
    m["Unternehmen"] = 55;
    m["gehen"] = 81;
    m["Bestatter"] = 65.6;

    //print all elements
    StringFloatMap::iterator pos;
    cout.setf(ios::left, ios::adjustfield);
    for (pos = m.begin(); pos != m.end(); ++pos) 
    {
        cout << setw(15) << pos->first.c_str() << " " << pos->second <<endl;
    }
    cout << endl;
}

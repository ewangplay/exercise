#include <iostream>
#include <map>
using namespace std;

int main() 
{
    typedef map<string, float> StringFloatMap;

    StringFloatMap col1;

    col1.insert(make_pair("Tom", 67.5));
    col1.insert(make_pair("John", 80.5));
    col1.insert(make_pair("Mary", 90));
    col1.insert(make_pair("Jekey", 78.4));

    StringFloatMap::iterator pos;
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    col1.erase("Mary");

    col1.insert(StringFloatMap::value_type("Wang", 95.4));
    col1.insert(pair<string, float>("Man", 88.5));

    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    pos = col1.find("Man");
    col1.erase(pos);
    ++pos;
    cout << pos->first << "\t" << pos->second << endl;
    cout << endl;
    
    for (pos = col1.begin(); pos != col1.end(); ) 
    {
        if (pos->second == 88.5) 
        {
            col1.erase(pos++);
        }
        else
        {
            ++pos;
        }
    }   

    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;
}

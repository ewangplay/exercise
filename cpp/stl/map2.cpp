#include <iostream>
#include <map>
using namespace std;

int main() 
{
    typedef map<string, float> StringFloatMap;

    //create a empty StringFloatMap set
    StringFloatMap col1;

    //insert some elements
    col1["Tom"] = 67.5;
    col1["John"] = 80.5;
    col1["Mary"] = 90;
    col1["Jekey"] = 78.4;

    //print all the elements of col1
    StringFloatMap::iterator pos;
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    //delete the element with key is Mary
    col1.erase("Mary");

    //insert tow new elements
    col1["Wang"] = 95.4;
    col1["Man"] = 88.5;

    //print all the elements of col1
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    //find the element with key is Man
    pos = col1.find("Man");
    cout << pos->first << "\t" << pos->second << endl;
    cout << endl;
    
    //delete the element with value is 88.5
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        if (pos->second == 88.5) 
        {
            col1.erase(pos);
        }
    }   

    //print all the elements of col1
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    //Modify the key of element with key is Tom
    col1["Zhang"] = col1["Tom"];
    col1.erase("Tom");

    //print all the elements of col1
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    return 0;
}

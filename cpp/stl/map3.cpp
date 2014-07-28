#include <iostream>
#include <map>
#include <algorithm>
using namespace std;

template <typename K, typename V>
class equal_value 
{
    private:
        V value;

    public:
        equal_value(const V& v): value(v) {}
        bool operator() (pair<const K, V> elem)
        {
            return elem.second == value;
        }
};

int main() 
{
    typedef map<float, float> FloatFloatMap;

    //create a empty FloatFloatMap set
    FloatFloatMap col1;

    //insert some elements
    col1[2] = 3;
    col1[4] = 5;
    col1[3] = 6;
    col1[5] = 3;
    col1[1] = 4;
    col1[6] = 1;

    //print all the elements of col1
    FloatFloatMap::iterator pos;
    for (pos = col1.begin(); pos != col1.end(); ++pos) 
    {
        cout << "key: " << pos->first << "\t" << "value: " << pos->second << endl;
    }
    cout << endl;

    //find the element with key 3
    pos = col1.find(3);
    if (pos != col1.end())
    {
        cout << pos->first << "\t" << pos->second << endl;
    }

    //find the elements with value 3
    pos = find_if(col1.begin(), col1.end(), equal_value<float, float>(3));
    if (pos != col1.end())
    {
        cout << pos->first << "\t" << pos->second << endl;
    }

    return 0;
}

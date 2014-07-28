#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> col1;
    col1.reserve(10);
    col1.push_back(2);
    col1.push_back(5);
    cout << "col1 size:" << col1.size() << endl;
    cout << "col1 capacity:" << col1.capacity() <<endl;
    cout << endl;

    vector<int> col2(10);
    cout <<"col2 size:" << col2.size() << endl;
    cout << "col2 capacity:" <<col2.capacity() <<endl;

    return 0;
}

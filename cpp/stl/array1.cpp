#include <iostream>
#include <algorithm>
using namespace std;

int main()
{
    int col[] = {2, 4, 7, 5, 8, 1};
    int size = sizeof(col) / sizeof(col[0]);

    cout << "original array: ";
    for(int i = 0; i < size; ++i)
    {
        cout << col[i] << " ";
    }
    cout <<endl;

    transform(col, col + size,
            col,
            col,
            multiplies<int>());
    sort(col + 1, col + size);

    cout << "processed array: ";
    for(int i = 0; i < size; ++i)
    {
        cout << col[i] << " ";
    }
    cout <<endl;
}

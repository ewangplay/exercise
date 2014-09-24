#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() 
{
    vector<int> vecRand(10);

    //lambda表达式最基本的形式
    generate(vecRand.begin(), vecRand.end(), []{
            return rand() % 100;
            });
    //带参数列表的lambda表达式
    for_each(vecRand.begin(), vecRand.end(), [](int n) {
            cout << n << endl;
            });

    //lambda表达式按引用捕获变量
    //按引用捕获的变量在lambda函数体中可以修改，并且会最终
    //反映到函数体外面。
    int oddCount = 0;
    for_each(vecRand.begin(), vecRand.end(), [&oddCount](int n) {
            if(n % 2 == 1) oddCount++;
            });
    cout << "odd numbers in the vector is:" << oddCount << endl;
}

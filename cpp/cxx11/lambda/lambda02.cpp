#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Factor 
{
    public:
        Factor(int v, int s)
        {
            value = v;
            step = s;
        }

        int operator() ()
        {
            return value += step;
        }

    private:
        int value;
        int step;
};

int main() 
{
    vector<int> vecRand(10);

    //lambda表达式按引用和按值捕获变量
    //按值捕获的变量在lambda函数体中是只读的，不能够进行修改。
    int step = 2;
    int value = -step;
    generate(vecRand.begin(), vecRand.end(), [&value,step]{
            return value += step;
            });
    for_each(vecRand.begin(), vecRand.end(), [](int n) {
            cout << n << endl;
            });
    cout << "value: " << value << endl;

    //lambda表达式mutable的用法
    //和上面的方法相比，生成的列表结果是一样的，但是最后检查value的值
    //会发现是不一样的，上面的方法value的最终值为18，而这个方法中value
    //的最终值还是-2。这说明按引用捕获使用变量时，函数体内修改的变量
    //值的确反映到了函数体外面；但使用mutable时虽然可以在函数体内修改
    //按值捕获的变量，但修改的值只限于在lambda函数体内使用，对外面是
    //不可见的。
    value = -step;
    generate(vecRand.begin(), vecRand.end(), [value,step]() mutable {
            return value += step;
            });
    for_each(vecRand.begin(), vecRand.end(), [](int n) {
            cout << n << endl;
            });
    cout << "value: " << value << endl;

    //函数对象（Function Object）的用法，这种用法得到的结果跟上面使用
    //mutable是的的结果完全一样。实际上上面的使用mutable形式的lambda
    //表达式只是对函数对象的一个语法糖，更方便我们表达而已。
    value = -step;
    generate(vecRand.begin(), vecRand.end(), Factor(value, step));
    for_each(vecRand.begin(), vecRand.end(), [](int n) {
            cout << n << endl;
            });
    cout << "value: " << value << endl;

}

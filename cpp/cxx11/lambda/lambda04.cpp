#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() 
{
    int x = 1, y = 2;
    auto fn = [x, &y]() -> int {
        return x+y;
    };

    x = 4;
    y = 5;

    //该程序最终的输出结果为6。
    //那么，为什么是6？ 而不是3，也不是9。
    //这就涉及到按引用捕获和按值捕获的变量的取值规则了。
    //对于按值捕获的变量，在lambda表达式声明的时候就已经确定，之后
    //无论外面到变量怎么修改，都不会影响lambda表达式中的变量值。
    //对于按引用捕获的变量，lambda表达式中的和外面的是同一个变量，
    //所以外面的值变化里面的也变化。
    //所以针对该例子，当调用fn时，x=1, y=5,所以结果为6.
    cout << fn() << endl;
}


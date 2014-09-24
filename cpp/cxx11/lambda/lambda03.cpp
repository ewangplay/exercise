#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

class Factor 
{
    public:
        int operator() (int x, int y)
        {
            return x + y;
        }
};

void foo(function<int (int, int)> f)
{
    cout << f(1, 2) << endl;
}

template <class Fn>
void bar(Fn f)
{
    cout << f(1, 2) << endl;
}

int main() 
{
    //如何声明一个lambda表达式（也可以称之为匿名函数）
    function<int (int, int)> fn1 = [](int x, int y) {
        return x+y;
    };

    //相对于上面的声明方式，使用auto更加的简洁优雅,推荐这种方法
    auto fn2 = [](int x, int y) {
        return x+y;
    };

    //从下面的调用中可以看出来lambda表达式和函数对象实际上是等价的，
    //它们可以应用在相同的场景下，只是labmda表达式是函数对象的一个
    //语法糖，更加的简洁和优雅。
    foo(fn1);
    bar(fn1);

    foo(fn2);
    bar(fn2);

    foo(Factor());
    bar(Factor());
}


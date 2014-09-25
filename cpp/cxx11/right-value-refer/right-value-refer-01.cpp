#include <iostream>
#include <string.h>

using namespace std;

class CHasPtrMem
{
    public:
        //默认的构造函数
        CHasPtrMem()
        {
            cout << "call CHasPtrMem()" << endl;
            m_pstr = new char[1];
            m_pstr[0] = '\0';
        }

        //带参数的构造函数
        CHasPtrMem(const char *pstr)
        {
            cout << "call CHasPtrMem(char *pstr)" << endl;
            if(pstr == NULL)
            {
                m_pstr = new char[1];
                m_pstr[0] = '\0';
            }
            else
            {
                m_pstr = new char[strlen(pstr) + 1];
                strcpy(m_pstr, pstr);
            }
        }

        //拷贝构造函数
        CHasPtrMem(const CHasPtrMem & r)
        {
            cout << "call CHasPtrMem(const CHasPtrMem & r)" << endl;
            m_pstr = new char[strlen(r.m_pstr) + 1];
            strcpy(m_pstr, r.m_pstr);
        }

        //赋值函数
        CHasPtrMem & operator=(const CHasPtrMem & r)
        {
            cout << "call operator=(const CHasPtrMem & r)" << endl;
            if(this != &r)
            {
                delete m_pstr;
                m_pstr = new char[strlen(r.m_pstr) + 1];
                strcpy(m_pstr, r.m_pstr);
            }
            return *this;
        }

        //移动构造函数
        CHasPtrMem(CHasPtrMem && r)
        {
            cout << "call CHasPtrMem(const CHasPtrMem && r)" << endl;
            m_pstr = r.m_pstr;
            r.m_pstr = nullptr;
        }

        //移动赋值函数
        CHasPtrMem & operator=(CHasPtrMem && r)
        {
            cout << "call operator=(const CHasPtrMem && r)" << endl;
            if(this != &r)
            {
                delete m_pstr;
                m_pstr = r.m_pstr;
                r.m_pstr = nullptr;
            }
            return *this;
        }

        //析构函数
        ~CHasPtrMem()
        {
            cout << "call ~CHasPtrMem()" << endl;
            delete m_pstr;
        }

        char * GetString()
        {
            return m_pstr;
        }

    private:
        char * m_pstr;
};

CHasPtrMem ReturnCHasPtrMemIns()
{
    //调用带参数的构造函数
    CHasPtrMem tmp("jerry");
    return tmp;
}

int main() 
{
    //调用带参数的构造函数
    CHasPtrMem a("tom");
    //调用默认构造函数
    CHasPtrMem b;
    //调用赋值函数
    b = a;
    //调用Copy构造函数
    CHasPtrMem c = b;
    
    //这个地方调用了函数返回一个CHasPtrMem对象
    //按照程序上进行分析：函数ReturnCHasPtrMemIns内定义了临时变量，而
    //函数返回时又会产生一个临时变量(比如我们称之为tmp1)，那么
    //tmp -> tmp1, tmp1 -> d的过程会有两次调用Copy构造函数的过程，但是
    //从程序输出的日志发现没有这两次Copy的过程，为什么会这样？
    //原来这是编译器的RVO（return value optimization)特性，自动对代码
    //进行了优化，把中间由于临时变量导致的两次Copy过程给优化掉了。最终
    //优化的效果就是变量d直接使用了tmp的地址，任何的拷贝过程都没有了。
    //如果希望像预期的那样看到这两次拷贝构造过程，在使用g++编译器时带上
    //-fno-elide-constructors选项即可。这样就关闭了RVO优化特性。
    //一旦我们定义了移动构造函数，那么由于临时变量产生的两次拷贝构造过程
    //就变为了两次移动构造过程。也就是说在c++11新标准中，对于临时对象的
    //拷贝构造过程，使用了移动语义来进行替换，以优化代码速度。但前提是
    //必须定义相应的移动语义函数。
    //但是，如果开启了RVO优化（不使用-fno-elide-constructors选项），那么
    //不管是拷贝构造过程还是移动构造过程，都会被优化掉。
    CHasPtrMem d = ReturnCHasPtrMemIns();

    cout << "a: " << a.GetString() << endl;
    cout << "b: " << b.GetString() << endl;
    cout << "c: " << c.GetString() << endl;
    cout << "d: " << d.GetString() << endl;
}


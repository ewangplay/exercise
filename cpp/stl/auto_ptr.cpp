#include <iostream>
#include <memory>
using namespace std;

void my_print(const auto_ptr<int>& p)
{
    cout << *p << endl;
}

int main()
{
    auto_ptr<int> pi(new int(3));

    my_print(pi);

    cout << *pi << endl;
}

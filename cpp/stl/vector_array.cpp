#include <vector>
using namespace std;

int main()
{
    vector<char> v;
    //v.resize(41);
    v.reserve(41);
    strcpy(&v[0], "hello, world!");
    printf("%s\n", &v[0]);
}

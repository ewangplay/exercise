//memfun.cpp
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <functional>
using namespace std;

class Person
{
	public:
		Person(string str): name(str) {}

		void print() const
		{
			cout << name << endl;
		}

		void printPrefix(string prefix) const
		{
			cout << prefix << name << endl;
		}

	private:
		string name;
};

int main()
{
	vector<Person *> col1;

	col1.push_back(new Person("Tom"));
	col1.push_back(new Person("Mary"));
	col1.push_back(new Person("Wang"));
	col1.push_back(new Person("Bill"));

	for_each(col1.begin(), col1.end(), mem_fun(&Person::print));
	cout << endl;

	for_each(col1.begin(), col1.end(), bind2nd(mem_fun(&Person::printPrefix), "name: "));
}


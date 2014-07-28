//memfunref.cpp
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

		void printWithPrefix(string prefix) const
		{
			cout << prefix << name << endl;
		}
	private:
		string name;
};

int main()
{
	vector<Person> col1;

	//insert some Person object into col1
	col1.push_back(Person("Tom"));
	col1.push_back(Person("Mary"));
	col1.push_back(Person("Wang"));
	col1.push_back(Person("Bill"));

	//call Person::print member fucntion 
	for_each(col1.begin(), col1.end(), mem_fun_ref(&Person::print));
	cout << endl;

	//call Person::printWithPrefix member fucntion
	for_each(col1.begin(), col1.end(), bind2nd(mem_fun_ref(&Person::printWithPrefix), "name: "));
}


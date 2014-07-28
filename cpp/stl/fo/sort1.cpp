//sort1.cpp
#include <iostream>
#include <set>
#include <algorithm>
#include <string>
#include "../print.hpp"
using namespace std;

//define the Person class
class Person
{
	public:
		Person(string name, int age): m_name(name), m_age(age) {}
		Person(const Person &p)
		{
			m_name = p.m_name;
			m_age = p.m_age;
		}

		string name() const
		{
			return m_name;
		}
		int age() const
		{
			return m_age;
		}

		friend ostream & operator<<(ostream & os, const Person& p)
		{
			os << p.name() << ":" << p.age();
			return  os;
		}

	private:
		string m_name;
		int m_age;
};

//define the Person Sort Criterion class
class PersonSortCriterion
{
	public:
		bool operator() (const Person& p1, const Person& p2) const
		{
			return p1.age() > p2.age();
		}
};

//main
int main()
{
	//PersonSet type define
	typedef set<Person, PersonSortCriterion> PersonSet;

	//define a PersonSet set
	PersonSet col1;

	//insert some elements into col1
	col1.insert(Person("wang", 21));
	col1.insert(Person("zhang", 30));
	col1.insert(Person("zhao", 25));
	col1.insert(Person("qian", 40));

	//print the elements of col1
	PRINT_ELEMENTS(col1, "col1: ");
}


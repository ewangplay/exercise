//foreach.cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include "../print.hpp"
using namespace std;

class MeanValue
{
	public:
		MeanValue() : sum(0), num(0){}
		void operator() (int val)
		{
			num++;
			sum += val;
		}
		double value() 
		{
			return static_cast<double>(sum) / static_cast<double>(num);
		}

	private:
		long sum;
		long num;
};

int main()
{
	//define a vector container
	vector<int> col1;

	//insert elements from 1 to 9
	for(int i = 1; i <= 9; ++i)
	{
		col1.push_back(i);
	}

	//print col1
	PRINT_ELEMENTS(col1, "col1: ");

	//process and print mean value
	MeanValue mv = for_each(col1.begin(), col1.end(), MeanValue());
	cout << "mean value: " << mv.value() << endl;
}

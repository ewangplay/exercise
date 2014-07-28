#include <iostream>
#include "animal.hpp"

using namespace std;

//======================= Dog Impelementation =================================
void Dog::bark()
{
    cout << "wa,wa,wa....." << endl;
}

Animal * Dog::copy() const
{
    return(new Dog(*this));
}

//======================== Pig Implementation ===============================
void Pig::bark()
{
    cout << "he,he,he....." << endl;
}

Animal * Pig::copy() const
{
    return(new Pig(*this));
}

//========================= Horse Implementation ============================
void Horse::bark()
{
    cout << "ga, ga, ga ......" << endl;
}

Animal * Horse::copy() const
{
    return(new Horse(*this));
}


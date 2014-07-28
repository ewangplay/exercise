#include "animalagency.hpp"

AnimalAgency::AnimalAgency(): pa(0) 
{
}

AnimalAgency::AnimalAgency(const Animal & animal): pa(animal.copy())
{
}

AnimalAgency::AnimalAgency(const AnimalAgency & aa)
{
    pa = aa.pa?aa.pa->copy():0;
}

AnimalAgency & AnimalAgency::operator=(const AnimalAgency & aa)
{
    if(this != &aa) 
    {
        delete pa;
        pa = aa.pa?aa.pa->copy():0;
    }
    return *this;
}

AnimalAgency::~AnimalAgency()
{
    delete pa;
}

void AnimalAgency::bark()
{
    pa->bark();
}


#ifndef _ANIMALAGENCY_HPP_
#define _ANIMALAGENCY_HPP_

#include "animal.hpp"

class AnimalAgency
{
    public:
        AnimalAgency();
        AnimalAgency(const Animal & animal);
        AnimalAgency(const AnimalAgency & aa);
        AnimalAgency & operator=(const AnimalAgency & aa);
        ~AnimalAgency();

        void bark();

    private:
        Animal * pa;
};

#endif



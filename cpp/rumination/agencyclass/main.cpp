#include "animal.hpp"
#include "animalagency.hpp"

int main(int argc, char **argv)
{
    AnimalAgency aa[3];
    Dog dog;
    Pig pig;
    Horse horse;

    aa[0] = dog;
    aa[1] = pig;
    aa[2] = horse;

    for(int i = 0; i < 3; i++)
    {
        aa[i].bark();
    }

    return(0);
}


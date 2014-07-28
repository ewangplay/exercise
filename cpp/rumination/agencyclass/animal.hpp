#ifndef _ANIMAL_HPP_
#define _ANIMAL_HPP_

class Animal 
{
    public:
        virtual void bark() = 0;
        virtual ~Animal(){}
        virtual Animal * copy() const = 0;
};

class Dog: public Animal
{
    public:
        virtual void bark();
        virtual Animal * copy() const;
};

class Pig: public Animal
{

    public:
        virtual void bark();
        virtual Animal * copy() const;
};

class Horse: public Animal
{
    public:
        virtual void bark();
        virtual Animal * copy() const;
};

#endif 

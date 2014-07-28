#ifndef _MEMBER_HPP_
#define _MEMBER_HPP_
#include <string>
using namespace std;

class Member 
{
    public:
        Member(const char * r_cstr_name, int r_age) : name(r_cstr_name), age(r_age) {}
        Member(string r_name, int r_age) : name(r_name), age(r_age) {}
        Member(const Member& rv) : name(rv.name), age(rv.age) {}
        Member& operator= (const Member& rv) 
        {
            if (this != &rv)
            {
                name = rv.name;
                age = rv.age;
            }
            return *this;
        }
        friend inline ostream& operator<< (ostream& os, const Member& rv)
        {
            os << "name: " << rv.name << "\tage: " << rv.age << endl;
            return os;
        }
        void set_name(const char * r_cstr_name)
        {
            name = r_cstr_name;
        }
        void set_name(string r_name)
        {
            name = r_name;
        }
        string get_name()
        {
            return name;
        }

        void set_age(int r_age)
        {
            age = r_age;
        }
        int get_age()
        {
            return age;
        }

    private:
        string name;
        int age;
};

#endif  //_MEMBER_HPP_

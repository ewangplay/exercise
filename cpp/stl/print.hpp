#ifndef _PRINT_HPP_
#define _PRINT_HPP_
#include <iostream>

template <typename T>
inline void PRINT_ELEMENTS(const T& col1, const char * optcstr)
{
    typename T::const_iterator pos;
    std::cout << optcstr;
    for (pos = col1.begin(); pos != col1.end(); ++pos)
    {
        std::cout << *pos << ' ';
    }
    std::cout << std::endl;
}
#endif

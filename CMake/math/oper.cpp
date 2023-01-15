#include "oper.h"
#include <iostream>

namespace math{
    int operations::sum(const int& a, const int& b){
        std::cout << "sum: " << a << ", " << b << std::endl;
        return a + b;
    }
    int operations::mult(const int& a, const int& b){
        std::cout << "mult: " << a << ", " << b << std::endl;
        return a*b;
    }
}
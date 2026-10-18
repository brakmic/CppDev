#pragma once

#include <string>
#include <string_view>

namespace hello {

std::string greeting(std::string_view name);
int add(int lhs, int rhs);

}  // namespace hello

#include "hello.hpp"

#include <format>

namespace hello {

std::string greeting(std::string_view name) {
    return std::format("Hello, {}!", name);
}

int add(int lhs, int rhs) {
    return lhs + rhs;
}

}  // namespace hello

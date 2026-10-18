#include "hello.hpp"

#include <cstdlib>
#include <iostream>

namespace {

void expect(bool condition, const char* message) {
    if (!condition) {
        std::cerr << "FAILED: " << message << '\n';
        std::exit(EXIT_FAILURE);
    }
}

}  // namespace

int main() {
    expect(hello::greeting("world") == "Hello, world!", "greeting returns the expected text");
    expect(hello::add(2, 3) == 5, "add returns the expected sum");

    std::cout << "All checks passed\n";
    return EXIT_SUCCESS;
}

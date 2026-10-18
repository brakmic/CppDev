cmake_minimum_required(VERSION 3.28)
project(cmake_hello VERSION 1.0.0 LANGUAGES CXX)

option(ENABLE_SANITIZERS "Build with AddressSanitizer and UndefinedBehaviorSanitizer" OFF)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

if(ENABLE_SANITIZERS)
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
endif()

add_library(hello src/hello.cpp)
target_include_directories(hello PUBLIC include)
target_compile_features(hello PUBLIC cxx_std_23)

add_executable(cmake_hello src/main.cpp)
target_link_libraries(cmake_hello PRIVATE hello)

include(CTest)
if(BUILD_TESTING)
    add_executable(hello_tests tests/test_hello.cpp)
    target_link_libraries(hello_tests PRIVATE hello)
    add_test(NAME hello_tests COMMAND hello_tests)
endif()

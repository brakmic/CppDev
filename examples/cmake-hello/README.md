# CMake Hello

A minimal C++23 project that exercises the toolchain in the CppDev image:
CMake presets, Ninja, CTest, and optional sanitizers.

## Build and test

```bash
cmake --preset release
cmake --build --preset release
ctest --preset release
```

## Debug build

```bash
cmake --preset debug
cmake --build --preset debug
./build/debug/cmake_hello
```

The debug preset exports `compile_commands.json` for clangd and IDE tooling.

## Sanitizers

```bash
cmake --preset sanitize
cmake --build --preset sanitize
ctest --preset sanitize
```

## Debugging and profiling

```bash
gdb ./build/debug/cmake_hello
valgrind --leak-check=full ./build/debug/cmake_hello
```

## ccache

The image includes `ccache`. Enable it per project with:

```bash
cmake --preset debug -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```

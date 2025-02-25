# C++ Development Environment in Docker

This repository provides a lightweight Docker image for modern C++ development, using Ubuntu 24.04 as the base and GCC/G++ 14 as the default compiler.

## Features

- **Ubuntu 24.04** for a recent Linux environment
- **GCC/G++ 14** set as default compilers
- Essential build tools: `cmake`, `ninja-build`, `valgrind`, etc.
- Common utilities for networking and debugging (`net-tools`, `iproute2`, `gdb`, `strace`, etc.)
- Non-root user `cppdev` with passwordless sudo

## Getting Started

### Pull the Image

```bash
docker pull brakmic/cppdev:latest
```

### Run the Container

```bash
docker run -it --rm -v $(pwd):/workspace brakmic/cppdev:latest
```

- `-it` starts an interactive session.
- `--rm` cleans up the container after you exit.
- `-v $(pwd):/workspace` mounts the current directory into the `/workspace` folder inside the container, so you can work with your local files.

## Usage

Inside the container, you have:

- GCC/G++ 14
- `cmake`, `ninja`, and other build tools
- `git`, `nano`, and other essential utilities

By default, you’ll be dropped into a bash shell as the `cppdev` user. Any changes in `/workspace` will be reflected on your host machine’s current directory due to the volume mount.

## License

[MIT](./LICENSE)

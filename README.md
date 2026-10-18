# CppDev

[![CI](https://github.com/brakmic/CppDev/actions/workflows/ci.yml/badge.svg)](https://github.com/brakmic/CppDev/actions/workflows/ci.yml)

A ready-to-use C++ development environment in Docker, based on Ubuntu 24.04 with GCC 14 as the default compiler. It provides the toolchain for building, debugging, profiling, and testing C++ projects, runs as a non-root user with passwordless sudo, and works both as a standalone container and as a VS Code dev container.

## Images

| Image | Purpose |
| --- | --- |
| `brakmic/cppdev:latest` | Base C++ toolchain |
| `brakmic/cppdev:devcontainer` | Base image plus Node.js, Docker Engine, and `lsd` for dev container use |

The release workflow publishes both images for `linux/amd64` and `linux/arm64`.

## Quick start

Bash or zsh:

```bash
docker run --rm -it -v "$(pwd):/workspace" brakmic/cppdev:latest
```

PowerShell:

```powershell
docker run --rm -it -v "${PWD}:/workspace" brakmic/cppdev:latest
```

The current directory is mounted at `/workspace`, and the container starts an interactive Bash shell as the `cppdev` user. Files created in `/workspace` are written to the host directory.

## What is included

| Component | Version in the current image |
| --- | --- |
| Ubuntu | 24.04 |
| GCC / G++ | 14.2.0 (default, selectable at build time) |
| CMake | 3.28.3 |
| Ninja | 1.11.1 |
| GNU Make | 4.3 |
| GDB | 15.1 |
| Valgrind | 3.22.0 |
| ccache | 4.9.1 |
| Python | 3.12.3 with `venv` and `pip` |
| Git | 2.43.0 |
| nano | with enhanced syntax highlighting |

The image also includes autotools (`autoconf`, `automake`, `libtool`), `pkg-config`, `bash-completion`, `git-lfs`, `strace`, `lsof`, `net-tools`, `iproute2`, `iputils-ping`, and `dnsutils`.

The devcontainer image adds:

| Component | Version in the current image |
| --- | --- |
| Node.js | 22.23.3 |
| npm | 10.9.9 |
| Docker Engine and CLI | 29.9.1 |
| lsd | 1.2.0 |

Global npm packages: `typescript`, `tsx`, `node-gyp`, `yarn`, `nodemon`, and `eslint`.

### Optional tooling

Build with `INSTALL_EXTRA_TOOLS=true` to add:

| Component | Version in the current image |
| --- | --- |
| clang-format | 18.1.3 |
| clang-tidy | 18.1.3 |
| Cppcheck | 2.13.0 |
| gcovr | 7.0 |
| lcov | 2.0 |
| Meson | 1.3.2 |
| pipx | 1.4.3 |
| gdbserver | 15.1 |

```bash
docker build --build-arg INSTALL_EXTRA_TOOLS=true -t cppdev:extra .
```

## Build from source

```bash
docker build -t cppdev:local .
```

Useful build arguments:

| Argument | Default | Purpose |
| --- | --- | --- |
| `UBUNTU_VERSION` | `24.04` | Base image version |
| `GCC_VERSION` | `14` | GCC/G++ version from the Ubuntu archive, for example `13` |
| `USER_UID` | `1000` | UID of the `cppdev` user |
| `USER_GID` | `1000` | GID of the `cppdev` user |
| `INSTALL_EXTRA_TOOLS` | `false` | Install optional tooling |
| `NANORC_REF` | pinned commit | Nano syntax highlighting revision |

Example for a host user with a different UID or GID:

```bash
docker build \
  --build-arg USER_UID="$(id -u)" \
  --build-arg USER_GID="$(id -g)" \
  -t cppdev:local .
```

On Linux, bind-mounted files keep their ownership. If the container user does not match your host UID and GID, files in `/workspace` may become owned by the wrong user. Build with matching IDs or run with `--user "$(id -u):$(id -g)"`.

## Dev container

The repository includes a complete `.devcontainer/devcontainer.json`:

1. Install the Dev Containers extension in VS Code.
2. Open the repository.
3. Run **Dev Containers: Reopen in Container**.

The configuration:

- builds `devcontainer.Dockerfile` on top of `brakmic/cppdev:latest`,
- sets `cppdev` as the remote user,
- mounts the workspace at `/workspace`,
- mounts the host Docker socket and makes it accessible to the container user,
- installs the C/C++ and EditorConfig extensions.

To build the dev container on a locally built base image, add a build argument to the `build` section of `.devcontainer/devcontainer.json`:

```json
"args": { "BASE_IMAGE": "cppdev:local" }
```

### Docker socket access

Mounting `/var/run/docker.sock` gives the container access to the host Docker daemon. The post-start command adjusts the socket permissions so the non-root user can run Docker commands. This is convenient for local development, but it means the container can control Docker on the host. Do not use this configuration with untrusted code or on shared machines. If you prefer group-based access, create the container's `docker` group with the host socket GID and add `cppdev` to it instead of changing the socket permissions.

## Example project

`examples/cmake-hello` is a small C++23 project with CMake presets, Ninja, CTest, and a sanitizer preset:

```bash
cd examples/cmake-hello
cmake --preset release
cmake --build --preset release
ctest --preset release
```

The `debug` preset exports `compile_commands.json`, and the `sanitize` preset enables AddressSanitizer and UndefinedBehaviorSanitizer. See `examples/cmake-hello/README.md`.

## Make targets

| Target | Description |
| --- | --- |
| `make build` | Build the base image for the local architecture |
| `make build-extra` | Build the base image with optional tooling |
| `make devcontainer` | Build the dev container image on top of the base image |
| `make smoke` | Run the smoke test against the built image |
| `make buildx` | Build a multi-architecture image without pushing |
| `make publish` | Build and push a multi-architecture image |

Variables: `IMAGE`, `TAG`, `PLATFORMS`, `EXTRA_TOOLS`, and `DEVCONTAINER_TAG`.

## Smoke tests

The smoke tests check the compiler version, core tools, the non-root user, passwordless sudo, the shell environment, Python venv support, nano syntax files, and a full configure, build, and test cycle of the example project.

Bash or zsh:

```bash
bash scripts/smoke-test.sh cppdev:local 14
```

PowerShell:

```powershell
.\scripts\smoke-test.ps1 -Image cppdev:local -ExpectedGccMajor 14
```

## Python packages

Ubuntu 24.04 marks the system Python as externally managed (PEP 668), so `pip install` outside a virtual environment fails. Use a virtual environment for application dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install <package>
```

For command-line tools, install `pipx` with the optional tooling build and run `pipx install <package>`.

## Releasing

The CI workflow builds and smoke tests both images on every push and pull request. Pushing a tag that starts with `v`, for example `v1.1.0`, publishes:

- `brakmic/cppdev` and `ghcr.io/<owner>/cppdev` for `linux/amd64` and `linux/arm64`,
- `brakmic/cppdev:devcontainer` and `ghcr.io/<owner>/cppdev:devcontainer`.

Docker Hub publishing requires `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`. Store them as environment secrets in a `release` environment with required reviewers. The publish job runs in that environment, so tag releases wait for approval before the credentials are released. If either secret is missing, only GHCR is published. GHCR publishing uses the built-in, short-lived `GITHUB_TOKEN`.

Use a dedicated Docker Hub personal access token with read and write permissions only. Do not grant delete or account administration permissions. Set an expiration where possible and rotate the token regularly.

## Platform notes

- The release workflow builds `linux/amd64` and `linux/arm64` images.
- If you pull an image that only contains `linux/amd64`, run it on ARM hosts with `--platform linux/amd64`. Emulation is slower and some tools may behave differently.
- Third-party downloads are pinned and verified where possible. Updates are intentional and reviewed.

## Security notes

- The `cppdev` user has passwordless sudo, which is convenient in a development container but not appropriate for shared or production hosts.
- The dev container mounts the host Docker socket. Any process in the container can control the host Docker daemon. Use it only with code you trust.
- The image is a development environment, not a hardened runtime image.
- The Docker Hub token is passed only to the login step and is never exported as a job-wide environment variable.
- GitHub Actions used by the workflow are pinned to commit SHAs.
- The publish job has `packages: write` permission only in the release job; the build job is read-only.
- Enable secret scanning and push protection for the repository to catch accidental credential commits.

## Troubleshooting

**Docker socket permission denied in the dev container.** The post-start command adjusts the socket permissions. If you disabled it, add the container user to a group that matches the host socket GID, or run `sudo chmod 666 /var/run/docker.sock` inside the container.

**Files in `/workspace` have unexpected ownership.** Rebuild with `USER_UID` and `USER_GID` matching your host user, or run with `--user "$(id -u):$(id -g)"`.

**SELinux denies access to mounted files (Fedora, RHEL).** Add the `:z` option to the volume mount.

**`pip install` fails with an externally managed environment error.** Use a virtual environment or `pipx` as described above.

**Locale warnings during custom builds.** The base image generates `en_US.UTF-8` and exports `LANG` and `LC_ALL`. Make sure the `locales` package is installed before running `locale-gen` when you modify the build.

## Third-party content

The image contains third-party components with their own licenses. See [THIRD-PARTY.md](./THIRD-PARTY.md). In particular, the nano syntax highlighting files come from the nanorc project and are licensed under GPL-3.0-or-later; the license text is included in the image at `/usr/share/doc/nanorc-syntax/LICENSE`.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE)

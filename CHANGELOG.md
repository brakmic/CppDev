# Changelog

All notable changes to this project are documented here. The format follows Keep a Changelog, and the project uses semantic versioning.

## [Unreleased]

### Added

- Dev container configuration in `.devcontainer/devcontainer.json` with a workspace mount, Docker socket access, and C/C++ extensions.
- CMake example project with release, debug, and sanitizer presets plus CTest.
- CI workflow that builds both images, runs smoke tests, and publishes multi-architecture images on version tags.
- Dependabot configuration for GitHub Actions and Docker.
- Optional tooling build argument covering clang-format, clang-tidy, Cppcheck, gcovr, gdbserver, lcov, Meson, and pipx.
- Build arguments for the Ubuntu version, GCC version, user UID, and user GID.
- Bash and PowerShell smoke test scripts.
- Makefile targets for building, testing, and publishing images.
- Third-party notice and contributing guide.
- `ccache` in the base image.
- `python3-venv` in the base image.

### Changed

- Docker Hub publishing requires both `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`; if either is missing, Docker Hub steps are skipped.
- The shell environment exports `EDITOR` and `VISUAL` in interactive shells, and login shells now load `.bashrc` through `.bash_profile`.
- Package installation runs non-interactively with `apt-get` and removes package lists after every step.
- Locale variables are set after the locale is generated.
- Compiler alternatives use the version selected by `GCC_VERSION`.
- Nano syntax highlighting is pinned to a fixed upstream commit, and the GPL license text is copied into the image.
- The devcontainer Dockerfile uses a configurable `BASE_IMAGE`.
- lsd is updated to 1.2.0 and verified with SHA-256 checksums for amd64 and arm64.
- The Docker repository key is stored in `/etc/apt/keyrings`, and the codename is read from `/etc/os-release`.
- `TERM` is no longer set in the image.

### Fixed

- `EDITOR=nano` did not take effect in the default interactive shell, and login shells lost the Bash configuration.
- The devcontainer image could not be used by VS Code without a devcontainer configuration.
- Builds could hang on interactive package prompts.
- `pip install` failed on Ubuntu 24.04 without virtual environment support.
- The default Ubuntu user at UID/GID 1000 conflicted with the requested `cppdev` IDs.
- Missing `.dockerignore` sent repository internals as build context.

### Removed

- The empty `.vscode/settings.json` was replaced by machine-local settings that git ignores.

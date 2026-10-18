# Contributing

## Build and test

Build the base image, the devcontainer image, and run the smoke test:

```bash
make build
make devcontainer
make smoke
```

Or run the commands directly:

```bash
docker build -t cppdev:local .
docker build -f devcontainer.Dockerfile --build-arg BASE_IMAGE=cppdev:local -t cppdev:local-devcontainer .
bash scripts/smoke-test.sh cppdev:local
```

On Windows, use `scripts/smoke-test.ps1`.

The optional tooling variant is part of the test surface:

```bash
docker build --build-arg INSTALL_EXTRA_TOOLS=true -t cppdev:extra .
```

## Updating pinned dependencies

- Nano syntax files: update `NANORC_REF` in the Dockerfile to a reviewed upstream commit.
- lsd: update `LSD_VERSION` and both SHA-256 values in `devcontainer.Dockerfile`. Compute them from the published `.deb` files for amd64 and arm64.
- Ubuntu base: update `UBUNTU_VERSION` and run the full smoke test.

## Pull requests

- Keep the Dockerfiles reproducible: pin external downloads and verify checksums.
- Do not add machine-specific paths, hostnames, credentials, or personal configuration to tracked files.
- Keep `.vscode/` and other editor state machine-local; it is ignored by git.
- Update `README.md` and `CHANGELOG.md` for user-visible changes.
- Run `make build`, `make devcontainer`, and `make smoke` before opening a pull request.

## Commit messages

Use an imperative subject line that starts with a verb, for example `Add arm64 release builds`. Keep the subject free of parentheses and semicolons. Describe the reason for the change in the body when it is not obvious.

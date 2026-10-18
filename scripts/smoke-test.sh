#!/usr/bin/env bash
set -euo pipefail

image="${1:-brakmic/cppdev:latest}"
expected_gcc_major="${2:-14}"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

run() {
    docker run --rm "$image" "$@"
}

echo "Smoke testing ${image}"

gcc_version="$(run gcc -dumpfullversion)"
gpp_version="$(run g++ -dumpfullversion)"
cmake_version="$(run cmake --version)"
cmake_version="${cmake_version%%$'\n'*}"
ninja_version="$(run ninja --version)"

echo "gcc:   ${gcc_version}"
echo "g++:   ${gpp_version}"
echo "cmake: ${cmake_version}"
echo "ninja: ${ninja_version}"

case "${gcc_version}" in
    "${expected_gcc_major}".*) ;;
    *) fail "expected GCC ${expected_gcc_major}, found ${gcc_version}" ;;
esac

case "${gpp_version}" in
    "${expected_gcc_major}".*) ;;
    *) fail "expected G++ ${expected_gcc_major}, found ${gpp_version}" ;;
esac

for tool in make valgrind gdb strace git ccache python3; do
    if ! run "$tool" --version >/dev/null 2>&1; then
        run "$tool" -V >/dev/null 2>&1 || fail "missing ${tool}"
    fi
done

[ "$(run id -un)" = "cppdev" ] || fail "expected user cppdev"
run bash -lc 'sudo -n true' || fail "passwordless sudo is not available"
[ "$(run bash -lic 'printf %s "$EDITOR"' 2>/dev/null)" = "nano" ] || fail "EDITOR is not set in an interactive login shell"

interactive_editor="$(run bash -ic 'printf %s "$EDITOR"' 2>/dev/null)"
[ "${interactive_editor}" = "nano" ] || fail "EDITOR is not set in an interactive shell"

run bash -lc 'python3 -m venv /tmp/venv-check && /tmp/venv-check/bin/python -m pip --version >/dev/null'
run bash -lc 'grep -q nano-syntax /etc/nanorc && test -f /usr/share/doc/nanorc-syntax/LICENSE'

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workdir="$(mktemp -d)"

cleanup() {
    # Build output is owned by the container user, so remove it from inside
    # the container before deleting the host directory.
    docker run --rm -v "${workdir}:/workspace" "$image" rm -rf /workspace/build >/dev/null 2>&1 || true
    rm -rf "${workdir}"
}
trap cleanup EXIT

cp -a "${repo_root}/examples/cmake-hello/." "${workdir}/"
chmod -R a+rwX "${workdir}"

echo "Building examples/cmake-hello with the release preset"
docker run --rm -v "${workdir}:/workspace" -w /workspace "$image" \
    bash -lc 'cmake --preset release && cmake --build --preset release && ctest --preset release'

echo "Smoke test passed."

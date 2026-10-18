# Security policy

## Supported versions

The latest tagged release and the `main` branch receive security fixes. Older tags may not receive updates.

## Reporting a vulnerability

Do not open a public issue for a security problem. Report it privately through [GitHub private vulnerability reporting](https://github.com/brakmic/CppDev/security/advisories/new).

Include the affected image tag, reproduction steps, and impact. Acknowledgement and follow-up are provided on a best-effort basis.

## Scope

The images are development environments, not hardened production runtimes. The following are intentional and are not vulnerabilities by themselves:

- Passwordless sudo for the `cppdev` user.
- The dev container mounts the host Docker socket.
- The images include compilers, debuggers, and network tools.

Reports about the build, the release workflow, pinned third-party downloads, or credential handling are in scope.

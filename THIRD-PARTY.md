# Third-party notices

The images bundle third-party software. The licenses below apply to those components, not to this repository's own code, which is MIT licensed.

| Component | License | Notes |
| --- | --- | --- |
| Ubuntu 24.04 and distribution packages | Various free software licenses | Package copyright information is available in `/usr/share/doc/<package>/copyright` inside the image. |
| GCC, CMake, Ninja, GDB, Valgrind, Git, Python, and other Ubuntu packages | Various free software licenses | Distributed as part of Ubuntu. |
| nanorc syntax highlighting files | GPL-3.0-or-later | Pinned commit `1aa64a86cf4c750e4d4788ef1a19d7a71ab641dd`; license text at `/usr/share/doc/nanorc-syntax/LICENSE`. |
| lsd 1.2.0 | Apache-2.0 | Downloaded from the upstream GitHub release and verified with SHA-256. |
| Node.js | MIT | Installed in the devcontainer image from NodeSource. |
| Global npm packages | Various licenses | typescript, tsx, node-gyp, yarn, nodemon, and eslint. |
| Docker Engine, CLI, and plugins | Apache-2.0 | Installed in the devcontainer image. |
| VS Code extensions referenced by `.devcontainer/devcontainer.json` | Various licenses | Installed by VS Code at container creation, not bundled in the image. |

No third-party source is modified by this repository.

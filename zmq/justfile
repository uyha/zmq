gen-options:
  #!/usr/bin/env bash

  set -euo pipefail

  cd {{justfile_directory()}}/tools
  uv run "{{justfile_directory()}}/tools/gen-ctxopt.py" > \
    "{{justfile_directory()}}/src/context/option.zig"

  uv run "{{justfile_directory()}}/tools/gen-sockopt.py" > \
    "{{justfile_directory()}}/src/socket/option.zig"

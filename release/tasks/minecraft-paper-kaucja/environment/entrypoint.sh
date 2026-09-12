#!/bin/bash
set -euo pipefail

if [ "${1:-}" = "verify" ]; then
    # Forge mounts the candidate workspace separately from the image. Keep
    # the verifier's /app contract while ensuring only that mounted workspace
    # is executed.
    cp -a /workspace/desktop/. /app/
    exec python3 /tests/verify.py
fi

exec "$@"

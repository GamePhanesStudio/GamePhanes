#!/bin/bash
set -euo pipefail

if [ "${1:-}" = "verify" ]; then
    cp -a /workspace/desktop/. /app/
    exec python3 /tests/verify.py
fi

exec "$@"

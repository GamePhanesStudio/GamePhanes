#!/bin/sh
set -eu
if python -m pytest /app/tests/test_outputs.py -q; then
  mkdir -p /logs/verifier
  printf '1\n' > /logs/verifier/reward.txt
else
  mkdir -p /logs/verifier
  printf '0\n' > /logs/verifier/reward.txt
fi

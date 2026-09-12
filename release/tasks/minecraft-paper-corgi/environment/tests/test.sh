#!/bin/sh
set -eu
mkdir -p /logs/verifier
if TASK_OUTPUT_ROOT=/app RUBRIC_PATH=/tests/rubric.yaml python3 -m pytest /tests/test_outputs.py -q; then
  printf '1\n' > /logs/verifier/reward.txt
else
  printf '0\n' > /logs/verifier/reward.txt
fi

#!/usr/bin/env bash
set -euo pipefail

RESULT_DIR="/logs/verifier"
mkdir -p "$RESULT_DIR"

pass=0
total=1

g++ -std=c++17 -I /app /tests/prediction_probe.cpp -o /tmp/prediction_probe 2>/dev/null
if /tmp/prediction_probe 2>&1 | grep -q "CPP_PREDICTION_PROBE_OK"; then
    pass=1
fi

if [ "$pass" -eq 1 ]; then probe_passed=true; else probe_passed=false; fi

cat > "$RESULT_DIR/result.json" <<JSON
{"status":"evaluated","reward":$( awk "BEGIN{printf \"%.1f\",$pass/$total}" ),"score":$( awk "BEGIN{printf \"%.1f\",$pass/$total}" ),"passed":$pass,"total":$total,"checks":[{"id":"prediction_probe","passed":$probe_passed}]}
JSON
awk "BEGIN{printf \"%.1f\n\",$pass/$total}" > "$RESULT_DIR/reward.txt"

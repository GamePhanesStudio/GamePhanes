#!/usr/bin/env bash
set -euo pipefail

RESULT_DIR="/logs/verifier"
mkdir -p "$RESULT_DIR"

pass=0
total=1

cp /tests/runtime_probe.gd /app/runtime_probe.gd
PROBE_OUT=$(godot --headless --path /app --script /app/runtime_probe.gd 2>&1 || true)
rm -f /app/runtime_probe.gd

if echo "$PROBE_OUT" | grep -q "VEHICLE_EFFECTS_PROBE_OK"; then
    pass=1
fi

if [ "$pass" -eq 1 ]; then probe_passed=true; else probe_passed=false; fi

cat > "$RESULT_DIR/result.json" <<JSON
{"status":"evaluated","reward":$(awk "BEGIN{printf \"%.1f\",$pass/$total}"),"score":$(awk "BEGIN{printf \"%.1f\",$pass/$total}"),"passed":$pass,"total":$total,"checks":[{"id":"vehicle_effects_probe","passed":$probe_passed}]}
JSON
awk "BEGIN{printf \"%.1f\n\",$pass/$total}" > "$RESULT_DIR/reward.txt"

#!/bin/sh
set -u

MODE="${1:-run}"
if [ "$MODE" = "verify" ]; then
    WORKSPACE="${3:?verify requires a workspace path}"
    RESULT_PATH="${4:?verify requires a result path}"
else
    WORKSPACE="${TASK_OUTPUT_ROOT:-/app}"
    RESULT_PATH="${RESULT_PATH:-/logs/verifier/result.json}"
fi

RESULT_DIR=$(dirname "$RESULT_PATH")
mkdir -p "$RESULT_DIR"
PARSE_LOG="$RESULT_DIR/godot-import.log"
RUNTIME_LOG="$RESULT_DIR/godot-runtime.log"
PROBE="$WORKSPACE/.gameforgebench_night_zone_probe.gd"

N_CHECKPOINTS=5

cleanup() { rm -f "$PROBE"; }
trap cleanup EXIT INT TERM

# --- Structural guards (early-exit only; do NOT contribute to PASSED or SCORE) ---

if ! { [ -f "$WORKSPACE/project.godot" ] && [ -f "$WORKSPACE/Main.tscn" ] && [ -f "$WORKSPACE/scripts/night_zone.gd" ]; }; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"night_zone_cp1","passed":false,"detail":"scene load and night_mode toggle","type":"godot_probe"},{"id":"night_zone_cp2","passed":false,"detail":"landmarks and weapons shape","type":"godot_probe"},{"id":"night_zone_cp3","passed":false,"detail":"enemy spawn scaling","type":"godot_probe"},{"id":"night_zone_cp4","passed":false,"detail":"path cost and boundary clamping","type":"godot_probe"},{"id":"night_zone_runtime","passed":false,"detail":"snapshot isolation and full probe success","type":"godot_probe"}]}
EOF
    printf '0\n' >"$RESULT_DIR/reward.txt"
    exit 0
fi

if ! timeout 120 godot --headless --path "$WORKSPACE" --editor --quit >"$PARSE_LOG" 2>&1; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"night_zone_cp1","passed":false,"detail":"scene load and night_mode toggle","type":"godot_probe"},{"id":"night_zone_cp2","passed":false,"detail":"landmarks and weapons shape","type":"godot_probe"},{"id":"night_zone_cp3","passed":false,"detail":"enemy spawn scaling","type":"godot_probe"},{"id":"night_zone_cp4","passed":false,"detail":"path cost and boundary clamping","type":"godot_probe"},{"id":"night_zone_runtime","passed":false,"detail":"snapshot isolation and full probe success","type":"godot_probe"}]}
EOF
    printf '0\n' >"$RESULT_DIR/reward.txt"
    exit 0
fi

if grep -Eq 'SCRIPT ERROR|Parse Error|Failed to load script|Cannot open file' "$PARSE_LOG"; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"night_zone_cp1","passed":false,"detail":"scene load and night_mode toggle","type":"godot_probe"},{"id":"night_zone_cp2","passed":false,"detail":"landmarks and weapons shape","type":"godot_probe"},{"id":"night_zone_cp3","passed":false,"detail":"enemy spawn scaling","type":"godot_probe"},{"id":"night_zone_cp4","passed":false,"detail":"path cost and boundary clamping","type":"godot_probe"},{"id":"night_zone_runtime","passed":false,"detail":"snapshot isolation and full probe success","type":"godot_probe"}]}
EOF
    printf '0\n' >"$RESULT_DIR/reward.txt"
    exit 0
fi

scene_ok=true
if ! { [ "$(grep -Fc '[node name="Landmark" type="Node2D" parent="."]' "$WORKSPACE/Main.tscn" 2>/dev/null || true)" -eq 1 ] &&
       grep -Fq '[node name="Weapon" type="Node2D" parent="."]' "$WORKSPACE/Main.tscn" &&
       grep -Fq '[node name="EnemySpawner" type="Node2D" parent="."]' "$WORKSPACE/Main.tscn" &&
       grep -Fq '[node name="NavigationRegion" type="Node2D" parent="."]' "$WORKSPACE/Main.tscn"; }; then
    scene_ok=false
fi

if [ "$scene_ok" = false ]; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"night_zone_cp1","passed":false,"detail":"scene load and night_mode toggle","type":"godot_probe"},{"id":"night_zone_cp2","passed":false,"detail":"landmarks and weapons shape","type":"godot_probe"},{"id":"night_zone_cp3","passed":false,"detail":"enemy spawn scaling","type":"godot_probe"},{"id":"night_zone_cp4","passed":false,"detail":"path cost and boundary clamping","type":"godot_probe"},{"id":"night_zone_runtime","passed":false,"detail":"snapshot isolation and full probe success","type":"godot_probe"}]}
EOF
    printf '0\n' >"$RESULT_DIR/reward.txt"
    exit 0
fi

# --- Run the probe and collect checkpoint signals ---

cp /grader/tests/night_zone_probe.gd "$PROBE"
timeout 120 godot --headless --path "$WORKSPACE" --script "$PROBE" >"$RUNTIME_LOG" 2>&1 || true

cp1=false; cp2=false; cp3=false; cp4=false; cpfinal=false
grep -Fq 'NIGHT_ZONE_RUNTIME_CP1_OK'  "$RUNTIME_LOG" && cp1=true
grep -Fq 'NIGHT_ZONE_RUNTIME_CP2_OK'  "$RUNTIME_LOG" && cp2=true
grep -Fq 'NIGHT_ZONE_RUNTIME_CP3_OK'  "$RUNTIME_LOG" && cp3=true
grep -Fq 'NIGHT_ZONE_RUNTIME_CP4_OK'  "$RUNTIME_LOG" && cp4=true
grep -Fq 'NIGHT_ZONE_RUNTIME_OK'       "$RUNTIME_LOG" && cpfinal=true

PASSED=0
[ "$cp1"     = true ] && PASSED=$((PASSED + 1))
[ "$cp2"     = true ] && PASSED=$((PASSED + 1))
[ "$cp3"     = true ] && PASSED=$((PASSED + 1))
[ "$cp4"     = true ] && PASSED=$((PASSED + 1))
[ "$cpfinal" = true ] && PASSED=$((PASSED + 1))

[ "$PASSED" -eq "$N_CHECKPOINTS" ] && REWARD=1 || REWARD=0
case "$PASSED" in
    0) SCORE=0.0 ;;
    1) SCORE=0.2 ;;
    2) SCORE=0.4 ;;
    3) SCORE=0.6 ;;
    4) SCORE=0.8 ;;
    *) SCORE=1.0 ;;
esac

cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":$REWARD,"score":$SCORE,"passed":$PASSED,"total":$N_CHECKPOINTS,"checks":[{"id":"night_zone_cp1","passed":$cp1,"detail":"scene load and night_mode toggle","type":"godot_probe"},{"id":"night_zone_cp2","passed":$cp2,"detail":"landmarks and weapons shape","type":"godot_probe"},{"id":"night_zone_cp3","passed":$cp3,"detail":"enemy spawn scaling","type":"godot_probe"},{"id":"night_zone_cp4","passed":$cp4,"detail":"path cost and boundary clamping","type":"godot_probe"},{"id":"night_zone_runtime","passed":$cpfinal,"detail":"snapshot isolation and full probe success","type":"godot_probe"}]}
EOF
printf '%s\n' "$REWARD" >"$RESULT_DIR/reward.txt"
exit 0

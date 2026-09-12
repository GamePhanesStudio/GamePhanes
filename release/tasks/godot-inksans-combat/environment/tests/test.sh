#!/usr/bin/env bash
set -euo pipefail

WORKSPACE=/app
RESULT_DIR=/logs/verifier
RESULT_PATH="$RESULT_DIR/result.json"
REWARD_PATH="$RESULT_DIR/reward.txt"
PARSE_LOG="$RESULT_DIR/godot-import.log"
RUNTIME_LOG="$RESULT_DIR/godot-runtime.log"
PROBE="$WORKSPACE/.gameforgebench_ink_sans_probe.gd"

mkdir -p "$RESULT_DIR"
printf '0\n' >"$REWARD_PATH"
trap 'rm -f "$PROBE"' EXIT HUP INT TERM

N_CHECKPOINTS=5

# --- Structural guards (early-exit only, do NOT count toward score) ---

if [ ! -f "$WORKSPACE/scripts/ink_sans_state.gd" ]; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":false,"detail":"API shape: scene load, node, signals","type":"godot_probe"},{"id":"cp2","passed":false,"detail":"Initial state and valid damage hit","type":"godot_probe"},{"id":"cp3","passed":false,"detail":"Damage guards: invalid, lethal, post-death","type":"godot_probe"},{"id":"cp4","passed":false,"detail":"Signals, snapshot isolation, reset","type":"godot_probe"},{"id":"cp5","passed":false,"detail":"Multi-instance state isolation","type":"godot_probe"}]}
EOF
    exit 0
fi

if ! grep -Fq '[node name="InkSansState" type="Node" parent="."]' "$WORKSPACE/Main.tscn" 2>/dev/null; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":false,"detail":"API shape: scene load, node, signals","type":"godot_probe"},{"id":"cp2","passed":false,"detail":"Initial state and valid damage hit","type":"godot_probe"},{"id":"cp3","passed":false,"detail":"Damage guards: invalid, lethal, post-death","type":"godot_probe"},{"id":"cp4","passed":false,"detail":"Signals, snapshot isolation, reset","type":"godot_probe"},{"id":"cp5","passed":false,"detail":"Multi-instance state isolation","type":"godot_probe"}]}
EOF
    exit 0
fi

if [ ! -f "$WORKSPACE/project.godot" ] || [ ! -f "$WORKSPACE/Main.tscn" ]; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":false,"detail":"API shape: scene load, node, signals","type":"godot_probe"},{"id":"cp2","passed":false,"detail":"Initial state and valid damage hit","type":"godot_probe"},{"id":"cp3","passed":false,"detail":"Damage guards: invalid, lethal, post-death","type":"godot_probe"},{"id":"cp4","passed":false,"detail":"Signals, snapshot isolation, reset","type":"godot_probe"},{"id":"cp5","passed":false,"detail":"Multi-instance state isolation","type":"godot_probe"}]}
EOF
    exit 0
fi

if ! timeout 120 godot --headless --path "$WORKSPACE" --editor --quit >"$PARSE_LOG" 2>&1; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":false,"detail":"API shape: scene load, node, signals","type":"godot_probe"},{"id":"cp2","passed":false,"detail":"Initial state and valid damage hit","type":"godot_probe"},{"id":"cp3","passed":false,"detail":"Damage guards: invalid, lethal, post-death","type":"godot_probe"},{"id":"cp4","passed":false,"detail":"Signals, snapshot isolation, reset","type":"godot_probe"},{"id":"cp5","passed":false,"detail":"Multi-instance state isolation","type":"godot_probe"}]}
EOF
    exit 0
fi

if grep -Eq 'SCRIPT ERROR|Parse Error|Failed to load script|Cannot open file' "$PARSE_LOG"; then
    cat >"$RESULT_PATH" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":false,"detail":"API shape: scene load, node, signals","type":"godot_probe"},{"id":"cp2","passed":false,"detail":"Initial state and valid damage hit","type":"godot_probe"},{"id":"cp3","passed":false,"detail":"Damage guards: invalid, lethal, post-death","type":"godot_probe"},{"id":"cp4","passed":false,"detail":"Signals, snapshot isolation, reset","type":"godot_probe"},{"id":"cp5","passed":false,"detail":"Multi-instance state isolation","type":"godot_probe"}]}
EOF
    exit 0
fi

# --- Runtime probe ---

cp /tests/runtime_probe.gd "$PROBE"
timeout 120 godot --headless --path "$WORKSPACE" --script "$PROBE" >"$RUNTIME_LOG" 2>&1 || true

# --- Score checkpoints ---

cp1=false; cp2=false; cp3=false; cp4=false; cp5=false
grep -Fq 'INK_SANS_SCENE_RUNTIME_CP1_OK' "$RUNTIME_LOG" && cp1=true
grep -Fq 'INK_SANS_SCENE_RUNTIME_CP2_OK' "$RUNTIME_LOG" && cp2=true
grep -Fq 'INK_SANS_SCENE_RUNTIME_CP3_OK' "$RUNTIME_LOG" && cp3=true
grep -Fq 'INK_SANS_SCENE_RUNTIME_CP4_OK' "$RUNTIME_LOG" && cp4=true
grep -Fq 'INK_SANS_SCENE_RUNTIME_OK'     "$RUNTIME_LOG" && cp5=true

PASSED=0
[ "$cp1" = true ] && PASSED=$((PASSED + 1))
[ "$cp2" = true ] && PASSED=$((PASSED + 1))
[ "$cp3" = true ] && PASSED=$((PASSED + 1))
[ "$cp4" = true ] && PASSED=$((PASSED + 1))
[ "$cp5" = true ] && PASSED=$((PASSED + 1))

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
{"status":"evaluated","reward":$REWARD,"score":$SCORE,"passed":$PASSED,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":$cp1,"detail":"API shape: scene load, node, signals","type":"godot_probe"},{"id":"cp2","passed":$cp2,"detail":"Initial state and valid damage hit","type":"godot_probe"},{"id":"cp3","passed":$cp3,"detail":"Damage guards: invalid, lethal, post-death","type":"godot_probe"},{"id":"cp4","passed":$cp4,"detail":"Signals, snapshot isolation, reset","type":"godot_probe"},{"id":"cp5","passed":$cp5,"detail":"Multi-instance state isolation","type":"godot_probe"}]}
EOF
printf '%s\n' "$REWARD" >"$REWARD_PATH"
exit 0

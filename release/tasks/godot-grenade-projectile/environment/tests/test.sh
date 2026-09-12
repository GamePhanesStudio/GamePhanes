#!/usr/bin/env bash
set -euo pipefail

WORKSPACE=/app
RESULT_DIR=/logs/verifier
PROBE="$WORKSPACE/.gameforgebench_grenade_probe.gd"
mkdir -p "$RESULT_DIR"
printf '0\n' > "$RESULT_DIR/reward.txt"
trap 'rm -f "$PROBE"' EXIT HUP INT TERM

N_CHECKPOINTS=5

fail_early() {
    cat > "$RESULT_DIR/result.json" <<EOF
{"status":"evaluated","reward":0,"score":0.0,"passed":0,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":false,"detail":"scene API shape","type":"godot_probe"},{"id":"cp2","passed":false,"detail":"projectile movement","type":"godot_probe"},{"id":"cp3","passed":false,"detail":"burn pool lifecycle","type":"godot_probe"},{"id":"cp4","passed":false,"detail":"edge case rejection","type":"godot_probe"},{"id":"cp5","passed":false,"detail":"smoke state, counts, and reset","type":"godot_probe"}]}
EOF
    printf '0\n' > "$RESULT_DIR/reward.txt"
    exit 0
}

# --- structural guards (no score contribution) ---
[ -f "$WORKSPACE/Main.tscn" ] || fail_early
[ -f "$WORKSPACE/scripts/grenade_physics.gd" ] || fail_early
grep -Fq 'func throw_grenade' "$WORKSPACE/scripts/grenade_physics.gd" || fail_early
grep -Fq 'func advance_burn_pool' "$WORKSPACE/scripts/grenade_physics.gd" || fail_early

if [ -f "$WORKSPACE/project.godot" ]; then
    if ! timeout 120 godot --headless --path "$WORKSPACE" --editor --quit > "$RESULT_DIR/godot-import.log" 2>&1; then
        fail_early
    fi
    if grep -Eq 'SCRIPT ERROR|Parse Error|Failed to load script|Cannot open file' "$RESULT_DIR/godot-import.log"; then
        fail_early
    fi
else
    fail_early
fi

# --- runtime probe ---
cp /tests/runtime_probe.gd "$PROBE"
timeout 120 godot --headless --path "$WORKSPACE" --script "$(basename "$PROBE")" > "$RESULT_DIR/godot-runtime.log" 2>&1 || true

# --- count checkpoint signals ---
cp1=false; cp2=false; cp3=false; cp4=false; cp5=false
grep -Fq 'GRENADE_SCENE_PROBE_CP1_OK' "$RESULT_DIR/godot-runtime.log" && cp1=true
grep -Fq 'GRENADE_SCENE_PROBE_CP2_OK' "$RESULT_DIR/godot-runtime.log" && cp2=true
grep -Fq 'GRENADE_SCENE_PROBE_CP3_OK' "$RESULT_DIR/godot-runtime.log" && cp3=true
grep -Fq 'GRENADE_SCENE_PROBE_CP4_OK' "$RESULT_DIR/godot-runtime.log" && cp4=true
grep -Fq 'GRENADE_SCENE_PROBE_OK'     "$RESULT_DIR/godot-runtime.log" && cp5=true

passed=0
[ "$cp1" = true ] && passed=$((passed + 1))
[ "$cp2" = true ] && passed=$((passed + 1))
[ "$cp3" = true ] && passed=$((passed + 1))
[ "$cp4" = true ] && passed=$((passed + 1))
[ "$cp5" = true ] && passed=$((passed + 1))

[ "$passed" -eq "$N_CHECKPOINTS" ] && reward=1 || reward=0

case "$passed" in
    0) score="0.0" ;;
    1) score="0.2" ;;
    2) score="0.4" ;;
    3) score="0.6" ;;
    4) score="0.8" ;;
    *) score="1.0" ;;
esac

cat > "$RESULT_DIR/result.json" <<EOF
{"status":"evaluated","reward":$reward,"score":$score,"passed":$passed,"total":$N_CHECKPOINTS,"checks":[{"id":"cp1","passed":$cp1,"detail":"scene API shape","type":"godot_probe"},{"id":"cp2","passed":$cp2,"detail":"projectile movement","type":"godot_probe"},{"id":"cp3","passed":$cp3,"detail":"burn pool lifecycle","type":"godot_probe"},{"id":"cp4","passed":$cp4,"detail":"edge case rejection","type":"godot_probe"},{"id":"cp5","passed":$cp5,"detail":"smoke state, counts, and reset","type":"godot_probe"}]}
EOF
printf '%s\n' "$reward" > "$RESULT_DIR/reward.txt"

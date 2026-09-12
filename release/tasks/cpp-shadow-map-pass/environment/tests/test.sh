#!/usr/bin/env bash
set -euo pipefail

RESULT_DIR="/logs/verifier"
mkdir -p "$RESULT_DIR"

WORKDIR="/app"
PROBE_SRC="/app/gfb042_probe.cpp"
PROBE_BIN="/tmp/gfb042_probe"

pass=0
total=1

emit_result() {
    local status="evaluated"
    local reward
    reward=$(awk "BEGIN{printf \"%.1f\", $pass/$total}")
    cat > "$RESULT_DIR/result.json" <<JSON
{"status":"$status","reward":$reward,"score":$reward,"passed":$pass,"total":$total,"checks":[{"id":"shadow_runtime_probe","passed":$( [ "$pass" -eq 1 ] && echo true || echo false )}]}
JSON
    echo "$reward" > "$RESULT_DIR/reward.txt"
}

# Write the verifier-owned probe to disk
cat > "$PROBE_SRC" <<'PROBE_EOF'
#include "engine/include/kay/scene/scene.h"
#include "engine/src/scene/scene.cpp"
#include <cmath>
#include <iostream>
#include <vector>

using kay::frame_snapshot;
using kay::light_type;
using kay::matrix4x4;
using kay::render_event;
using kay::scene;
using kay::scene_light;
using kay::shadow_caster;
using kay::shadow_params;

static bool close(float a, float b) { return std::fabs(a - b) < 0.00001f; }

static bool events_equal(const frame_snapshot& value, const std::vector<render_event>& expected) {
    return value.events == expected;
}

int main() {
    scene world;
    scene_light point{};
    point.index = 2;
    point.type = light_type::point;
    point.active = true;
    point.casts_shadows = true;
    world.add_light(point);

    scene_light sun{};
    sun.index = 7;
    sun.type = light_type::directional;
    sun.active = true;
    sun.casts_shadows = true;
    sun.shadow_vp = matrix4x4::identity();
    sun.shadow_vp.m[12] = 4.0f;
    sun.shadow = shadow_params{0.75f, 0.002f, 1024.0f, 99};
    world.add_light(sun);
    world.add_caster(shadow_caster{true, true});
    world.add_caster(shadow_caster{false, true});
    world.add_caster(shadow_caster{true, false});
    world.render();

    frame_snapshot rendered = kay::graphics::snapshot();
    if (rendered.shadow_pass_active || !rendered.shadow_ready) return 10;
    if (rendered.light_index != 7 || rendered.params.light_index != 7) return 11;
    if (rendered.caster_count != 1 || rendered.lighting_count != 1) return 12;
    if (!close(rendered.shadow_vp.m[12], 4.0f) || !close(rendered.params.strength, 0.75f)) return 13;
    if (!events_equal(rendered, {
        render_event::shadow_pass_begin,
        render_event::shadow_vp_uploaded,
        render_event::shadow_params_uploaded,
        render_event::shadow_caster_drawn,
        render_event::shadow_pass_end,
        render_event::lighting_applied,
    })) return 14;

    scene no_shadow;
    sun.active = false;
    no_shadow.add_light(sun);
    no_shadow.add_caster(shadow_caster{true, true});
    no_shadow.render();
    frame_snapshot isolated = kay::graphics::snapshot();
    if (isolated.shadow_ready || isolated.shadow_pass_active) return 20;
    if (isolated.light_index != -1 || isolated.caster_count != 0) return 21;
    if (!events_equal(isolated, {render_event::lighting_applied})) return 22;

    kay::graphics::reset_frame();
    kay::graphics::set_shadow_vp(sun.shadow_vp);
    kay::graphics::set_shadow_params(sun.shadow);
    kay::graphics::draw_shadow_caster();
    kay::graphics::end_shadow_pass();
    kay::graphics::apply_lights();
    frame_snapshot invalid = kay::graphics::snapshot();
    if (invalid.shadow_ready || invalid.caster_count != 0 || invalid.light_index != -1) return 30;
    if (!events_equal(invalid, {render_event::lighting_applied})) return 31;

    kay::graphics::reset_frame();
    kay::graphics::begin_shadow_pass(3);
    kay::graphics::begin_shadow_pass(9);
    kay::graphics::set_shadow_vp(sun.shadow_vp);
    kay::graphics::set_shadow_params(sun.shadow);
    kay::graphics::draw_shadow_caster();
    kay::graphics::end_shadow_pass();
    kay::graphics::end_shadow_pass();
    kay::graphics::apply_lights();
    frame_snapshot duplicate = kay::graphics::snapshot();
    if (!duplicate.shadow_ready || duplicate.shadow_pass_active) return 40;
    if (duplicate.light_index != 3 || duplicate.params.light_index != 3) return 41;
    if (duplicate.events.size() != 6 || duplicate.lighting_count != 1) return 42;

    std::cout << "CPP_SHADOW_RUNTIME_OK\n";
    return 0;
}
PROBE_EOF

cd "$WORKDIR"

if ! g++ -std=c++17 -Iengine/include "$PROBE_SRC" engine/src/render/graphics.cpp -o "$PROBE_BIN" 2>/tmp/gfb042_compile.log; then
    emit_result
    exit 0
fi

PROBE_OUT=$("$PROBE_BIN" 2>&1 || true)

if echo "$PROBE_OUT" | grep -q "CPP_SHADOW_RUNTIME_OK"; then
    pass=1
fi

emit_result

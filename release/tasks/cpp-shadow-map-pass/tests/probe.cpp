#include "engine/include/kay/render/graphics.h"
#include <iostream>
#include <vector>
using kay::frame_snapshot;
using kay::matrix4x4;
using kay::render_event;
using kay::shadow_params;

int main() {
    kay::graphics::reset_frame();
    kay::graphics::begin_shadow_pass(5);
    matrix4x4 vp = matrix4x4::identity();
    vp.m[12] = 2.0f;
    kay::graphics::set_shadow_vp(vp);
    shadow_params p{0.5f, 0.001f, 512.0f, 99};
    kay::graphics::set_shadow_params(p);
    kay::graphics::draw_shadow_caster();
    kay::graphics::end_shadow_pass();
    kay::graphics::apply_lights();
    frame_snapshot s = kay::graphics::snapshot();
    if (s.shadow_pass_active || !s.shadow_ready) return 1;
    if (s.light_index != 5 || s.caster_count != 1 || s.lighting_count != 1) return 2;
    std::vector<render_event> expected_events = {
        render_event::shadow_pass_begin,
        render_event::shadow_vp_uploaded,
        render_event::shadow_params_uploaded,
        render_event::shadow_caster_drawn,
        render_event::shadow_pass_end,
        render_event::lighting_applied,
    };
    if (s.events != expected_events) return 3;
    kay::graphics::reset_frame();
    frame_snapshot after = kay::graphics::snapshot();
    if (after.shadow_ready || after.shadow_pass_active || after.caster_count != 0) return 4;
    kay::graphics::reset_frame();
    kay::graphics::begin_shadow_pass(3);
    kay::graphics::begin_shadow_pass(9);
    kay::graphics::set_shadow_vp(matrix4x4::identity());
    shadow_params p2{0.5f, 0.001f, 512.0f, 99};
    kay::graphics::set_shadow_params(p2);
    kay::graphics::draw_shadow_caster();
    kay::graphics::end_shadow_pass();
    kay::graphics::end_shadow_pass();
    kay::graphics::apply_lights();
    frame_snapshot dup = kay::graphics::snapshot();
    if (!dup.shadow_ready || dup.shadow_pass_active) return 5;
    if (dup.light_index != 3) return 6;
    if (dup.events.size() != 6) return 7;
    std::cout << "CPP_SHADOW_RUNTIME_OK\n";
    return 0;
}

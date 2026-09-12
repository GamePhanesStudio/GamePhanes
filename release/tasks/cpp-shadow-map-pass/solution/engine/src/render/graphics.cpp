#include "../../include/kay/render/graphics.h"

namespace kay::graphics {

namespace {

frame_snapshot g_frame{};
bool g_vp_uploaded = false;
bool g_params_uploaded = false;

} // namespace

void reset_frame() {
    g_frame = frame_snapshot{};
    g_vp_uploaded = false;
    g_params_uploaded = false;
}

void begin_shadow_pass(int light_index) {
    if (g_frame.shadow_pass_active) {
        return;
    }
    g_frame.shadow_pass_active = true;
    g_frame.light_index = light_index;
    g_frame.params.light_index = light_index;
    g_frame.events.push_back(render_event::shadow_pass_begin);
}

void set_shadow_vp(const matrix4x4& vp) {
    if (!g_frame.shadow_pass_active) {
        return;
    }
    g_frame.shadow_vp = vp;
    g_vp_uploaded = true;
    g_frame.events.push_back(render_event::shadow_vp_uploaded);
}

void set_shadow_params(const shadow_params& params) {
    if (!g_frame.shadow_pass_active) {
        return;
    }
    g_frame.params = params;
    g_frame.params.light_index = g_frame.light_index;
    g_params_uploaded = true;
    g_frame.events.push_back(render_event::shadow_params_uploaded);
}

void draw_shadow_caster() {
    if (!g_frame.shadow_pass_active) {
        return;
    }
    ++g_frame.caster_count;
    g_frame.events.push_back(render_event::shadow_caster_drawn);
}

void end_shadow_pass() {
    if (!g_frame.shadow_pass_active) {
        return;
    }
    g_frame.shadow_pass_active = false;
    g_frame.shadow_ready = g_vp_uploaded && g_params_uploaded && g_frame.caster_count > 0;
    g_frame.events.push_back(render_event::shadow_pass_end);
}

void apply_lights() {
    ++g_frame.lighting_count;
    g_frame.events.push_back(render_event::lighting_applied);
}

frame_snapshot snapshot() {
    return g_frame;
}

} // namespace kay::graphics

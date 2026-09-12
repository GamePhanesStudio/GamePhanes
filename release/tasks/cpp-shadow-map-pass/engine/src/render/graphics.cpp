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
    // TODO: reject a duplicate pass while preserving the first light.
    g_frame.shadow_pass_active = true;
    g_frame.light_index = light_index;
    g_frame.params.light_index = light_index;
}

void set_shadow_vp(const matrix4x4& vp) {
    // TODO: upload the matrix only during the active shadow pass.
    g_frame.shadow_vp = vp;
}

void set_shadow_params(const shadow_params& params) {
    // TODO: keep shadow parameters synchronized with the selected light.
    g_frame.params = params;
}

void draw_shadow_caster() {
    // TODO: account for a depth draw in the active pass.
}

void end_shadow_pass() {
    // TODO: make readiness depend on both uploads and at least one caster.
    g_frame.shadow_pass_active = false;
}

void apply_lights() {
    ++g_frame.lighting_count;
    g_frame.events.push_back(render_event::lighting_applied);
}

frame_snapshot snapshot() {
    return g_frame;
}

} // namespace kay::graphics

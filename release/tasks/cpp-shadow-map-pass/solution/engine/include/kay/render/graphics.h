#pragma once

#include <cstdint>
#include <vector>

namespace kay {

struct matrix4x4 {
    float m[16]{};

    static matrix4x4 identity() {
        matrix4x4 value{};
        value.m[0] = value.m[5] = value.m[10] = value.m[15] = 1.0f;
        return value;
    }
};

struct shadow_params {
    float strength = 0.0f;
    float bias = 0.0015f;
    float map_size = 2048.0f;
    int light_index = -1;
};

enum class render_event {
    shadow_pass_begin,
    shadow_vp_uploaded,
    shadow_params_uploaded,
    shadow_caster_drawn,
    shadow_pass_end,
    lighting_applied,
};

struct frame_snapshot {
    bool shadow_pass_active = false;
    bool shadow_ready = false;
    int light_index = -1;
    std::uint32_t caster_count = 0;
    std::uint32_t lighting_count = 0;
    matrix4x4 shadow_vp{};
    shadow_params params{};
    std::vector<render_event> events;
};

namespace graphics {

void reset_frame();
void begin_shadow_pass(int light_index);
void set_shadow_vp(const matrix4x4& vp);
void set_shadow_params(const shadow_params& params);
void draw_shadow_caster();
void end_shadow_pass();
void apply_lights();
frame_snapshot snapshot();

} // namespace graphics

} // namespace kay

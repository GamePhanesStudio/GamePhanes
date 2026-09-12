#pragma once

#include <vector>

#include "../render/graphics.h"

namespace kay {

enum class light_type { directional, point };

struct scene_light {
    int index = -1;
    light_type type = light_type::point;
    bool active = false;
    bool casts_shadows = false;
    matrix4x4 shadow_vp = matrix4x4::identity();
    shadow_params shadow{};
};

struct shadow_caster {
    bool active = false;
    bool casts_shadows = false;
};

class scene {
public:
    void add_light(const scene_light& light);
    void add_caster(const shadow_caster& caster);
    void render();

private:
    void push_shadows();
    void push_lights();

    std::vector<scene_light> lights_;
    std::vector<shadow_caster> casters_;
};

} // namespace kay

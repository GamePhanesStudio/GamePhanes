#include "../../include/kay/scene/scene.h"

namespace kay {

void scene::add_light(const scene_light& light) {
    lights_.push_back(light);
}

void scene::add_caster(const shadow_caster& caster) {
    casters_.push_back(caster);
}

void scene::render() {
    graphics::reset_frame();
    push_shadows();
    push_lights();
}

void scene::push_shadows() {
    for (const scene_light& light : lights_) {
        if (!light.active || !light.casts_shadows || light.type != light_type::directional) {
            continue;
        }

        graphics::begin_shadow_pass(light.index);
        graphics::set_shadow_vp(light.shadow_vp);
        graphics::set_shadow_params(light.shadow);
        for (const shadow_caster& caster : casters_) {
            if (caster.active && caster.casts_shadows) {
                graphics::draw_shadow_caster();
            }
        }
        graphics::end_shadow_pass();
        break;
    }
}

void scene::push_lights() {
    graphics::apply_lights();
}

} // namespace kay

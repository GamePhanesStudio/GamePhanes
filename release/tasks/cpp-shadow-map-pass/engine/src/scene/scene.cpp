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
    // Lighting is wired, but the shadow pass still needs to be integrated.
    push_lights();
}

void scene::push_shadows() {
    // TODO: choose the first active directional shadow-casting light,
    // upload its matrix and parameters, draw active casters, then end.
}

void scene::push_lights() {
    graphics::apply_lights();
}

} // namespace kay

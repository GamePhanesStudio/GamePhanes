Complete the shadow-map rendering pipeline in four C++ files: `engine/include/kay/render/graphics.h`, `engine/include/kay/scene/scene.h`, `engine/src/render/graphics.cpp`, and `engine/src/scene/scene.cpp`.

The scene renderer needs to run a shadow/depth pass for the first active directional light that casts shadows before proceeding to lighting. This pass should upload the light's view-projection matrix and shadow parameters, draw all active shadow-casting objects, and cleanly bracket the pass with begin and end markers. Inactive lights, point lights, inactive casters, and non-shadow-casters should all be skipped.

The graphics lifecycle must be robust to misuse: beginning a pass when one is already active, or ending a pass when none is running, should be idempotent rather than corrupting state. Uploads and caster draws outside an active pass should be silently ignored. Resetting frame state must wipe all shadow data so a frame without a valid shadow light never inherits the previous frame's matrix, parameters, or caster count.

The project compiles as C++17. The probe checks the frame snapshot and the ordered render event stream. Submit only the four source files listed above.
The replay view's orbit camera has two bugs in `scripts/orbit_camera.gd`. First, the horizontal drag sensitivity is calibrated in raw pixels, so the same physical swipe rotates by different amounts on low- and high-density screens. Second, dragging right turns the camera the wrong way — it moves away from the drag instead of following it.

Fix the sensitivity so it scales by the display's pixel density — the same physical travel should produce the same rotation regardless of screen DPI. The default sensitivity should be defined in density-independent units. While you're there, flip the yaw direction so dragging right increases yaw and the camera follows the finger.

Also make sure that zeroing out the yaw restores the camera to its initial horizontal orientation, and that requesting a snapshot of the camera state returns a copy — mutating the returned data must not affect the live camera.

Submit only `scripts/orbit_camera.gd`.
Implement the `GrenadePhysics` class in `scripts/grenade_physics.gd`. The class is already attached to a node in `Main.tscn` and the method signatures are in place.

Computing a launch velocity from a speed and angle should return a zero vector for invalid (zero or negative) speed. Throwing a grenade should use that velocity to create a projectile dictionary with position, velocity, and active fields, appending it to the projectiles array — invalid speed returns an empty dictionary without touching the array. Advancing a projectile should add velocity times delta to position each frame, returning failure and leaving state untouched for non-positive delta or an empty dictionary.

Spawning a burn pool should create a dictionary with position, radius, remaining duration, and active fields, appending it only when both radius and duration are positive. Advancing a burn pool should tick down the remaining time by delta and set it to inactive when it reaches zero. The smoke state check should return "active" or "extinguished" based on whether elapsed time has reached the lifetime. Resetting should clear both arrays.

Submit `scripts/grenade_physics.gd`, `scripts/main.gd`, and `Main.tscn`.
Implement three related mechanics in a Godot 4 project using GDScript: vehicle deceleration, a launcher camera, and a rocket smoke trail.

When a player exits a vehicle, the vehicle should coast to a stop by subtracting a deceleration value multiplied by frame delta from its current speed each frame, clamping so speed never goes below zero.

The launcher camera tracks relative position between the launcher and the player, but only along the horizontal axis. Its vertical offset must stay exactly zero regardless of what either object does vertically.

The smoke trail generator takes a starting point, a velocity vector, a total duration, and a sample interval, and returns an array of positions spaced evenly in time along the trajectory. If any parameter is invalid — zero or negative duration, zero or negative interval — it should return an empty array rather than crash.

The probe validates the speed floor, the horizontal-only camera tracking, and the trajectory array including the empty-array guard. Submit a working, launchable Godot project with your GDScript implementation.
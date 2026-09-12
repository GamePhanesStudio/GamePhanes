Complete the `com.gameforge.chair.ChairPlugin` class for a Minecraft Paper plugin. The plugin is responsible for chair seating, and the camera clips through chair models in third-person view because the chair's hitbox is larger than one block.

The hitbox for a chair must be exactly one block in every dimension, independent of any block state. Seating interactions should reject a null or empty player identifier and silently ignore attempts to seat a player in a chair that already has an occupant — no stacking duplicate seat entries.

The plugin also needs to produce a consistent state snapshot for inspection and support a clean reload by wiping all stored state.

The probe checks that the hitbox is exactly 1×1×1, that a duplicate interaction on an occupied chair has no side effect, and that a reload leaves the plugin blank. Submit your updated `ChairPlugin.java` and `plugin.yml`.
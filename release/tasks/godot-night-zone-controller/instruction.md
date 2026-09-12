Finish the `NightZone` controller in `scripts/night_zone.gd`. `Main.tscn` is read-only, so every change lives in that one script.

The controller currently does nothing when night mode is activated. Activating it should populate the zone's state: at least two named landmarks, at least one armed weapon with a real damage value, and a path cost multiplier that reflects how night mode affects AI movement. In the dark, danger pushes soldiers toward the most direct route available, so paths feel shorter than they would in daylight — the multiplier should capture that discount.

Enemy spawning should scale meaningfully with wave number so that later waves are genuinely harder — tougher and faster. An invalid or zero wave should still produce a valid enemy at minimum strength without crashing.

Path cost calculation should apply the zone's current multiplier to any incoming distance. A negative distance is treated as zero.

The state snapshot must be a full copy of the controller's current data — a caller mutating the returned value must not corrupt the live zone state.

Submit only `scripts/night_zone.gd`.

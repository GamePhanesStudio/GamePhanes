The replay page needs a few fixes across `scripts/replay_ui.gd` and `Main.tscn`. The minimap is currently attached to the main scene layer, which means the scene camera clips it — moving it to its own independent canvas layer in the scene file will fix that.

The HUD height is hard-coded, so it overflows on smaller screens. Add logic that derives the height dynamically from the viewport size and safe-area insets, subtracting both insets from the viewport height. The result for a small viewport should be strictly less than the result for a desktop viewport at the same insets.

Screenshot capture needs proper lifecycle management. Entering capture mode should hide screenshot-only HUD elements and mark the capture as pending; leaving capture mode should restore those elements and clear the pending flag. A snapshot of the current capture state should reflect both whether a capture is pending and whether the extra HUD elements are visible.

Keep the transition duration as a readable positive value, and expose a way to query transition progress at a given time offset.

Submit only `scripts/replay_ui.gd` and `Main.tscn`.
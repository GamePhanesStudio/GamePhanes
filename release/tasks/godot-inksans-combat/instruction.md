Implement the `InkSansState` class in `scripts/ink_sans_state.gd`. The class tracks HP, a hit counter, and whether the fighter is alive, and exposes two signals: one that fires whenever HP changes and one that fires exactly once when HP hits zero.

Taking a hit should return failure and leave state untouched when the amount is zero or negative, or when the fighter is already dead. For a valid hit, reduce HP by the given amount clamped to zero, increment the hit counter, emit the health change signal with the before and after values, and emit the defeated signal if HP just reached zero. Return success. The alive check simply returns whether HP is greater than zero.

Resetting should restore HP to the maximum and clear the hit counter. Emit the health change signal if HP actually changed, but never emit the defeated signal. Skip the signal entirely if HP was already at max.

The state snapshot returns a dictionary with hp, max_hp, hits, and alive — as a copy so callers cannot mutate internal state.

Submit `scripts/ink_sans_state.gd`, `scripts/main.gd`, and `Main.tscn`.
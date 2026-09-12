Fix two bugs in a headless C++ billiards predictor. The collision handler in `src/Prediction.h` has two problems after a ball-ball impact: the balls can remain overlapping, and spin is not transferred between them, causing the cue ball to drift off the correct post-shot line.

The collision handler needs to push the two balls apart so their centers are no longer overlapping after the impulse, and it needs to exchange the appropriate spin component so each ball leaves with the correct lateral curve. Everything else — velocity decay, spin decay, per-step spin deflection, friction coefficient, loop structure — should stay unchanged.

The probe runs ball A from (0,0) with velocity (0.28, 0) and spin 0.18 toward a stationary ball B at (0.95, 0) for 220 steps and compares the final positions and velocities against a reference; the run passes when those values match within tolerance.

Submit the corrected `src/Prediction.h` and a plain-text `ROOT_CAUSE.txt` that names the bug and describes the fix.
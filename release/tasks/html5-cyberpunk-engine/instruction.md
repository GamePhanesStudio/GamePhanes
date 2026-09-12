Build a cyberpunk-themed browser game across four source files — `index.html`, `src/engine.js`, `src/state.js`, and `src/game.js`. Do not collapse or reorganize these module boundaries.

The engine loop should drive the game forward using requestAnimationFrame. State management should handle observable transitions for score, HP, and wave. The game module should spawn enemies at runtime with at least four distinct types and at least three boss types that appear as waves progress.

The probe depends on `window.NeonRift` (exposed by the engine/game layer) and `window.CyberState` (exposed by the state module) — both must be present and functional when `index.html` loads. The probe will advance wave state, apply HP damage, and fire unexpected events, so the state machine should degrade gracefully on unknown event types rather than throwing. After exercising the game, the probe reads its verdict from the page DOM.

Submit the complete source files — no documentation in place of working code.
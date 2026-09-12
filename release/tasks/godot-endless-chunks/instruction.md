Implement an endless streaming level generator in a Godot 4 project using GDScript.

Configuring a seed should reset the generator to a clean state so all subsequent generation is reproducible from that point. Generating a chunk at a given index must always return exactly six platform slots in the same order for the same seed and index — determinism is required. Any gap between platforms in the chunk must have a spike placed there; without this, players fall into gaps and get stuck, which the probe specifically checks.

Access gating should only unlock an entity when the identifier is valid and the progress value is at least 3 — anything else stays locked.

State snapshots must be deep, isolated copies — callers holding a snapshot must not see it change when the generator is used further.

Submit a working, launchable Godot 4 project with your GDScript implementation. The probe runs the project directly.
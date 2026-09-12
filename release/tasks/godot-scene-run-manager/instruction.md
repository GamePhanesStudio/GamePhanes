Implement the `SceneRunManager` class in `scripts/scene_run_manager.gd`. The class controls whether scenes are allowed to run, counts executions, handles crash cleanup, and returns isolated state snapshots.

Configuring the manager enables or disables it. When disabled, running a scene does nothing and returns failure.

Running a scene validates the path — it must be non-empty and end in `.tscn` — then loads and instantiates the resource. Any failure along that chain returns failure. A successful run increments an internal counter, stores the path as the last scene, and returns success with the current count.

Crash recovery looks for a lock file in the given cache directory and deletes it if present, then returns success. It should be safe to call when no lock file exists.

The state snapshot returns enabled, last scene, and run count as a copy — mutations to it must not affect the manager.

The probe exercises: running before enabled, two successful runs with incrementing counts, rejection of a bad path and a non-tscn path, disabling, crash recovery with and without a lock file, and snapshot isolation.

Submit `scripts/scene_run_manager.gd`, `scripts/main.gd`, and `Main.tscn`.
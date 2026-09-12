extends SceneTree
func _init() -> void:
    var manager := preload("res://scripts/scene_run_manager.gd").new()
    # CP1: API shape — unconfigured call must be rejected
    if manager.run_scene("res://Main.tscn").get("ok", true): quit(1); return
    manager.configure(true)
    print("SCENE_RUN_PLUGIN_PROBE_CP1_OK")
    # CP2: core execution — two sequential runs with incrementing run_count
    var first: Dictionary = manager.run_scene("res://Main.tscn")
    if not first.get("ok", false) or first.get("run_count", 0) != 1: quit(1); return
    var second: Dictionary = manager.run_scene("res://Main.tscn")
    if not second.get("ok", false) or second.get("run_count", 0) != 2: quit(1); return
    print("SCENE_RUN_PLUGIN_PROBE_CP2_OK")
    # CP3: edge cases and gating — bad paths rejected, disabled manager rejected
    if manager.run_scene("res://missing.tscn").get("ok", true): quit(1); return
    if manager.run_scene("bad.scene").get("ok", true): quit(1); return
    manager.configure(false)
    if manager.run_scene("res://Main.tscn").get("ok", true): quit(1); return
    print("SCENE_RUN_PLUGIN_PROBE_CP3_OK")
    # CP4: crash recovery clears lock file (idempotent) and snapshot is isolated
    var temp := "user://scene_run_probe"
    DirAccess.make_dir_recursive_absolute(temp)
    var file := temp.path_join("scene_run.lock")
    var handle := FileAccess.open(file, FileAccess.WRITE); handle.store_string("lock"); handle = null
    if not manager.recover_after_crash(temp) or FileAccess.file_exists(file): quit(1); return
    if not manager.recover_after_crash(temp): quit(1); return
    var copy: Dictionary = manager.snapshot(); copy["last_scene"] = "mutated"; copy["run_count"] = 999
    var later: Dictionary = manager.snapshot()
    if str(later["last_scene"]) == "mutated" or int(later["run_count"]) == 999: quit(1); return
    print("SCENE_RUN_PLUGIN_PROBE_OK"); quit(0)

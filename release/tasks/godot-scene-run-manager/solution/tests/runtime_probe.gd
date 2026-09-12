extends SceneTree
func _init() -> void:
    var manager := preload("res://scripts/scene_run_manager.gd").new()
    if manager.run_scene("res://Main.tscn").get("ok", true): quit(1); return
    manager.configure(true)
    var result: Dictionary = manager.run_scene("res://Main.tscn")
    if not result.get("ok", false) or result.get("run_count", 0) != 1: quit(1); return
    if manager.run_scene("bad.scene").get("ok", true): quit(1); return
    var temp := "user://scene_run_probe"
    DirAccess.make_dir_recursive_absolute(temp)
    var file := temp.path_join("scene_run.lock")
    var handle := FileAccess.open(file, FileAccess.WRITE); handle.store_string("lock"); handle = null
    if not manager.recover_after_crash(temp) or FileAccess.file_exists(file): quit(1); return
    var copy: Dictionary = manager.snapshot(); copy["last_scene"] = "mutated"
    if str(manager.snapshot()["last_scene"]) == "mutated": quit(1); return
    print("SCENE_RUN_PLUGIN_PROBE_OK"); quit(0)

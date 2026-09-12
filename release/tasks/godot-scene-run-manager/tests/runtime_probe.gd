extends SceneTree
func _init() -> void:
    var manager := preload("res://scripts/scene_run_manager.gd").new()
    if manager.run_scene("res://Main.tscn").get("ok", true): quit(1); return
    manager.configure(true)
    var first: Dictionary = manager.run_scene("res://Main.tscn")
    var first_count: int = first.get("run_count", first.get("count", 0))
    if not first.get("ok", false) or first_count != 1: quit(1); return
    var second: Dictionary = manager.run_scene("res://Main.tscn")
    var second_count: int = second.get("run_count", second.get("count", 0))
    if not second.get("ok", false) or second_count != 2: quit(1); return
    if manager.run_scene("res://missing.tscn").get("ok", true): quit(1); return
    if manager.run_scene("bad.scene").get("ok", true): quit(1); return
    manager.configure(false)
    if manager.run_scene("res://Main.tscn").get("ok", true): quit(1); return
    var temp := "user://scene_run_probe"
    DirAccess.make_dir_recursive_absolute(temp)
    var file := temp.path_join("scene_run.lock")
    var handle := FileAccess.open(file, FileAccess.WRITE); handle.store_string("lock"); handle = null
    if not manager.recover_after_crash(temp) or FileAccess.file_exists(file): quit(1); return
    if not manager.recover_after_crash(temp): quit(1); return
    var copy: Dictionary = manager.snapshot(); copy["last_scene"] = "mutated"
    var later: Dictionary = manager.snapshot()
    if str(later["last_scene"]) == "mutated": quit(1); return
    var later_count: int = later.get("run_count", later.get("count", -1))
    if later_count == 999: quit(1); return
    print("SCENE_RUN_PLUGIN_PROBE_OK"); quit(0)

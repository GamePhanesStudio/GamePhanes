extends RefCounted
class_name SceneRunManager

var enabled := false
var last_scene := ""
var run_count := 0

func configure(value: bool) -> void:
    enabled = value

func run_scene(scene_path: String) -> Dictionary:
    if not enabled or scene_path.is_empty() or not scene_path.ends_with(".tscn"):
        return {"ok": false, "error": "disabled_or_invalid"}
    if not ResourceLoader.exists(scene_path, "PackedScene"):
        return {"ok": false, "error": "scene_not_found"}
    var packed := ResourceLoader.load(scene_path, "PackedScene") as PackedScene
    if packed == null:
        return {"ok": false, "error": "scene_load_failed"}
    var instance := packed.instantiate()
    if instance == null:
        return {"ok": false, "error": "scene_instantiate_failed"}
    instance.free()
    last_scene = scene_path
    run_count += 1
    return {"ok": true, "scene": scene_path, "run_count": run_count}

func recover_after_crash(cache_dir: String) -> bool:
    if cache_dir.is_empty():
        return false
    var marker := cache_dir.path_join("scene_run.lock")
    if not FileAccess.file_exists(marker):
        return true
    DirAccess.remove_absolute(marker)
    return not FileAccess.file_exists(marker)

func snapshot() -> Dictionary:
    return {"enabled": enabled, "last_scene": last_scene, "run_count": run_count}

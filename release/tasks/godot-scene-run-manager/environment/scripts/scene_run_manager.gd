extends RefCounted
class_name SceneRunManager

var enabled := false
var last_scene := ""

func configure(value: bool) -> void:
	enabled = value

func run_scene(_scene_path: String) -> Dictionary:
	return {"ok": false, "error": "not configured"}

func recover_after_crash(_cache_dir: String) -> bool:
	return false

func snapshot() -> Dictionary:
	return {"enabled": enabled, "last_scene": last_scene}

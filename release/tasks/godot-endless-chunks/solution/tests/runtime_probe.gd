extends SceneTree
func _init() -> void:
    var first := preload("res://scripts/endless_level.gd").new()
    first.configure_seed(42)
    var a: Array[Dictionary] = first.generate_chunk(2)
    var b: Array[Dictionary] = first.generate_chunk(2)
    if a.size() != 6 or a != b: quit(1); return
    var has_spike := false
    for cell in a:
        if bool(cell.get("spike", false)): has_spike = true
    if not has_spike: quit(1); return
    var second := preload("res://scripts/endless_level.gd").new()
    second.configure_seed(42)
    if second.generate_chunk(2) != a: quit(1); return
    if first.unlocked("gate", 2) or not first.unlocked("gate", 3): quit(1); return
    var copy: Dictionary = first.snapshot(); copy["chunks"][2][0]["height"] = 999
    if int(first.snapshot()["chunks"][2][0]["height"]) == 999: quit(1); return
    print("ENDLESS_LEVEL_PROBE_OK"); quit(0)

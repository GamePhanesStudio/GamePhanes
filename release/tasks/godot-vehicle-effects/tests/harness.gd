extends SceneTree
func _initialize() -> void:
    var effects := preload("res://scripts/vehicle_effects.gd").new()
    if effects.decelerate(100.0, 40.0, 1.0) != 60.0: quit(1); return
    if effects.decelerate(10.0, 40.0, 1.0) != 0.0: quit(1); return
    var offset: Vector2 = effects.camera_offset(Vector2(10.0, 80.0), Vector2(42.0, 120.0))
    if offset != Vector2(32.0, 0.0): quit(1); return
    var path: Array[Vector2] = effects.smoke_path(Vector2.ZERO, Vector2(10.0, 0.0), 0.5, 0.1)
    if path.size() != 6 or path[0] != Vector2.ZERO or path[-1] != Vector2(5.0, 0.0): quit(1); return
    print("VEHICLE_EFFECTS_PROBE_OK"); quit(0)

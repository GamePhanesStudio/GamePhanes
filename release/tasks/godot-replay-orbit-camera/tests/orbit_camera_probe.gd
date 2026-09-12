extends SceneTree

func _initialize() -> void:
	var scene = load("res://Main.tscn")
	if scene == null:
		quit(1)
		return
	var inst = scene.instantiate()
	root.add_child(inst)
	await process_frame
	var cam = inst.find_child("ReplayCamera", true, false)
	if cam == null:
		quit(1)
		return
	if not "rotate_speed_dp" in cam:
		quit(1)
		return
	var rate: float = float(cam.get("rotate_speed_dp"))
	if rate <= 0.0 or rate > 0.1:
		quit(1)
		return
	print("ORBIT_PROBE1_OK")
	if not cam.has_method("drag_delta"):
		quit(1)
		return
	var mm := 10.0
	var d160: float = float(cam.call("drag_delta", mm * 160.0 / 25.4, 0.0, 160.0))
	var d520: float = float(cam.call("drag_delta", mm * 520.0 / 25.4, 0.0, 520.0))
	if absf(d160 - d520) > 0.001:
		quit(1)
		return
	print("ORBIT_PROBE2_OK")
	if not cam.has_method("apply_drag"):
		quit(1)
		return
	var yaw0: float = float(cam.get("yaw") if "yaw" in cam else 0.0)
	cam.call("apply_drag", 20.0, 0.0, 160.0)
	var yaw1: float = float(cam.get("yaw") if "yaw" in cam else 0.0)
	if yaw1 <= yaw0:
		quit(1)
		return
	if cam.has_method("snapshot"):
		var snap: Dictionary = cam.call("snapshot")
		if "yaw" in snap:
			snap["yaw"] = 9999.0
		var snap2: Dictionary = cam.call("snapshot")
		if snap2.has("yaw") and float(snap2["yaw"]) >= 9000.0:
			quit(1)
			return
	inst.free()
	print("ORBIT_PROBE3_OK")
	quit(0)

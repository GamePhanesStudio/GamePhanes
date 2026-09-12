extends SceneTree

func _init() -> void:
	var scene = load("res://Main.tscn")
	if scene == null:
		quit(1)
		return
	var zone = scene.instantiate()
	root.add_child(zone)
	await process_frame
	# Start unconfigured; call the product controller API directly.
	if zone.night_mode == true:
		quit(1)
		return
	zone.configure_night_mode()
	if zone.night_mode != true:
		quit(1)
		return
	print("NIGHT_ZONE_RUNTIME_CP1_OK")
	if zone.landmarks.size() < 2:
		quit(1)
		return
	var has_damage := false
	for weapon in zone.weapons.values():
		if weapon is Dictionary and float(weapon.get("damage", 0.0)) > 0.0:
			has_damage = true
	if not has_damage:
		quit(1)
		return
	print("NIGHT_ZONE_RUNTIME_CP2_OK")
	var first: Dictionary = zone.spawn_enemy(1)
	var later: Dictionary = zone.spawn_enemy(3)
	if float(later["health"]) <= float(first["health"]):
		quit(1)
		return
	if float(later["speed"]) <= float(first["speed"]):
		quit(1)
		return
	print("NIGHT_ZONE_RUNTIME_CP3_OK")
	var tuned: float = zone.path_cost(10.0)
	# The night config must apply a real, positive path-cost reduction (not return
	# the unchanged base or a hard-coded zero).
	if tuned >= 10.0 or tuned <= 0.0:
		quit(1)
		return
	# A wave below one and a negative cost are still safe: the controller clamps the
	# wave to level >= 1 and the negative base cost to zero (never errors).
	var bound: Dictionary = zone.spawn_enemy(0)
	var neg_cost: float = zone.path_cost(-1.0)
	if float(bound["health"]) <= 0.0 or neg_cost < 0.0:
		quit(1)
		return
	print("NIGHT_ZONE_RUNTIME_CP4_OK")
	# Mutating a returned copy must not corrupt the controller's own state.
	var snapshot_fresh: Dictionary = zone.snapshot()
	if (snapshot_fresh.get("landmarks", []) as Array).is_empty():
		quit(1)
		return
	var copy: Dictionary = zone.snapshot()
	if copy.get("weapons", {}) is Dictionary:
		for key in copy["weapons"].keys():
			var ent = copy["weapons"][key]
			if ent is Dictionary:
				ent["damage"] = 0.0
	var fresh2: Dictionary = zone.snapshot()
	var intact: Dictionary = zone.weapons
	for wkey in intact.keys():
		if float((intact[wkey] as Dictionary).get("damage", 0.0)) <= 0.0:
			quit(1)
			return
	if (fresh2.get("landmarks", []) as Array).is_empty():
		quit(1)
		return
	zone.free()
	print("NIGHT_ZONE_RUNTIME_OK")
	quit(0)

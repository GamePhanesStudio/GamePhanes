extends SceneTree

func _initialize() -> void:
	var scene = load("res://Main.tscn")
	if scene == null:
		quit(1)
		return
	var zone = scene.instantiate()
	root.add_child(zone)
	await process_frame
	if zone.night_mode == true:
		quit(1)
		return
	zone.configure_night_mode()
	if zone.night_mode != true:
		quit(1)
		return
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
	print("NIGHT_ZONE_PROBE1_OK")
	var first: Dictionary = zone.spawn_enemy(1)
	var later: Dictionary = zone.spawn_enemy(3)
	if float(later["health"]) <= float(first["health"]):
		quit(1)
		return
	if float(later["speed"]) <= float(first["speed"]):
		quit(1)
		return
	var tuned: float = zone.path_cost(10.0)
	if tuned >= 10.0 or tuned <= 0.0:
		quit(1)
		return
	print("NIGHT_ZONE_PROBE2_OK")
	var bound: Dictionary = zone.spawn_enemy(0)
	var neg_cost: float = zone.path_cost(-1.0)
	if float(bound["health"]) <= 0.0 or neg_cost < 0.0:
		quit(1)
		return
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
	print("NIGHT_ZONE_PROBE3_OK")
	quit(0)

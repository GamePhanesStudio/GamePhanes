extends SceneTree

func _init() -> void:
    var packed := load("res://Main.tscn") as PackedScene
    if packed == null: quit(1); return
    var scene := packed.instantiate()
    root.add_child(scene)
    var grenade := scene.get_node("GrenadePhysics") as GrenadePhysics
    if grenade == null: quit(1); return
    var projectile: Dictionary = grenade.throw_grenade(10.0, PI * 0.5)
    if not projectile.get("active", false): quit(1); return
    if not grenade.advance_projectile(projectile, 0.5): quit(1); return
    var moved: Vector2 = projectile["position"]
    if absf(moved.x) > 0.001 or absf(moved.y - 5.0) > 0.001: quit(1); return
    var pool: Dictionary = grenade.spawn_burn_pool(Vector2(2, 3), 4.0, 2.0)
    if not pool.get("active", false): quit(1); return
    if not grenade.advance_burn_pool(pool, 0.5) or not pool.get("active", false): quit(1); return
    if not grenade.advance_burn_pool(pool, 1.5) or pool.get("active", true) or float(pool.get("remaining", 1.0)) != 0.0: quit(1); return
    if grenade.advance_burn_pool(pool, 0.1): quit(1); return
    if not grenade.throw_grenade(0.0, 0.0).is_empty(): quit(1); return
    if not grenade.spawn_burn_pool(Vector2.ZERO, 0.0, 2.0).is_empty(): quit(1); return
    if not grenade.spawn_burn_pool(Vector2.ZERO, 2.0, 0.0).is_empty(): quit(1); return
    var stable: Dictionary = grenade.spawn_burn_pool(Vector2.ZERO, 2.0, 1.0)
    if grenade.advance_burn_pool(stable, 0.0): quit(1); return
    if not stable.get("active", false): quit(1); return
    if grenade.smoke_state(0.5, 1.0) != "active" or grenade.smoke_state(1.0, 1.0) != "extinguished": quit(1); return
    print("GRENADE_SCENE_PROBE_OK")
    quit(0)

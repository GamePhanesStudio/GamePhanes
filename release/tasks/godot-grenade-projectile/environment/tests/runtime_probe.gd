extends SceneTree

func _initialize() -> void:
    var packed := load("res://Main.tscn") as PackedScene
    if packed == null: quit(1); return
    var scene := packed.instantiate()
    root.add_child(scene)
    var grenade := scene.get_node("GrenadePhysics") as GrenadePhysics
    if grenade == null: quit(1); return

    # CP1: API shape — scene instantiates, node found, throw_grenade returns active projectile
    var projectile: Dictionary = grenade.throw_grenade(10.0, PI * 0.5)
    if not projectile.get("active", false): quit(1); return
    print("GRENADE_SCENE_PROBE_CP1_OK")

    # CP2: core projectile behavior — advance moves position correctly
    if not grenade.advance_projectile(projectile, 0.5): quit(1); return
    var moved: Vector2 = projectile["position"]
    if absf(moved.x) > 0.001 or absf(moved.y - 5.0) > 0.001: quit(1); return
    print("GRENADE_SCENE_PROBE_CP2_OK")

    # CP3: burn pool lifecycle — spawn, partial advance, full expiry, expired pool rejected
    var pool: Dictionary = grenade.spawn_burn_pool(Vector2(2, 3), 4.0, 2.0)
    if not pool.get("active", false): quit(1); return
    if not grenade.advance_burn_pool(pool, 0.5) or not pool.get("active", false): quit(1); return
    if not grenade.advance_burn_pool(pool, 1.5) or pool.get("active", true) or float(pool.get("remaining", 1.0)) != 0.0: quit(1); return
    if grenade.advance_burn_pool(pool, 0.1): quit(1); return
    print("GRENADE_SCENE_PROBE_CP3_OK")

    # CP4: edge cases — invalid inputs rejected, zero-advance on stable pool
    if not grenade.throw_grenade(0.0, 0.0).is_empty(): quit(1); return
    if not grenade.spawn_burn_pool(Vector2.ZERO, 0.0, 2.0).is_empty(): quit(1); return
    if not grenade.spawn_burn_pool(Vector2.ZERO, 2.0, 0.0).is_empty(): quit(1); return
    var stable: Dictionary = grenade.spawn_burn_pool(Vector2.ZERO, 2.0, 1.0)
    if grenade.advance_burn_pool(stable, 0.0): quit(1); return
    if not stable.get("active", false): quit(1); return
    print("GRENADE_SCENE_PROBE_CP4_OK")

    # CP5: smoke state, internal state counts, and reset_for_reload
    if grenade.smoke_state(0.5, 1.0) != "active" or grenade.smoke_state(1.0, 1.0) != "extinguished": quit(1); return
    if grenade.projectiles.size() != 1 or grenade.burn_pools.size() != 2: quit(1); return
    grenade.reset_for_reload()
    if grenade.projectiles.size() != 0 or grenade.burn_pools.size() != 0: quit(1); return
    print("GRENADE_SCENE_PROBE_OK")
    quit(0)

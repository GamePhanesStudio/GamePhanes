extends SceneTree

var health_events: Array = []
var defeated_events := 0

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _on_health_changed(previous_hp: int, current_hp: int) -> void:
    health_events.append([previous_hp, current_hp])

func _on_defeated() -> void:
    defeated_events += 1

func _run() -> void:
    var packed := load("res://Main.tscn") as PackedScene
    if packed == null:
        _fail("Main.tscn is not a loadable PackedScene"); return
    var first := packed.instantiate()
    root.add_child(first)
    await process_frame
    var fighter := first.get_node_or_null("InkSansState")
    if fighter == null or fighter.get_script() == null:
        _fail("InkSansState scene node is missing its script"); return
    if not fighter.has_signal("health_changed") or not fighter.has_signal("defeated"):
        _fail("combat signals are missing"); return
    fighter.connect("health_changed", Callable(self, "_on_health_changed"))
    fighter.connect("defeated", Callable(self, "_on_defeated"))
    print("INK_SANS_SCENE_RUNTIME_CP1_OK")

    var initial: Dictionary = fighter.snapshot()
    if initial != {"hp": 100, "max_hp": 100, "hits": 0, "alive": true}:
        _fail("initial combat state is invalid"); return
    if not fighter.hit(25) or fighter.snapshot().get("hp") != 75 or fighter.snapshot().get("hits") != 1:
        _fail("valid damage transition failed"); return
    print("INK_SANS_SCENE_RUNTIME_CP2_OK")

    if fighter.hit(0) or fighter.hit(-3) or fighter.snapshot().get("hp") != 75:
        _fail("non-positive damage changed state"); return
    if not fighter.hit(100) or fighter.alive() or fighter.snapshot().get("hp") != 0:
        _fail("lethal damage did not clamp or update alive state"); return
    if fighter.hit(1) or fighter.snapshot().get("hits") != 2:
        _fail("post-death damage was accepted"); return
    print("INK_SANS_SCENE_RUNTIME_CP3_OK")

    if health_events != [[100, 75], [75, 0]] or defeated_events != 1:
        _fail("health/death signals do not match transitions"); return
    var copy: Dictionary = fighter.snapshot()
    copy["hp"] = 999
    copy["hits"] = 999
    if fighter.snapshot().get("hp") != 0 or fighter.snapshot().get("hits") != 2:
        _fail("snapshot aliases internal state"); return
    fighter.reset()
    fighter.reset()
    if fighter.snapshot() != {"hp": 100, "max_hp": 100, "hits": 0, "alive": true}:
        _fail("reset did not restore the initial state"); return
    if health_events != [[100, 75], [75, 0], [0, 100]] or defeated_events != 1:
        _fail("reset emitted duplicate or incorrect signals"); return
    if not fighter.hit(10):
        _fail("fighter did not accept damage after reset"); return
    print("INK_SANS_SCENE_RUNTIME_CP4_OK")

    var second := packed.instantiate()
    root.add_child(second)
    await process_frame
    var second_fighter := second.get_node_or_null("InkSansState")
    if second_fighter == null or second_fighter.snapshot() != {"hp": 100, "max_hp": 100, "hits": 0, "alive": true}:
        _fail("second scene instance inherited first-instance state"); return
    first.queue_free()
    second.queue_free()
    await process_frame
    print("INK_SANS_SCENE_RUNTIME_OK")
    quit(0)

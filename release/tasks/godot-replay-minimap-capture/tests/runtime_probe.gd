extends SceneTree

func fail(stage: String) -> void:
    print("REPLAY_UI_FAIL:" + stage)
    quit(1)

func _init() -> void:
    var ui := preload("res://scripts/replay_ui.gd").new()
    if not ui is Node:
        fail("instantiate")
        return
    if not ui.has_method("compute_ui_height") or not ui.has_method("begin_capture"):
        fail("public_api")
        return
    var desktop_height := ui.compute_ui_height(1280.0, 40.0, 20.0)
    if desktop_height <= 0.0:
        fail("large_viewport_layout")
        return
    var compact_height := ui.compute_ui_height(300.0, 40.0, 20.0)
    if compact_height >= desktop_height:
        fail("small_viewport_layout")
        return
    print("REPLAY_UI_PROBE1_OK")
    if ui.transition_duration <= 0.0:
        fail("transition_duration")
        return
    if ui.has_method("transition_alpha"):
        if absf(float(ui.call("transition_alpha", 0.125)) - 0.5) > 0.001:
            fail("transition_progress")
            return
    elif ui.get("transition_alpha") == null:
        fail("transition_api")
        return
    print("REPLAY_UI_PROBE2_OK")
    ui.begin_capture()
    var hidden := ui.capture_snapshot()
    if hidden.get("extra_elements_visible", true) or not hidden.get("capture_pending", false):
        fail("capture_hide")
        return
    ui.finish_capture()
    var restored := ui.capture_snapshot()
    if not restored.get("extra_elements_visible", false) or restored.get("capture_pending", true):
        fail("capture_restore")
        return
    print("REPLAY_UI_PROBE3_OK")
    quit(0)

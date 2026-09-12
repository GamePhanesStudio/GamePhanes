extends Node
class_name ReplayUi

## Runtime HUD sizing and screenshot state are kept independent of gameplay nodes.
@export var base_ui_height := 180.0
@export var transition_duration := 0.25
var extra_elements_visible := true
var capture_pending := false
var _capture_restore_queued := false

func compute_ui_height(viewport_height: float, safe_top: float, safe_bottom: float) -> float:
    var available := maxf(0.0, viewport_height - safe_top - safe_bottom)
    return minf(base_ui_height, available * 0.45)

func begin_capture() -> void:
    # Hide transient HUD elements before the frame is read, then restore them
    # on the following idle frame so the screenshot cannot include overlays.
    capture_pending = true
    extra_elements_visible = false
    _capture_restore_queued = true

func capture_snapshot() -> Dictionary:
    return {"extra_elements_visible": extra_elements_visible, "capture_pending": capture_pending}

func finish_capture() -> void:
    if _capture_restore_queued:
        _capture_restore_queued = false
        capture_pending = false
        extra_elements_visible = true

func transition_alpha(elapsed: float) -> float:
    if transition_duration <= 0.0:
        return 1.0
    return clampf(elapsed / transition_duration, 0.0, 1.0)

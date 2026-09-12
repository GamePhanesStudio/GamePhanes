extends Node
class_name ReplayUi

@export var ui_height := 180.0
@export var transition_duration := 0.0
var extra_elements_visible := true
var capture_pending := false

func compute_ui_height(_viewport_height: float, _safe_top: float, _safe_bottom: float) -> float:
    return ui_height

func begin_capture() -> void:
    capture_pending = true

func capture_snapshot() -> Dictionary:
    return {"extra_elements_visible": extra_elements_visible, "capture_pending": capture_pending}

func finish_capture() -> void:
    capture_pending = false

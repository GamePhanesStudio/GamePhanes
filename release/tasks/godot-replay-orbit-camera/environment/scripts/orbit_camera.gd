extends Camera3D
class_name OrbitCamera

## Legacy implementation: sensitivity is incorrectly measured in raw pixels.
@export var rotate_speed_px: float = 0.0055
var yaw := 0.0

func drag_delta(relative_px: Vector2, _dpi: float = 160.0) -> float:
    return relative_px.x * rotate_speed_px

func apply_drag(relative_px: Vector2, dpi: float = 160.0) -> void:
    yaw -= drag_delta(relative_px, dpi)
    rotation.y = yaw

func reset_yaw() -> void:
    yaw = 0.0
    rotation.y = yaw

func snapshot() -> Dictionary:
    return {"yaw": yaw}

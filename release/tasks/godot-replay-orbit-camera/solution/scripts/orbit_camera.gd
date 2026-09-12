extends Camera3D
class_name OrbitCamera

## Gesture sensitivity is expressed in radians per density-independent pixel.
@export var rotate_speed_dp: float = 0.0035
@export var dpi_override: float = 0.0
var yaw := 0.0

func _effective_dpi(dpi: float) -> float:
    if dpi > 0.0:
        return dpi
    if dpi_override > 0.0:
        return dpi_override
    return 160.0

func drag_delta(x_px: float, y_px: float = 0.0, dpi: float = 0.0) -> float:
    var px_per_dp := _effective_dpi(dpi) / 160.0
    return x_px / maxf(px_per_dp, 0.001) * rotate_speed_dp

func apply_drag(x_px: float, y_px: float = 0.0, dpi: float = 0.0) -> void:
    yaw += drag_delta(x_px, y_px, dpi)
    rotation.y = yaw

func reset_yaw() -> void:
    yaw = 0.0
    rotation.y = yaw

func snapshot() -> Dictionary:
    return {"yaw": yaw, "rotate_speed_dp": rotate_speed_dp}

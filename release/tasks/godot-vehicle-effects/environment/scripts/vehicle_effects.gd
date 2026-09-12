extends RefCounted
class_name VehicleEffects

var last_speed: float = 0.0
var smoke_samples: Array[Vector2] = []

func decelerate(speed: float, deceleration: float, delta: float) -> float:
    if speed <= 0.0 or deceleration < 0.0 or delta <= 0.0:
        return maxf(speed, 0.0)
    last_speed = maxf(speed - deceleration * delta, 0.0)
    return last_speed

func camera_offset(_player: Vector2, _emitter: Vector2) -> Vector2:
    return Vector2.ZERO

func smoke_path(origin: Vector2, velocity: Vector2, duration: float, interval: float = 0.1) -> Array[Vector2]:
    smoke_samples.clear()
    if duration <= 0.0 or interval <= 0.0:
        return smoke_samples.duplicate()
    var count := int(round(duration / interval))
    for i in range(count + 1):
        smoke_samples.append(origin + velocity * (i * interval))
    return smoke_samples.duplicate()

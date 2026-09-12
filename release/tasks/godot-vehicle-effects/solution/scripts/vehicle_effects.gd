extends RefCounted
class_name VehicleEffects
var last_speed: float = 0.0
var smoke_samples: Array[Vector2] = []

func decelerate(speed: float, deceleration: float, delta: float) -> float:
    if speed <= 0.0 or deceleration < 0.0 or delta <= 0.0:
        return maxf(speed, 0.0)
    last_speed = maxf(speed - deceleration * delta, 0.0)
    return last_speed

func camera_offset(player: Vector2, emitter: Vector2) -> Vector2:
    # The launcher camera follows the emitter horizontally, preserving vertical aim.
    return Vector2(emitter.x - player.x, 0.0)

func smoke_path(origin: Vector2, velocity: Vector2, duration: float, interval: float = 0.1) -> Array[Vector2]:
    var points: Array[Vector2] = []
    if duration <= 0.0 or interval <= 0.0:
        return points
    var count := int(round(duration / interval))
    for index in range(count + 1):
        var t := float(index) * interval
        points.append(origin + velocity * t)
    return points

extends Node
class_name GrenadePhysics

var projectiles: Array[Dictionary] = []
var burn_pools: Array[Dictionary] = []

func reset_for_reload() -> void:
    projectiles.clear()
    burn_pools.clear()

func throw_velocity(speed: float, angle_rad: float) -> Vector2:
    if speed <= 0.0:
        return Vector2.ZERO
    return Vector2(cos(angle_rad), sin(angle_rad)) * speed

func throw_grenade(speed: float, angle_rad: float) -> Dictionary:
    var velocity := throw_velocity(speed, angle_rad)
    if velocity == Vector2.ZERO:
        return {}
    var projectile := {"position": Vector2.ZERO, "velocity": velocity, "active": true}
    projectiles.append(projectile)
    return projectile

func advance_projectile(projectile: Dictionary, delta: float) -> bool:
    if delta <= 0.0 or not projectile.get("active", false):
        return false
    projectile["position"] = projectile["position"] + projectile["velocity"] * delta
    if projectile["position"].y < -1000.0:
        projectile["active"] = false
    return true

func spawn_burn_pool(position: Vector2, radius: float, duration: float) -> Dictionary:
    if radius <= 0.0 or duration <= 0.0:
        return {}
    var pool := {
        "position": position,
        "radius": radius,
        "duration": duration,
        "remaining": duration,
        "active": true,
    }
    burn_pools.append(pool)
    return pool

func advance_burn_pool(pool: Dictionary, delta: float) -> bool:
    if delta <= 0.0 or not pool.get("active", false):
        return false
    pool["remaining"] = maxf(0.0, float(pool["remaining"]) - delta)
    if pool["remaining"] <= 0.0:
        pool["active"] = false
    return true

func smoke_state(elapsed: float, lifetime: float) -> String:
    if lifetime <= 0.0 or elapsed >= lifetime:
        return "extinguished"
    return "active"

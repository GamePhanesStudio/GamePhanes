extends Node
class_name GrenadePhysics

var projectiles: Array[Dictionary] = []
var burn_pools: Array[Dictionary] = []

func reset_for_reload() -> void:
    projectiles.clear()
    burn_pools.clear()

func throw_velocity(speed: float, angle_rad: float) -> Vector2:
    return Vector2.ZERO

func throw_grenade(speed: float, angle_rad: float) -> Dictionary:
    return {}

func advance_projectile(projectile: Dictionary, delta: float) -> bool:
    return false

func spawn_burn_pool(position: Vector2, radius: float, duration: float) -> Dictionary:
    return {}

func advance_burn_pool(pool: Dictionary, delta: float) -> bool:
    return false

func smoke_state(elapsed: float, lifetime: float) -> String:
    return "extinguished"

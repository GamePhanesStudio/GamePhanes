extends Node2D
class_name NightZone

var night_mode := false
var landmarks: Array[String] = []
var weapons: Dictionary = {}
var enemy_growth := 1.0
var path_cost_multiplier := 1.0

func configure_night_mode() -> void:
    night_mode = true
    landmarks = ["quarantine_tower", "flooded_checkpoint"]
    weapons = {"silenced_carbine": {"damage": 24.0, "noise": 0.2}}
    enemy_growth = 1.25
    path_cost_multiplier = 0.8

func spawn_enemy(wave: int) -> Dictionary:
    var level := maxi(1, wave)
    return {"health": 10.0 * pow(enemy_growth, level - 1), "speed": 1.0 + 0.1 * (level - 1)}

func path_cost(base_cost: float) -> float:
    return maxf(0.0, base_cost) * path_cost_multiplier

func snapshot() -> Dictionary:
    return {"night_mode": night_mode, "landmarks": landmarks.duplicate(), "weapons": weapons.duplicate(true), "enemy_growth": enemy_growth, "path_cost_multiplier": path_cost_multiplier}

func reset_for_test() -> void:
    night_mode = false
    landmarks.clear()
    weapons.clear()
    enemy_growth = 1.0
    path_cost_multiplier = 1.0

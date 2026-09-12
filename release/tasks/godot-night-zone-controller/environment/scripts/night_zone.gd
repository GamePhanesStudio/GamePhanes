extends Node2D
class_name NightZone

var night_mode := false
var landmarks: Array[String] = []
var weapons: Dictionary = {}
var enemy_growth := 1.0
var path_cost_multiplier := 1.0
var _event_ids: Dictionary = {}

func configure_night_mode() -> void:
    # Starter defect: the event is accepted but does not apply the night rules.
    night_mode = false

func spawn_enemy(wave: int) -> Dictionary:
    var level := maxi(1, wave)
    return {"health": 10.0 * pow(enemy_growth, level - 1), "speed": 1.0 + 0.1 * (level - 1)}

func path_cost(base_cost: float) -> float:
    return maxf(0.0, base_cost) * path_cost_multiplier

func snapshot() -> Dictionary:
    return {"night_mode": night_mode, "landmarks": landmarks.duplicate(), "weapons": weapons.duplicate(true), "enemy_growth": enemy_growth, "path_cost_multiplier": path_cost_multiplier}

func handle_event(event_name: String, payload: Dictionary = {}) -> bool:
    var event_id := str(payload.get("event_id", ""))
    if event_id.is_empty() or _event_ids.has(event_id):
        return false
    _event_ids[event_id] = true
    match event_name:
        "configure":
            configure_night_mode()
            return true
        "spawn":
            var wave := int(payload.get("wave", 0))
            if wave < 1 or not night_mode:
                _event_ids.erase(event_id)
                return false
            spawn_enemy(wave)
            return true
        "path_cost":
            var base := float(payload.get("base", -1.0))
            if base < 0.0 or not night_mode:
                _event_ids.erase(event_id)
                return false
            path_cost(base)
            return true
        _:
            _event_ids.erase(event_id)
            return false

func reset_for_test() -> void:
    night_mode = false
    landmarks.clear()
    weapons.clear()
    enemy_growth = 1.0
    path_cost_multiplier = 1.0
    _event_ids.clear()

extends Node
class_name InkSansState

signal health_changed(previous_hp: int, current_hp: int)
signal defeated

@export_range(1, 9999, 1) var max_hp: int = 100
var hp: int = 100
var _hits: int = 0

func hit(amount: int) -> bool:
    if amount <= 0 or not alive():
        return false
    var previous_hp := hp
    hp = maxi(0, hp - amount)
    _hits += 1
    health_changed.emit(previous_hp, hp)
    if previous_hp > 0 and hp == 0:
        defeated.emit()
    return true

func reset() -> void:
    var previous_hp := hp
    hp = max_hp
    _hits = 0
    if previous_hp != hp:
        health_changed.emit(previous_hp, hp)

func alive() -> bool:
    return hp > 0

func snapshot() -> Dictionary:
    return {
        "hp": hp,
        "max_hp": max_hp,
        "hits": _hits,
        "alive": alive(),
    }

extends Node
class_name InkSansState

@export_range(1, 9999, 1) var max_hp: int = 100
var hp: int = 100
var _hits: int = 0

func hit(amount: int) -> void:
	hp -= amount

func reset() -> void:
	hp = max_hp
	_hits = 0

func snapshot() -> Dictionary:
	return {"hp": hp, "max_hp": max_hp, "hits": _hits}

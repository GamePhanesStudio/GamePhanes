extends RefCounted
class_name EndlessLevel

var seed_value := 0

func configure_seed(_value: int) -> void:
    pass

func generate_chunk(_index: int) -> Array[Dictionary]:
    return []

func unlocked(entity_id: String, progress: int) -> bool:
    return not entity_id.is_empty() and progress > 0

func snapshot() -> Dictionary:
    return {"seed": seed_value, "chunks": []}

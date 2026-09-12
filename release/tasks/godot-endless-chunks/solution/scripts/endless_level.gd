extends RefCounted
class_name EndlessLevel

var seed_value := 0
var chunks: Dictionary = {}

func configure_seed(value: int) -> void:
    seed_value = value
    chunks.clear()

func generate_chunk(index: int) -> Array[Dictionary]:
    if index < 0:
        return []
    if chunks.has(index):
        return chunks[index].duplicate(true)
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value + index * 7919
    var generated: Array[Dictionary] = []
    for slot in 6:
        var gap := rng.randf() < 0.35
        generated.append({"slot": slot, "platform": not gap, "spike": gap, "height": rng.randi_range(2, 8)})
    chunks[index] = generated.duplicate(true)
    return generated

func unlocked(entity_id: String, progress: int) -> bool:
    return not entity_id.is_empty() and progress >= 3

func snapshot() -> Dictionary:
    return {"seed": seed_value, "chunks": chunks.duplicate(true)}

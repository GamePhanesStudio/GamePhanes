extends CharacterBody2D
class_name PixelPlayer

@export var speed := 180.0
var spawn_position := Vector2.ZERO
var last_input := Vector2.ZERO

func _ready() -> void:
	spawn_position = global_position

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	last_input = direction
	velocity = direction * speed
	move_and_slide()

func reset_player() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO

func snapshot() -> Dictionary:
	return {"position": global_position, "velocity": velocity, "last_input": last_input}

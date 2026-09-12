extends Node2D

@onready var grenade_physics: GrenadePhysics = $GrenadePhysics

func _ready() -> void:
    queue_redraw()

func preview_throw(speed: float, angle_rad: float) -> Dictionary:
    return grenade_physics.throw_grenade(speed, angle_rad)

func _draw() -> void:
    draw_circle(Vector2(320, 180), 18.0, Color("4fd1c5"))
    draw_line(Vector2(320, 180), Vector2(390, 180), Color("f6ad55"), 3.0)

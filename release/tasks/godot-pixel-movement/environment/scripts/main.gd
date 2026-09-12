extends Node2D

@onready var player = $Player
@onready var position_label: Label = $HUD/Panel/VBox/PositionLabel
@onready var status_label: Label = $HUD/Panel/VBox/StatusLabel

func _ready() -> void:
	_refresh_hud()

func _physics_process(_delta: float) -> void:
	_refresh_hud()

func _refresh_hud() -> void:
	if not is_instance_valid(player):
		return
	var p: Vector2 = player.global_position
	position_label.text = "Player: (%d, %d)" % [roundi(p.x), roundi(p.y)]
	status_label.text = "WASD to move"

func reset_player() -> void:
	player.reset_player()
	_refresh_hud()

extends SceneTree
func _initialize() -> void:
    var packed = load("res://Main.tscn")
    if packed == null: quit(1); return
    var game = packed.instantiate()
    root.add_child(game)
    await process_frame
    var player = game.get_node("Player")
    var hud = game.get_node("HUD/Panel/VBox")
    var start: Vector2 = player.global_position
    Input.action_press("move_right")
    for i in range(12):
        await physics_frame
    var moved: Vector2 = player.global_position
    if moved.x <= start.x + 8.0: quit(1); return
    if player.velocity.length() > 180.5: quit(1); return
    Input.action_press("move_down")
    for i in range(12):
        await physics_frame
    Input.action_release("move_down")
    Input.action_release("move_right")
    if player.last_input.length() > 1.01: quit(1); return
    var wall_x := float(game.get_node("Wall").global_position.x)
    Input.action_press("move_right")
    for i in range(45):
        await physics_frame
    Input.action_release("move_right")
    var blocked: Vector2 = player.global_position
    if blocked.x >= wall_x - 10.0: quit(1); return
    game.reset_player()
    await physics_frame
    var reset_pos: Vector2 = player.global_position
    if reset_pos.distance_to(start) > 0.1 or player.velocity.length() > 0.1: quit(1); return
    game.reset_player()
    if player.global_position.distance_to(start) > 0.1: quit(1); return
    get_root().size = Vector2i(320, 180)
    await process_frame
    var panel_rect: Rect2 = game.get_node("HUD/Panel").get_global_rect()
    var label_text := str(hud.get_node("PositionLabel").text)
    if label_text.is_empty() or not hud.get_node("StatusLabel").visible: quit(1); return
    if panel_rect.position.x < 0.0 or panel_rect.position.y < 0.0 or panel_rect.end.x > 320.0 or panel_rect.end.y > 180.0: quit(1); return
    print("PIXEL_MOVEMENT_PROBE_OK"); quit(0)

extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_focus_loss_smoke.gd
const Stage2 = preload("res://prototypes/stage2_playable.gd")

func _initialize() -> void:
	var game = Stage2.new()
	game.touch_id = 4
	game.fire_touch_id = 5
	game.touch_move = Vector2(120, 140)
	game.touch_fire = true
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var errors: Array[String] = []
	if not game.paused:
		errors.append("Focus loss must pause live combat")
	if game.touch_id != -1 or game.fire_touch_id != -1:
		errors.append("Focus loss must release both touch IDs")
	if game.touch_fire or game.touch_move != Vector2.ZERO:
		errors.append("Focus loss must clear virtual fire and movement")
	var before: float = game.elapsed
	game._process(0.5)
	if game.elapsed != before:
		errors.append("Combat time must not advance while unfocused")
	game.state = "clear"
	game.paused = false
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	if game.paused:
		errors.append("Focus loss must not alter terminal result state")
	game.free()
	if errors.is_empty():
		print("PASS: stage 2 focus loss pauses combat and clears touch controls")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_mobile_pause_smoke.gd
const Stage2 = preload("res://prototypes/stage2_playable.gd")

func _initialize() -> void:
	var game = Stage2.new()
	root.add_child(game)
	var errors: Array[String] = []
	var touch := InputEventScreenTouch.new()
	touch.index = 1
	touch.pressed = true
	touch.position = Vector2(570, 30)
	game._input(touch)
	if not game.paused:
		errors.append("Pause touch target must pause live combat")
	if game.touch_id != -1 or game.fire_touch_id != -1:
		errors.append("Pausing must release virtual touch controls")
	var before := game.elapsed
	game._process(0.2)
	if game.elapsed != before:
		errors.append("Combat must freeze during mobile pause")
	touch.position = Vector2(300, 194)
	game._input(touch)
	if game.paused:
		errors.append("Resume touch target must resume combat")
	if game.touch_fire or game.touch_id != -1:
		errors.append("Resume touch must not latch firing or movement")
	game.queue_free()
	if errors.is_empty():
		print("PASS: stage 2 mobile pause and resume touch targets")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

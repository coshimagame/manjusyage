extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_pause_touch_release_smoke.gd
const Stage2 = preload("res://prototypes/stage2_playable.gd")

func _initialize() -> void:
	var stage = Stage2.new()
	var errors: Array[String] = []
	stage.state = "playing"
	stage.touch_id = 2
	stage.touch_move = Vector2(130, 120)
	stage.fire_touch_id = 3
	stage.touch_fire = true
	var pause_key = InputEventKey.new()
	pause_key.keycode = KEY_P
	pause_key.pressed = true
	stage._input(pause_key)
	if not stage.paused:
		errors.append("P must pause combat")
	for finger in [2, 3]:
		var release = InputEventScreenTouch.new()
		release.index = finger
		release.pressed = false
		stage._input(release)
	if stage.touch_id != -1 or stage.touch_move != Vector2.ZERO:
		errors.append("Movement touch must release during pause")
	if stage.fire_touch_id != -1 or stage.touch_fire:
		errors.append("Fire touch must release during pause")
	stage._input(pause_key)
	if stage.paused:
		errors.append("P must resume combat")
	if stage.touch_fire or stage.touch_id != -1:
		errors.append("Resume must not latch prior touch controls")
	stage.free()
	if errors.is_empty():
		print("PASS: paused touch release clears movement and fire")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

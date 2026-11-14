extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_pause_clear_input_smoke.gd
const Stage2 = preload("res://prototypes/stage2_playable.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	for use_gamepad in [false, true]:
		var stage = Stage2.new()
		stage.state = "playing"
		stage.touch_id = 2
		stage.touch_move = Vector2(160, 110)
		stage.fire_touch_id = 3
		stage.touch_fire = true
		if use_gamepad:
			var event = InputEventJoypadButton.new()
			event.button_index = JOY_BUTTON_START
			event.pressed = true
			stage._input(event)
		else:
			var event = InputEventKey.new()
			event.keycode = KEY_P
			event.pressed = true
			stage._input(event)
		if not stage.paused:
			errors.append("Pause input must pause combat")
		if stage.touch_id != -1 or stage.fire_touch_id != -1 or stage.touch_fire or stage.touch_move != Vector2.ZERO:
			errors.append("Pausing must clear all held touch controls")
		stage.free()
	if errors.is_empty():
		print("PASS: keyboard and gamepad pause clear held touch controls")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

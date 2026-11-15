extends SceneTree
# Result navigation smoke: does not alter player save data.
func _initialize() -> void:
	var scene: PackedScene = load("res://prototypes/stage2_playable.tscn")
	assert(scene != null)
	var stage = scene.instantiate()
	stage.state = "gameover"
	var b := InputEventJoypadButton.new()
	b.pressed = true
	b.button_index = JOY_BUTTON_B
	stage._input(b)
	assert(stage.state == "gameover", "B must not retry")
	var a := InputEventJoypadButton.new()
	a.pressed = true
	a.button_index = JOY_BUTTON_A
	stage._input(a)
	assert(stage.state == "playing", "A must retry")
	stage.state = "clear"
	var q := InputEventKey.new()
	q.pressed = true
	q.keycode = KEY_Q
	stage._input(q)
	assert(stage.state == "clear", "Q must not retry")
	stage.free()
	print("PASS: Stage 2 result navigation")
	quit(0)

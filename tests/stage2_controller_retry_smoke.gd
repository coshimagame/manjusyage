extends SceneTree
# Controller retry regression. No save files are touched.
func _initialize() -> void:
	var packed: PackedScene = load("res://prototypes/stage2_playable.tscn")
	assert(packed != null, "Stage 2 scene missing")
	var stage = packed.instantiate()
	stage.state = "gameover"
	stage.hp = 0
	stage.enemy_hp = 1
	stage.touch_fire = true
	stage.touch_id = 3
	stage.elapsed = 23.0
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_A
	button.pressed = true
	stage._input(button)
	assert(stage.state == "playing", "Controller A must retry")
	assert(stage.hp == 5 and stage.enemy_hp == 30, "Retry must reset combat")
	assert(not stage.touch_fire and stage.touch_id == -1, "Retry must clear touch")
	assert(is_zero_approx(stage.elapsed), "Retry must reset time")
	stage.state = "clear"
	button.button_index = JOY_BUTTON_START
	stage._input(button)
	assert(stage.state == "playing", "Controller Start must retry after clear")
	stage.free()
	print("PASS: Stage 2 controller retry and state reset")
	quit(0)

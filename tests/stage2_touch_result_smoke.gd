extends SceneTree
# Stage-2 touch result smoke; no campaign progress is written.
# Run: godot --headless --path . --script res://tests/stage2_touch_result_smoke.gd
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://prototypes/stage2_playable.tscn")
	assert(packed != null, "Stage 2 scene must load")
	var stage: Node2D = packed.instantiate()
	root.add_child(stage)
	await process_frame
	stage.state = "gameover"
	stage.hp = 0
	var left := InputEventScreenTouch.new()
	left.index = 3
	left.pressed = true
	left.position = Vector2(160, 180)
	stage._input(left)
	assert(stage.state == "playing", "Left result tap should retry")
	assert(stage.hp == 5, "Retry must restore HP")
	assert(stage.touch_id == -1, "Result tap must not become a movement touch")
	assert(not stage.touch_fire, "Result tap must not fire")
	var release := InputEventScreenTouch.new()
	release.index = 3
	release.pressed = false
	release.position = Vector2(160, 180)
	stage._input(release)
	assert(stage.touch_id == -1, "Released result finger must remain cleared")
	stage.state = "gameover"
	var b := InputEventJoypadButton.new()
	b.button_index = JOY_BUTTON_B
	b.pressed = true
	# Do not navigate in this isolated test: _return_to_title requires a current scene.
	stage._input(b)
	assert(stage.state == "gameover", "B must not retry")
	stage.queue_free()
	await process_frame
	print("PASS: Stage 2 touch result retry and controller exit guard")
	quit(0)

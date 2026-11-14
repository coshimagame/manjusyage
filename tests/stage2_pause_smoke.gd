extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_pause_smoke.gd
const Stage = preload("res://prototypes/stage2_playable.gd")

func _initialize() -> void:
	var scene = Stage.new()
	root.add_child(scene)
	var before = scene.elapsed
	scene.paused = true
	scene._process(0.5)
	if scene.elapsed != before:
		push_error("Paused combat advanced its clock")
		quit(1)
		return
	scene.paused = false
	scene._process(0.1)
	if scene.elapsed <= before:
		push_error("Resumed combat did not advance")
		quit(1)
		return
	scene.paused = true
	scene._restart()
	if scene.paused or scene.state != "playing":
		push_error("Retry did not clear pause state")
		quit(1)
		return
	print("PASS: stage 2 pause/resume/retry state")
	quit(0)

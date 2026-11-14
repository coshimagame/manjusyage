extends SceneTree
# Run with: godot --headless --path . --script res://tests/stage2_briefing_launch_smoke.gd
# Uses in-memory progress only; does not touch user://.
const Progress = preload("res://briefing_progress.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	var progress = Progress.new()
	if progress.can_launch(2):
		errors.append("Stage 2 must stay locked before Stage 1 clear")
	progress.highest_unlocked = 2
	progress.cleared[1] = true
	if not progress.can_launch(2):
		errors.append("Unlocked Stage 2 prototype must be launchable")
	var scene = load("res://prototypes/stage2_playable.tscn")
	if scene == null:
		errors.append("Stage 2 scene failed to load")
	else:
		var instance = scene.instantiate()
		if instance == null:
			errors.append("Stage 2 scene failed to instantiate")
		else:
			if not instance.has_signal("stage_cleared"):
				errors.append("Stage 2 clear signal missing")
			if not instance.has_method("_restart"):
				errors.append("Stage 2 retry missing")
			instance.free()
	if errors.is_empty():
		print("PASS: Stage 2 briefing gate and scene load")
		quit(0)
	else:
		for message in errors:
			push_error(message)
		quit(1)

extends SceneTree
# Isolated integration smoke; never writes real player save data.
const Progress = preload("res://briefing_progress.gd")
func _initialize() -> void:
	var progress = Progress.new()
	assert(not progress.can_launch(2), "Stage 2 must be locked before stage 1 clear")
	progress.highest_unlocked = 2
	assert(progress.can_launch(2), "Stage 2 must unlock after stage 1")
	var packed = load("res://prototypes/stage2_playable.tscn")
	assert(packed != null, "Stage 2 scene missing")
	var scene = packed.instantiate()
	assert(scene != null and scene.has_method("_restart"), "Stage 2 must be retryable")
	assert(scene.has_signal("stage_cleared"), "Stage 2 must report victory")
	scene.free()
	print("PASS: stage2 scene, unlock and retry contract")
	quit(0)

extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_progress_preservation_smoke.gd
# Uses an isolated temporary save, never the player's normal progress.
const Progress = preload("res://briefing_progress.gd")
const TEST_SAVE = "user://stage2_progress_preservation_smoke.cfg"

func _initialize() -> void:
	var errors: Array[String] = []
	var original = Progress.new()
	original.save_path = TEST_SAVE
	original.highest_unlocked = 2
	original.cleared[1] = true
	if original.save_data() != OK:
		errors.append("Could not create isolated save")
	else:
		# This must match the Stage 2 boss-clear sequence: load then mark.
		var stage2 = Progress.new()
		stage2.save_path = TEST_SAVE
		stage2.load_data()
		stage2.mark_cleared(2)
		var reloaded = Progress.new()
		reloaded.save_path = TEST_SAVE
		reloaded.load_data()
		if not bool(reloaded.cleared.get(1, false)):
			errors.append("Stage 1 completion was lost")
		if not bool(reloaded.cleared.get(2, false)):
			errors.append("Stage 2 completion was not saved")
		if reloaded.highest_unlocked != 3:
			errors.append("Stage 3 briefing should unlock")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	if errors.is_empty():
		print("PASS: Stage 2 completion preserves Stage 1 progress")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

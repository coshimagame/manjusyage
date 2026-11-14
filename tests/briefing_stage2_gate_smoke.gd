extends SceneTree
# Regression guard: narrative unlock does not imply playable stage availability.
# Run: godot --headless --path . --script res://tests/briefing_stage2_gate_smoke.gd
const Progress = preload("res://briefing_progress.gd")

func _initialize() -> void:
	var progress = Progress.new()
	var errors: Array[String] = []
	if not progress.can_select(1):
		errors.append("Stage 1 must be selectable at fresh start")
	if not progress.can_launch(1):
		errors.append("Stage 1 must remain playable")
	if progress.can_select(2):
		errors.append("Stage 2 must be locked before stage 1 clear")
	# In-memory state only: never touch the player's user:// save.
	progress.highest_unlocked = 2
	progress.cleared[1] = true
	if not progress.can_select(2):
		errors.append("Stage 2 briefing must unlock after stage 1 clear")
	if progress.has_gameplay(2):
		errors.append("Stage 2 must not claim gameplay until integrated into main")
	if progress.can_launch(2):
		errors.append("Unintegrated stage 2 must not launch from main")
	if progress.next_briefing_stage() != 2:
		errors.append("Next briefing must target stage 2")
	if errors.is_empty():
		print("PASS: stage 1 playable; stage 2 briefing unlocked but gameplay gated")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

extends SceneTree
# Godot 4.6: godot --headless --path . --script tests/test_briefing_progress.gd
const Progress=preload("res://briefing_progress.gd")

func _initialize():
	var progress=Progress.new()
	progress.save_path="user://test_briefing_progress_isolated.cfg"
	progress.load_data()
	progress.highest_unlocked=1
	progress.cleared.clear()
	assert(progress.can_select(1))
	assert(progress.can_launch(1))
	assert(not progress.can_select(2))
	assert(not progress.feature_available("mafio"))
	progress.mark_cleared(1)
	assert(progress.highest_unlocked==2)
	assert(progress.can_select(1) and progress.can_select(2))
	assert(progress.can_launch(1) and progress.can_launch(2)) # STAGE-001: stage 2 is playable once unlocked.
	assert(progress.next_briefing_stage()==2)
	var reloaded=Progress.new()
	reloaded.save_path=progress.save_path
	reloaded.load_data()
	assert(reloaded.highest_unlocked==2 and reloaded.cleared.get(1,false))
	reloaded.highest_unlocked=4
	assert(reloaded.feature_available("mafio"))
	assert(not reloaded.feature_available("jiyoza"))
	reloaded.highest_unlocked=5
	assert(reloaded.feature_available("jiyoza") and not reloaded.feature_available("cormii"))
	reloaded.highest_unlocked=6
	assert(reloaded.feature_available("cormii"))
	assert(reloaded.can_launch(6)) # Unlocked stages are launchable (all 8 playable).
	DirAccess.remove_absolute(ProjectSettings.globalize_path(progress.save_path))
	print("BRIEFING PASS: stage-1 immediate launch, stage-2 unlock and launch, stage-1 replay, feature milestones")
	quit(0)

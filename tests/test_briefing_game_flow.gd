extends SceneTree
# Run headless with an isolated Godot user:// profile.
func _initialize(): run.call_deferred()

func run():
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.briefing_progress.save_path="user://test_briefing_game_flow.cfg"
	game.briefing_progress.highest_unlocked=1
	game.briefing_progress.cleared.clear()
	game.count=3
	game.pilot_offset=1
	game.slice_mode=false # Full-game flow (slice mode pins runs to the stage-1 demo).
	game.start_game()
	assert(game.mode=="play")
	assert(game.players.map(func(p):return p.character)==[1,2,0])
	assert(not game.briefing_progress.can_select(2))
	assert(not game.briefing_progress.feature_available("mafio"))
	game.finish(true)
	assert(game.mode=="clear" and game.briefing_progress.can_select(2))
	game.open_briefing(2)
	assert(game.mode=="briefing" and game.briefing_stage==2)
	# STAGE-001: stage 2 is playable once unlocked; launching enters play on stage 2.
	game.launch_from_briefing()
	assert(game.mode=="play" and game.current_stage==2)
	game.briefing_stage=1
	game.briefing_slot=0
	game.change_briefing_character()
	assert(game.briefing_chars.slice(0,3)==[2,1,0])
	game.launch_from_briefing()
	assert(game.mode=="play" and game.players[0].character==2)
	assert(game.players[1].character==1 and game.players[2].character==0)
	assert(game.briefing_progress.highest_unlocked==2)
	var progress_path=game.briefing_progress.save_path
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(progress_path))
	print("BRIEFING FLOW PASS: stage-1 launch, clear unlock, stage-2 launch, stage-1 replay and pilot swaps")
	quit(0)

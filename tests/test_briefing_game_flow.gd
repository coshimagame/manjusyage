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
	game.start_game()
	assert(game.mode=="play")
	assert(game.players.map(func(p):return p.character)==[1,2,0])
	assert(not game.briefing_progress.can_select(2))
	assert(not game.briefing_progress.feature_available("mafio"))
	game.finish(true)
	assert(game.mode=="clear" and game.briefing_progress.can_select(2))
	game.players[1].experience=11
	game.open_stage1_intermission()
	assert(game.mode=="intermission")
	game.get_child(-1)._complete(false)
	assert(game.mode=="play" and game.stage_number==2 and game.music_name=="bgm_stage02_plan_a")
	assert(game.players.map(func(p):return p.character)==[1,2,0] and game.players[1].experience==11)
	game.spawn_wave()
	for enemy in game.enemies: assert(game.visual.sea_textures.has(enemy.art_id))
	game.elapsed=10.49
	game.update_game(.02)
	assert(game.shots.filter(func(s):return s.has("tide")).size()==5)
	game.elapsed=23.99
	game.update_game(.02)
	assert(game.boss.max==66 and game.music_name=="bgm_boss01_plan_b")
	var prior=FileAccess.get_file_as_string("user://last_run.json")
	game.finish(true)
	assert(FileAccess.get_file_as_string("user://last_run.json")==prior)
	assert(JSON.parse_string(FileAccess.get_file_as_string("user://last_run_stage2.json")).cleared)
	game.open_stage1_intermission()
	assert(game.mode=="menu" and game.can_resume_sea())
	var key=InputEventKey.new()
	key.physical_keycode=KEY_N; key.pressed=true
	game._input(key)
	assert(game.stage_number==2 and game.mode=="play")
	var progress_path=game.briefing_progress.save_path
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(progress_path))
	print("BRIEFING FLOW PASS: stage-1 launch, clear unlock, same crew, tides, stage-2 boss and resume")
	quit(0)

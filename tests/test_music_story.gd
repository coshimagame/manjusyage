extends SceneTree

func _initialize(): run.call_deferred()

func run():
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.music_name=="bgm_opening_plan_a")
	assert(game.music.stream.get_length()>20)
	game.start_game()
	assert(game.music_name=="bgm_stage01_plan_a")
	game.begin_boss()
	assert(game.music_name=="bgm_boss01_plan_a")
	assert(game.boss.max==58)
	game.update_boss(2.6)
	assert(game.shots.size()==5)
	game.finish(true)
	assert(game.music_name=="jg007_stage_clear")
	assert(game.music.stream.loop_mode==AudioStreamWAV.LOOP_DISABLED)
	assert(game.music.stream.get_length()>1)
	assert(game.music.playing)
	game.queue_free()
	await process_frame
	await process_frame
	print("MUSIC/BOSS PASS: title, stage, boss, safe ending fallback, playback, HP and volley")
	quit()

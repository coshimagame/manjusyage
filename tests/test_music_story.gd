extends SceneTree

func _initialize(): run.call_deferred()

func run():
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	game.slice_mode=false # Music/story expectations describe the full game, not the slice.
	await process_frame
	assert(game.music_name=="title")
	assert(game.music.stream.get_length()>20)
	game.start_game()
	assert(game.music_name=="ruins")
	game.begin_boss()
	assert(game.music_name=="sentinel")
	assert(game.boss.max==100)
	game.update_boss(2.6)
	assert(game.shots.size()==5)
	game.finish(true)
	assert(game.music_name==("ending" if ResourceLoader.exists("res://audio/ending.wav") else "title"))
	assert(game.music.stream.get_length()>20)
	assert(game.music.playing)
	game.queue_free()
	await process_frame
	await process_frame
	print("MUSIC/BOSS PASS: title, stage, boss, safe ending fallback, playback, HP and volley")
	quit()

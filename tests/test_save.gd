extends SceneTree

func _initialize():
	call_deferred("run")

func run():
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.count=2
	scene.bio_route=true
	# This test verifies the persistent high-score route.  v0.9 defaults to the
	# short slice, whose results deliberately do not replace the legacy best score.
	scene.slice_mode=false
	scene.start_game()
	scene.score=4321
	scene.gates_done=2
	scene.finish(true)
	var cfg=ConfigFile.new()
	assert(cfg.load("user://scores.cfg")==OK)
	assert(int(cfg.get_value("scores","1",0))>=10321)
	var record=JSON.parse_string(FileAccess.get_file_as_string("user://last_run.json"))
	assert(record.players==2 and record.cleared and record.gates==2 and record.ruleset=="ruins-v1")
	scene.start_game()
	scene.reserves=0
	for p in scene.players: p.down=1
	scene.update_game(.016)
	assert(scene.mode=="over")
	print("PERSISTENCE / GAME OVER PASS: per-player-count best, run schema, all-down loss")
	scene.music.stop()
	for player in scene.sfx_pool: player.stop()
	await create_timer(.3).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	call_deferred("quit")

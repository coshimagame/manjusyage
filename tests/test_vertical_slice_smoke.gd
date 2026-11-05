extends SceneTree
# Vertical-slice regression: real scene initialization, pilot selection, boss and results.
# Run with an isolated Godot user-data directory; never use a player's real saves.
func _initialize():
	run.call_deferred()

func run():
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	assert(game.mode == "menu", "Expected title/menu at startup")
	for player_count in [1, 2, 3]:
		game.count = player_count
		game.pilot_offset = 0
		game.start_game()
		assert(game.mode == "play", "Stage 1 did not start")
		assert(game.players.size() == player_count, "Incorrect squad size")
		for i in range(player_count):
			assert(game.players[i].character == i, "Incorrect pilot assignment")
		game.begin_boss()
		assert(game.boss.size() > 0, "Boss was not initialized")
		game.finish(true)
		assert(game.mode == "clear", "Clear result did not open")
		game.open_briefing(2)
		assert(game.mode == "briefing", "Next-stage briefing missing")
		# Stage 2 has no playable combat yet; this must not silently launch it.
		game.launch_from_briefing()
		assert(game.mode == "briefing", "Unimplemented stage 2 launched")
	game.queue_free()
	await process_frame
	print("VERTICAL SLICE SMOKE PASS: 1-3P title, stage1, boss, clear, stage2 lock")
	quit(0)

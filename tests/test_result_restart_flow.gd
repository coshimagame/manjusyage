extends SceneTree
# Headless regression: the real game script must be able to enter the result
# state and restart without losing the selected pilot count.
# Run with an isolated user:// profile:
# godot --headless --path . --script tests/test_result_restart_flow.gd
const Game = preload("res://game.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = Game.new()
	root.add_child(game)
	await process_frame
	if game.mode != "menu":
		_fail("Expected title/menu on startup")
		return
	for pilot_count in [1, 2, 3]:
		game.count = pilot_count
		game.start_game()
		if game.mode != "play" or game.players.size() != pilot_count:
			_fail("Start failed for %d players" % pilot_count)
			return
		game.mode = "clear"
		game.result_delay = 0.0
		game.queue_redraw()
		await process_frame
		if game.mode != "clear":
			_fail("Clear result state was lost")
			return
		game.start_game()
		if game.mode != "play" or game.players.size() != pilot_count:
			_fail("Restart failed for %d players" % pilot_count)
			return
	print("PASS: result -> retry for 1, 2 and 3 pilots")
	game.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)

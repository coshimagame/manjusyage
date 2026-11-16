extends SceneTree
# Run with: godot --headless --path . --script res://tests/stage1_boss_flow_smoke.gd
# Uses a separate --user-data-dir when possible; this script does not write saves.
const Game = preload("res://game.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = Game.new()
	root.add_child(game)
	await process_frame
	_assert(game.mode == "menu", "menu should be the initial state")
	game.auto_test = true # Avoid persistent save writes and sound playback on finish.
	game.count = 1
	game.start_game()
	_assert(game.mode == "play", "start_game should enter gameplay")
	_assert(game.players.size() == 1, "one player should be created")
	game.begin_boss()
	_assert(not game.boss.is_empty(), "stage 1 boss should be initialized")
	_assert(float(game.boss.get("hp", 0)) > 0.0, "boss must have positive HP")
	game.finish(true)
	_assert(game.mode == "clear", "victory should enter clear result")
	game.queue_free()
	await process_frame
	print("PASS: menu -> one-player sortie -> stage 1 boss -> clear")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: " + message)
		quit(1)
		assert(false, message)

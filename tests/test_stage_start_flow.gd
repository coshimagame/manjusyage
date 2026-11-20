extends SceneTree
# Regression test for the playable stage-1 entry point.
# Run with an isolated user-data profile:
# godot --headless --path . --script tests/test_stage_start_flow.gd

const Game = preload("res://game.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = Game.new()
	root.add_child(game)
	await process_frame
	var errors: Array[String] = []
	game.count = 3
	game.pilot_offset = 0
	game.start_game()
	if game.mode != "play":
		errors.append("start_game must enter play mode")
	if game.players.size() != 3:
		errors.append("three-player start must create three pilots")
	if game.reserves != 9:
		errors.append("three-player reserve count must be 9")
	if game.wave_id != 0 or game.score != 0:
		errors.append("new sortie must reset score and wave")
	for i in range(game.players.size()):
		var pilot: Dictionary = game.players[i]
		if not pilot.has("pos") or not pilot.has("hp") or not pilot.has("character"):
			errors.append("pilot %d missing required runtime fields" % i)
	game.queue_free()
	await process_frame
	if errors.is_empty():
		print("PASS: stage-1 three-player start state")
		quit(0)
	else:
		for message in errors:
			push_error("FAIL: " + message)
		quit(1)

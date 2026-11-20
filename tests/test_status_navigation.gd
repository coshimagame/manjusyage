extends SceneTree
# Godot 4.6 headless: godot --headless --path . --script res://tests/test_status_navigation.gd
# Uses the real game scene; does not overwrite player save files.
func _initialize() -> void:
	call_deferred("run")

func press(game: Node, key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	game._input(event)

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	for party_size in [1, 2, 3]:
		game.count = party_size
		game.pilot_offset = 0
		game.start_game()
		assert(game.mode == "play")
		press(game, KEY_TAB)
		assert(game.mode == "status", "TAB should open status")
		assert(game.status_slot == 0)
		press(game, KEY_LEFT)
		assert(game.status_slot == party_size - 1, "Left should wrap to last pilot")
		press(game, KEY_RIGHT)
		assert(game.status_slot == 0, "Right should wrap to first pilot")
		press(game, KEY_ESCAPE)
		assert(game.mode == "play", "ESC should return to play")
		press(game, KEY_ESCAPE)
		assert(game.mode == "pause", "ESC should pause")
		press(game, KEY_TAB)
		assert(game.mode == "status", "TAB should open status while paused")
		press(game, KEY_ENTER)
		assert(game.mode == "pause", "Closing status must preserve pause")
		press(game, KEY_ESCAPE)
		assert(game.mode == "play", "ESC should resume")
	print("STATUS NAVIGATION PASS: 1-3P wrapping and pause return")
	game.music.stop()
	for player in game.sfx_pool:
		player.stop()
	game.queue_free()
	await process_frame
	quit(0)

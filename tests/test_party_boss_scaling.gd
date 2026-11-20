extends SceneTree
# Godot 4.6 headless regression for the actual Stage 1 combat scene.
# Run: godot --headless --path . --script res://tests/test_party_boss_scaling.gd
# Does not modify user:// saves or replace approved art.
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		_check(false, "main.tscn loads")
		quit(1)
		return
	var game := packed.instantiate()
	# Avoid autoplay and audio hardware dependence while exercising real combat.
	game.auto_test = true
	game.test_count = 1
	root.add_child(game)
	for n in range(1, 4):
		game.count = n
		game.pilot_offset = 0
		game.start_game()
		_check(game.mode == "play", "%dP enters gameplay" % n)
		_check(game.players.size() == n, "%dP spawns correct number of ships" % n)
		_check(game.reserves == n * 3, "%dP reserve count" % n)
		for i in range(game.players.size()):
			var p: Dictionary = game.players[i]
			_check(p.has("character") and int(p.character) == i, "%dP pilot slot %d" % [n, i])
			_check(p.has("hp") and int(p.hp) == 4, "%dP initial HP slot %d" % [n, i])
		game.begin_boss()
		_check(not game.boss.is_empty(), "%dP boss spawned" % n)
		_check(float(game.boss.hp) > 0.0, "%dP boss has HP" % n)
		_check(float(game.boss.max) == float(game.boss.hp), "%dP boss HP bar max matches" % n)
		_check(game.enemies.is_empty(), "%dP boss clears regular enemies" % n)
	game.queue_free()
	if failures > 0:
		printerr("Party/boss regression: %d failure(s)" % failures)
		quit(1)
	else:
		print("Party/boss regression: all assertions passed")
		quit(0)

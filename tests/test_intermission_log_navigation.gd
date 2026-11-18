extends SceneTree
# Run from the project root:
# godot --headless --path . --script res://tests/test_intermission_log_navigation.gd
# This test exercises the production game.gd log state, without starting a battle.

const Game = preload("res://game.gd")
var failures: Array[String] = []

func _initialize() -> void:
	var game = Game.new()
	_check(not game.intermission_log_open, "log initially closed")
	game.toggle_intermission_log()
	_check(not game.intermission_log_open, "log cannot open outside intermission")
	game.mode = "intermission"
	game.intermission_line = 3
	game.toggle_intermission_log()
	_check(game.intermission_log_open, "log opens in intermission")
	_check(game.intermission_log_end == 3, "opening anchors to current read line")
	game.scroll_intermission_log(-2)
	_check(game.intermission_log_end == 1, "scroll back through read dialogue")
	game.scroll_intermission_log(-99)
	_check(game.intermission_log_end == 0, "scroll clamps at first line")
	game.scroll_intermission_log(99)
	_check(game.intermission_log_end == 3, "scroll never reveals unread dialogue")
	game.advance_intermission()
	_check(game.intermission_line == 3, "dialogue cannot advance while log open")
	game.toggle_intermission_log()
	_check(not game.intermission_log_open, "log closes")
	game.advance_intermission()
	_check(game.intermission_line == 4, "dialogue advances after closing log")
	game.toggle_intermission_log()
	_check(game.intermission_log_end == 4, "reopening anchors to latest read line")
	game.mode = "menu"
	game.scroll_intermission_log(-1)
	_check(game.intermission_log_end == 4, "scroll disabled outside intermission")
	game.free()
	if failures.is_empty():
		print("PASS: intermission log navigation")
		quit(0)
	else:
		for message in failures:
			push_error(message)
		quit(1)

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

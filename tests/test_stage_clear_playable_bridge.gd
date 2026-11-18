extends SceneTree
## Isolated smoke regression for stage bridge. Run with a disposable user-data directory.
## godot --headless --path . --script tests/test_stage_clear_playable_bridge.gd

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://stage_clear_playable_bridge.tscn") as PackedScene
	if scene == null:
		_fail("bridge scene could not load")
		return
	var bridge := scene.instantiate()
	root.add_child(bridge)
	await process_frame
	if bridge.phase != 0 or bridge.stage != 1:
		_fail("initial result state")
		return
	bridge._cycle_count()
	bridge._cycle_count()
	bridge._cycle_pilot()
	if bridge.player_count != 3 or bridge.pilot_index != 1:
		_fail("player count / pilot selection")
		return
	bridge._advance()
	if bridge.phase != 1 or bridge.lines.size() != 3:
		_fail("control room transition")
		return
	bridge._open_dialogue_log()
	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	bridge._unhandled_key_input(accept)
	if bridge.phase != 1 or bridge.line_index != 0:
		_fail("opening dialogue log must block underlying accept")
		return
	bridge.dialogue_log.hide()
	bridge._skip_dialogue()
	if bridge.phase != 2 or bridge.stage != 2 or bridge.player_count != 3:
		_fail("skip must preserve participants and advance stage")
		return
	bridge._advance()
	if bridge.phase != 0 or bridge.stage != 2:
		_fail("next result transition")
		return
	bridge.stage = 8
	bridge._advance()
	bridge._skip_dialogue()
	if not bridge.final_clear or bridge.phase != 2 or bridge.stage != 8:
		_fail("final stage completion")
		return
	bridge._advance()
	if bridge.stage != 8 or bridge.phase != 2:
		_fail("stage 8 must not overflow")
		return
	bridge._reset()
	if bridge.stage != 1 or bridge.player_count != 1 or bridge.pilot_index != 0 or bridge.final_clear:
		_fail("reset")
		return
	print("PASS: stage bridge result/dialogue/skip/3P/final/reset")
	bridge.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)

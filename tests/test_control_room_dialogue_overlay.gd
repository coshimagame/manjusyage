extends SceneTree
# Run: godot --headless --path . --script res://tests/test_control_room_dialogue_overlay.gd
const Overlay = preload("res://control_room_dialogue_overlay.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var overlay = Overlay.new()
	root.add_child(overlay)
	await process_frame
	var lines: Array[Dictionary] = [
		{"id": "stage1_01", "speaker": "コルミィ", "text": "確認"},
		{"id": "stage1_02", "speaker": "ムゥ", "text": "了解"}
	]
	overlay.set_lines(lines)
	assert(overlay.snapshot()["line_id"] == "stage1_01")
	assert(overlay.left_portrait.position.x < overlay.right_portrait.position.x)
	overlay.advance()
	assert(overlay.dialogue_label.visible_characters == -1)
	await process_frame
	assert(overlay.dialogue_label.visible_characters >= overlay.dialogue_label.get_total_character_count(), "Typewriter text must remain visible after fast-forward")
	overlay.advance()
	assert(overlay.snapshot()["line_id"] == "stage1_02")
	overlay.toggle_log()
	assert(overlay.log_open)
	overlay.advance()
	assert(overlay.snapshot()["line_index"] == 1, "Log must block advancement")
	overlay.toggle_log()
	overlay.advance()
	overlay.advance()
	assert(overlay.snapshot()["completed"])
	overlay.set_lines([])
	overlay.toggle_log()
	assert(overlay.log_open, "Empty dialogue log must not crash")
	print("PASS: dialogue portrait layout, typewriter fast-forward, log, completion and empty lines")
	quit(0)

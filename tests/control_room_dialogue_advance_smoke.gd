extends SceneTree
## Godot 4.6: godot --headless --path . --script res://tests/control_room_dialogue_advance_smoke.gd

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://prototypes/control_room_dialogue_demo.tscn")
	if scene == null:
		push_error("Control-room scene missing")
		quit(1)
		return
	var demo: Control = scene.instantiate()
	root.add_child(demo)
	await process_frame
	if demo.index != 0 or demo.get_dialogue_log().size() != 1:
		_fail("First dialogue line did not initialize")
		return
	demo.advance() # Reveal the entire first line
	if demo.index != 0 or demo.dialogue_label.visible_characters != -1:
		_fail("First press must reveal, not skip")
		return
	demo.advance() # Advance after full reveal (regression: -1 was treated as incomplete)
	if demo.index != 1 or demo.get_dialogue_log().size() != 2:
		_fail("Second press must advance to line two")
		return
	for i in range(1, demo.LINES.size()):
		demo.advance()
		demo.advance()
	if demo.index != demo.LINES.size() or not demo.next_button.disabled:
		_fail("Dialogue did not finish")
		return
	demo.queue_free()
	print("PASS: control-room reveal / advance / finish")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

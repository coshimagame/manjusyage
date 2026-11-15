extends SceneTree
## godot --headless --path . --script res://tests/intermission_input_smoke.gd
const Typewriter = preload("res://ui/intermission_typewriter.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui = Typewriter.new()
	root.add_child(ui)
	await process_frame
	var finished := [0]
	ui.dialogue_finished.connect(func(): finished[0] += 1)
	ui.start_dialogue([{"speaker":"クゥ","text":"準備完了。"},{"speaker":"ムゥ","text":"出撃。"}])
	var confirm := InputEventKey.new()
	confirm.keycode = KEY_ENTER
	confirm.pressed = true
	ui._unhandled_input(confirm)
	assert(ui._text_label.visible_characters == -1)
	ui._unhandled_input(confirm)
	assert(ui.get_resume_index() == 1)
	var start := InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	start.pressed = true
	ui._unhandled_input(start)
	assert(finished[0] == 1 and not ui.visible)
	ui._unhandled_input(start)
	assert(finished[0] == 1)
	ui.queue_free()
	print("PASS: intermission input smoke")
	quit(0)

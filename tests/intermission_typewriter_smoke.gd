extends SceneTree
## Godot 4.6: godot --headless --path . --script res://tests/intermission_typewriter_smoke.gd
## UIの字送り・全文表示・ログ・終了通知・スキップを実ノードで確認する。
const Typewriter = preload("res://ui/intermission_typewriter.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui = Typewriter.new()
	root.add_child(ui)
	await process_frame
	var finishes := [0]
	var changes: Array[int] = []
	ui.dialogue_finished.connect(func() -> void: finishes[0] += 1)
	ui.line_changed.connect(func(index: int, _speaker: String) -> void: changes.append(index))
	ui.start_dialogue([
		{"speaker": "クゥ", "text": "出撃準備。"},
		{"speaker": "ムゥ", "text": "整備完了。"}
	])
	_check(ui.visible and ui.get_resume_index() == 0, "first line started")
	_check(ui._text_label.visible_characters == 0, "typewriter starts hidden")
	ui.advance_or_reveal()
	_check(ui._text_label.visible_characters == -1, "reveal full line")
	ui.advance_or_reveal()
	_check(ui.get_resume_index() == 1, "advance to second line")
	_check(ui.get_dialogue_log().size() == 2, "dialogue log stores both lines")
	ui.advance_or_reveal()
	ui.advance_or_reveal()
	_check(not ui.visible and finishes[0] == 1, "finishes exactly once")
	_check(changes == [0, 1], "line_changed indices")
	ui.start_dialogue([{"speaker": "クゥ", "text": "再開。"}])
	_check(ui.get_dialogue_log().size() == 1, "new dialogue resets log")
	ui.skip_dialogue()
	_check(finishes[0] == 2 and not ui.visible, "skip emits finish")
	ui.skip_dialogue()
	_check(finishes[0] == 2, "repeated skip does not duplicate finish")
	ui.queue_free()
	print("PASS: intermission typewriter smoke")
	quit(0)

func _check(ok: bool, description: String) -> void:
	if not ok:
		push_error("FAIL: " + description)
		quit(1)

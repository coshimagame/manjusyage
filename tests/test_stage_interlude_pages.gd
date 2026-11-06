extends SceneTree
## Run: godot --headless --path . --script res://tests/test_stage_interlude_pages.gd
func _initialize() -> void:
	call_deferred("_check")

func _check() -> void:
	var scene := load("res://stage_interlude.tscn") as PackedScene
	if scene == null:
		push_error("Stage interlude scene missing")
		quit(1)
		return
	var view := scene.instantiate()
	root.add_child(view)
	await process_frame
	var original := view.LINES[0][1] as String
	var pages: Array[String] = view._dialogue_pages()
	if pages.is_empty() or "".join(pages).replace("\n", "") != original.replace("\n", ""):
		push_error("Dialogue pagination loses characters")
		quit(1)
		return
	if view._log_entry_count() != 0:
		push_error("Unfinished dialogue leaked into history")
		quit(1)
		return
	view.visible_chars = float(pages[0].length())
	if pages.size() == 1 and view._log_entry_count() != 1:
		push_error("Completed dialogue not added to history")
		quit(1)
		return
	view._advance()
	if view.line_index == 0 and pages.size() == 1:
		push_error("Dialogue advance stuck")
		quit(1)
		return
	print("PASS: stage interlude paging, transcript gating and progression")
	quit(0)

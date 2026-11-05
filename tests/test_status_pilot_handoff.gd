extends SceneTree
## Headless regression for status pilot selection -> main game handoff.
## Run: godot --headless --path . --script res://tests/test_status_pilot_handoff.gd
## No player save data is written by this test.
const PREVIEW := preload("res://ui/status_preview.tscn")
const META_KEY := "manjushage_selected_pilot"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui := PREVIEW.instantiate()
	root.add_child(ui)
	await process_frame
	if not ui.has_method("launch_game"):
		_fail("status preview lacks launch_game")
		return
	for pilot in range(3):
		ui.selected = pilot
		ui.launching = false
		ui.launch_game()
		if not has_meta(META_KEY):
			_fail("pilot metadata missing for index %d" % pilot)
			return
		if int(get_meta(META_KEY)) != pilot:
			_fail("pilot mismatch: expected %d" % pilot)
			return
		# The deferred scene transition has not run yet; reset the launch guard
		# to check all three indices synchronously before the next frame.
		ui.launching = false
	print("PASS status pilot handoff: selected=0,1,2 metadata matched")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL status pilot handoff: " + message)
	quit(1)

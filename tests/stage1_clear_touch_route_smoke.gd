extends SceneTree
## Static regression guard for stage-1 result touch/click route.
## godot --headless --path . --script res://tests/stage1_clear_touch_route_smoke.gd
func _initialize() -> void:
	var file := FileAccess.open("res://game.gd", FileAccess.READ)
	assert(file != null)
	var source := file.get_as_text()
	assert(source.contains('mode == "clear":\n\t\topen_stage1_intermission()'))
	assert(source.contains('mode=="intermission":\n\t\treturn'))
	print("stage1_clear_touch_route_smoke: PASS")
	quit(0)

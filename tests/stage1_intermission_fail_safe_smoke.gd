extends SceneTree
## Regression: missing dialogue resources must never silently skip the story.
## Run: godot --headless --path . --script res://tests/stage1_intermission_fail_safe_smoke.gd
func _initialize() -> void:
	var file := FileAccess.open("res://game.gd", FileAccess.READ)
	assert(file != null, "game.gd must be readable")
	var source := file.get_as_text()
	var begin := source.find("func open_stage1_intermission():")
	var end := source.find("func _on_stage1_intermission_end", begin)
	assert(begin >= 0 and end > begin, "intermission route missing")
	var route := source.substr(begin, end - begin)
	assert(route.count("INTERMISSION UNAVAILABLE - RETRY") == 2, "both failure cases must remain on clear result")
	assert(not route.contains("open_briefing("), "do not bypass story on missing assets")
	assert(source.contains("ENTER / A : INTERMISSION"), "result prompt must match actual route")
	print("stage1_intermission_fail_safe_smoke: PASS (static only)")
	quit(0)

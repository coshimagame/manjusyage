extends SceneTree
## Godot 4.6: godot --headless --path . --script res://tests/stage_intermission_integration_smoke.gd
const Intermission = preload("res://ui/stage_intermission_stage1.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var overlay = Intermission.new()
	root.add_child(overlay)
	await process_frame
	for players in [1, 2, 3]:
		assert(overlay.setup_after_stage(1, 1, players))
		assert(overlay.next_stage == 2)
		assert(overlay.lines.size() == 6)
		assert(overlay.lines[0].get("id") == "S1_POST_KUU_01")
	assert(overlay.setup_after_stage(1, 2, 1))
	assert(overlay.lines.size() == 7)
	assert(overlay.lines[-1].get("id") == "S1_POST_KUU_LOOP")
	var result := [-1]
	overlay.completed.connect(func(stage: int): result[0] = stage)
	for i in range(overlay.lines.size()):
		overlay.advance()
		overlay.advance()
	overlay.advance()
	assert(result[0] == 2)
	assert(overlay.done)
	assert(not overlay.setup_after_stage(2))
	print("stage_intermission_integration_smoke: PASS")
	quit(0)

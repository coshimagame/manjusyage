extends SceneTree
# Headless smoke: scene creation, typewriter advance, log, skip and completion.
const Intermission = preload("res://ui/stage_intermission.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = Intermission.new()
	root.add_child(scene)
	await process_frame
	var lines: Array[Dictionary] = [
		{"speaker": "クゥ", "text": "通信確認。"},
		{"speaker": "コルミィ", "text": "出撃準備、できたよ！"}
	]
	scene.configure(2, lines)
	assert(scene._pilot_portraits.size() == 3, "All three active pixel portraits must load for intermission dialogue")
	assert(scene.index == 0)
	scene.advance()
	assert(scene.index == 0) # First press reveals text.
	scene.advance()
	assert(scene.index == 1)
	await process_frame
	assert(scene._portrait.visible and scene._portrait.texture == scene._pilot_portraits["コルミィ"], "A pilot line must show its matching portrait")
	assert(scene.get_rect().size.x>=640 and scene.get_rect().size.y>=360)
	assert(not scene._portrait.get_rect().intersects(scene._dialogue.get_rect()))
	assert(scene._dialogue.text==lines[1].text and scene._dialogue.visible_characters<lines[1].text.length())
	scene.toggle_log()
	assert(scene.show_log and scene.history.size() == 1)
	scene.advance()
	assert(not scene.show_log)
	var result := [-1]
	scene.completed.connect(func(stage: int): result[0] = stage)
	scene.advance()
	scene.advance()
	scene.advance()
	assert(result[0] == 2)
	assert(scene.done)
	scene.configure(3, lines)
	var skip_result := [-1]
	scene.skipped.connect(func(stage: int): skip_result[0] = stage)
	scene._complete(true)
	assert(skip_result[0] == 3)
	print("stage_intermission_smoke: PASS")
	quit(0)

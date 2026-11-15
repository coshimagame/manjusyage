extends SceneTree
# Stage-1 intermission transition smoke: runs without gameplay assets or user saves.
const GameScript = preload("res://game.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game = GameScript.new()
	root.add_child(game)
	# The second callback must not navigate again after the first changes mode.
	game.mode = "intermission"
	var overlay = Control.new()
	game.add_child(overlay)
	game._on_stage1_intermission_end(99, overlay)
	assert(game.mode == "briefing", "Intermission must enter briefing exactly once")
	assert(game.briefing_stage == 2, "Stage-1 clear must not skip beyond stage 2")
	game._on_stage1_intermission_end(99, overlay)
	assert(game.briefing_stage == 2, "Repeated completion must not advance")
	print("PASS: stage1 intermission guarded transition")
	quit()

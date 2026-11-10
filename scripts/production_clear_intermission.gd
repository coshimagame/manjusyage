extends Node2D
## Production game clear -> intermission integration candidate.
## Runs the REAL main.tscn, not the enemy combat sandbox.
## Stage 2 is NOT unlocked here: existing game progression is preserved.
const GameScene = preload("res://main.tscn")
const IntermissionScene = preload("res://scenes/intermission_preview.tscn")
const Dialogue = preload("res://scripts/intermission_stage_dialogue.gd")
var game: Node2D
var overlay: Control
var clear_seen := false

func _ready() -> void:
	game = GameScene.instantiate()
	add_child(game)
	set_process(true)

func _process(_delta: float) -> void:
	if not is_instance_valid(game) or is_instance_valid(overlay):
		return
	if str(game.get("mode")) == "clear":
		if not clear_seen:
			clear_seen = true
			_show_clear_dialogue()
	else:
		clear_seen = false

func _show_clear_dialogue() -> void:
	# Disable input and simulation on the real game while the story owns the screen.
	game.process_mode = Node.PROCESS_MODE_DISABLED
	overlay = IntermissionScene.instantiate()
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.finished.connect(_finish_clear_dialogue, CONNECT_ONE_SHOT)
	# These are unapproved preview lines, not canon.
	overlay.begin(Dialogue.lines_for(1))

func _finish_clear_dialogue() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
		overlay = null
	# Do not pretend Stage 2 exists in the production game.
	# Keep the original clear/result mode and its own navigation intact.
	game.process_mode = Node.PROCESS_MODE_INHERIT

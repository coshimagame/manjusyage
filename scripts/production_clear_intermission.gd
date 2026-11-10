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
var prior_game_process_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT
var paused_audio: Array[AudioStreamPlayer] = []

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
	prior_game_process_mode = game.process_mode
	game.process_mode = Node.PROCESS_MODE_DISABLED
	# Disabling node processing does not stop AudioStreamPlayer playback.
	# Pause only the real game's active streams; leave the dialogue audio alone.
	paused_audio.clear()
	_pause_game_audio(game)
	overlay = IntermissionScene.instantiate()
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.finished.connect(_finish_clear_dialogue, CONNECT_ONE_SHOT)
	# These are unapproved preview lines, not canon.
	overlay.begin(Dialogue.lines_for(1))

# Audio players may live inside nested stage, HUD, or boss nodes.
# Never touch the sibling intermission overlay or streams paused beforehand.
func _pause_game_audio(root: Node) -> void:
	for child in root.get_children():
		if child is AudioStreamPlayer:
			if child.playing and not child.stream_paused:
				child.stream_paused = true
				paused_audio.append(child)
		_pause_game_audio(child)

func _exit_tree() -> void:
	# Ensure externally retained game/audio nodes cannot remain paused.
	_restore_game_audio()

func _restore_game_audio() -> void:
	# Restore only streams that this bridge paused and that still exist.
	for player in paused_audio:
		if is_instance_valid(player):
			player.stream_paused = false
	paused_audio.clear()

func _finish_clear_dialogue() -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
		overlay = null
	# Do not pretend Stage 2 exists in the production game.
	# Keep the original clear/result mode and its own navigation intact.
	_restore_game_audio()
	if is_instance_valid(game):
		game.process_mode = prior_game_process_mode

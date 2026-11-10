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
var paused_audio: Array[Node] = []
const Stage2Prototype = preload("res://scenes/stage2_combat_prototype.tscn")
var stage2_button: Button

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
# Include positional 2D/3D emitters, not only non-positional BGM players.
# Never touch the sibling intermission overlay or streams paused beforehand.
func _pause_game_audio(root: Node) -> void:
	for child in root.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D or child is AudioStreamPlayer3D:
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
	# Keep the production result screen; offer an explicit opt-in to the
	# standalone Stage 2 prototype, without changing save/progression data.
	_restore_game_audio()
	if is_instance_valid(game):
		game.process_mode = prior_game_process_mode
	_show_stage2_option()

# Prototype-only bridge. The player must opt in; no Stage 2 unlock or save is claimed.
func _show_stage2_option() -> void:
	if is_instance_valid(stage2_button):
		return
	stage2_button = Button.new()
	stage2_button.text = "第2面 試作へ出撃（未完成）"
	stage2_button.position = Vector2(360, 305)
	stage2_button.size = Vector2(260, 42)
	stage2_button.pressed.connect(_launch_stage2)
	add_child(stage2_button)

func _launch_stage2() -> void:
	# Transition deferred so the same click cannot hit Stage 2 controls.
	get_tree().change_scene_to_packed.call_deferred(Stage2Prototype)

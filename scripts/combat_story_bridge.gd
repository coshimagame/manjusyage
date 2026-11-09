extends Node2D
## Integration smoke test: combat sandbox -> dialogue -> next stage / retry.
## This is NOT the production game flow. Uses separate user:// sandbox save.
const CombatScene = preload("res://scenes/enemy_combat_sandbox.tscn")
const IntermissionScene = preload("res://scenes/intermission_preview.tscn")
const SAVE_PATH := "user://combat_story_preview.cfg"

var combat: Node2D
var overlay: Control
var awaiting_intermission := false
var stage_completed := false

func _ready() -> void:
	combat = CombatScene.instantiate()
	add_child(combat)
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		var saved_stage := clampi(int(cfg.get_value("progress", "stage", 1)), 1, 8)
		combat._set_stage(saved_stage)
	set_process(true)

func _process(_delta: float) -> void:
	if awaiting_intermission or not is_instance_valid(combat):
		return
	if combat.stage_clear and not stage_completed:
		stage_completed = true
		_show_intermission()
	elif not combat.stage_clear:
		stage_completed = false

func _show_intermission() -> void:
	awaiting_intermission = true
	# Freeze combat and its input while the dialogue overlay owns the screen.
	# Without this, N/R/shot can mutate the stage behind the intermission.
	combat.process_mode = Node.PROCESS_MODE_DISABLED
	overlay = IntermissionScene.instantiate()
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.finished.connect(_on_intermission_finished, CONNECT_ONE_SHOT)
	# Text is explicitly provisional; the final story must use approved dialogue IDs.
	overlay.begin([
		{"id":"bridge_s%02d_clear" % combat.stage, "speaker":"コルミィ", "text":"ここは越えたね。次の世界へ進もう！", "status":"proposal"},
		{"id":"bridge_s%02d_ready" % combat.stage, "speaker":"ムゥ", "text":"機体を整備する。出撃準備を頼む。", "status":"proposal"}
	])

func _on_intermission_finished() -> void:
	var next_stage := 1 if combat.stage >= 8 else combat.stage + 1
	# Store only preview progress. Never touch the real player's save.
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "stage", next_stage)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Combat story preview progress could not be saved: %s" % err)
	combat._set_stage(next_stage)
	if is_instance_valid(overlay):
		overlay.queue_free()
		overlay = null
	# Resume gameplay only after the overlay is dismissed and stage is reset.
	combat.process_mode = Node.PROCESS_MODE_INHERIT
	awaiting_intermission = false
	stage_completed = false

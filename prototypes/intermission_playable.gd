extends Control
## Standalone, provisional intermission screen. No canon dialogue is embedded.
## Instantiate res://prototypes/intermission_playable.tscn and call configure().
signal continue_requested(next_stage: int)
signal return_requested

@export var characters_per_second := 28.0
var next_stage := 2
var lines: Array[Dictionary] = []
var line_index := 0
var visible_chars := 0.0
var complete := false
var speaker_label: Label
var dialogue_label: Label
var hint_label: Label
var history: Array[String] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.025, 0.035, 0.09, 1.0)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.08
	panel.anchor_right = 0.92
	panel.anchor_top = 0.55
	panel.anchor_bottom = 0.93
	add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)
	speaker_label = Label.new()
	layout.add_child(speaker_label)
	dialogue_label = Label.new()
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(dialogue_label)
	hint_label = Label.new()
	hint_label.text = "Enter / Space / Tap: 次へ     Esc: スキップ"
	layout.add_child(hint_label)
	_show_line()

func configure(stage: int, dialogue: Array[Dictionary]) -> void:
	next_stage = max(1, stage)
	lines = dialogue.duplicate(true)
	line_index = 0
	visible_chars = 0.0
	complete = false
	history.clear()
	if is_node_ready():
		_show_line()

func _process(delta: float) -> void:
	if complete or lines.is_empty() or dialogue_label == null:
		return
	visible_chars += delta * maxf(1.0, characters_per_second)
	dialogue_label.visible_characters = mini(int(visible_chars), dialogue_label.get_total_character_count())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		continue_requested.emit(next_stage)
	elif event.is_action_pressed("ui_accept") or (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		_advance()

func _advance() -> void:
	if complete:
		continue_requested.emit(next_stage)
		return
	if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		visible_chars = float(dialogue_label.get_total_character_count())
		dialogue_label.visible_characters = -1
		return
	line_index += 1
	_show_line()

func _show_line() -> void:
	if speaker_label == null:
		return
	if line_index >= lines.size():
		complete = true
		speaker_label.text = "通信終了"
		dialogue_label.text = "次のステージへ進む"
		dialogue_label.visible_characters = -1
		hint_label.text = "Enter / Space / Tap: 続ける"
		return
	var entry: Dictionary = lines[line_index]
	var speaker := str(entry.get("speaker", "通信"))
	var dialogue := str(entry.get("text", ""))
	speaker_label.text = speaker
	dialogue_label.text = dialogue
	dialogue_label.visible_characters = 0
	visible_chars = 0.0
	history.append("%s: %s" % [speaker, dialogue])

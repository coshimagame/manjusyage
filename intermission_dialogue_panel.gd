extends Control
## Reusable non-canonical intermission subtitle panel. No story text is embedded.
## Instantiate res://intermission_dialogue_panel.tscn and call begin(lines).
signal finished
signal line_changed(index: int)

@export var characters_per_second: float = 28.0
var lines: Array[Dictionary] = []
var index := 0
var revealed := 0.0
var history: Array[String] = []
var active := false
var show_history := false
var speaker_label: Label
var subtitle_label: Label
var history_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -116.0
	panel.offset_bottom = -8.0
	panel.offset_left = 12.0
	panel.offset_right = -12.0
	add_child(panel)
	var layout := VBoxContainer.new()
	panel.add_child(layout)
	speaker_label = Label.new()
	layout.add_child(speaker_label)
	subtitle_label = Label.new()
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(subtitle_label)
	history_label = Label.new()
	history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	history_label.visible = false
	layout.add_child(history_label)
	visible = false
	set_process(true)
	set_process_unhandled_input(true)

func begin(dialogue: Array[Dictionary]) -> void:
	lines = dialogue.duplicate(true)
	history.clear()
	index = 0
	revealed = 0.0
	show_history = false
	active = not lines.is_empty()
	visible = active
	if active:
		_display_line()
	else:
		finished.emit()

func _display_line() -> void:
	var entry := lines[index]
	speaker_label.text = str(entry.get("speaker", ""))
	subtitle_label.text = str(entry.get("text", ""))
	subtitle_label.visible_characters = 0
	revealed = 0.0
	line_changed.emit(index)

func _process(delta: float) -> void:
	if not active or show_history:
		return
	var total := subtitle_label.get_total_character_count()
	if subtitle_label.visible_characters < total:
		revealed = minf(float(total), revealed + maxf(1.0, characters_per_second) * delta)
		subtitle_label.visible_characters = int(revealed)

func advance() -> void:
	if not active:
		return
	if show_history:
		toggle_history()
		return
	var total := subtitle_label.get_total_character_count()
	if subtitle_label.visible_characters < total:
		subtitle_label.visible_characters = -1
		revealed = float(total)
		return
	history.append(speaker_label.text + "： " + subtitle_label.text)
	index += 1
	if index >= lines.size():
		active = false
		visible = false
		finished.emit()
	else:
		_display_line()

func skip() -> void:
	if not active:
		return
	active = false
	visible = false
	finished.emit()

func toggle_history() -> void:
	if not active:
		return
	show_history = not show_history
	history_label.visible = show_history
	subtitle_label.visible = not show_history
	history_label.text = "\n".join(history)
	if show_history and history.is_empty():
		history_label.text = "（まだ会話履歴はありません）"

func _unhandled_input(event: InputEvent) -> void:
	if not active or not event.is_pressed():
		return
	if event.is_action("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()
	elif event.is_action("ui_cancel"):
		skip()
		get_viewport().set_input_as_handled()

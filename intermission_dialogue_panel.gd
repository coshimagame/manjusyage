extends Control
## Reusable non-canon dialogue panel for stage intermissions.
## No portrait is substituted: approved art can be connected later.
signal dialogue_finished
signal line_changed(speaker: String, line_id: String)

@export var characters_per_second := 32.0
@onready var speaker_label: Label = $Panel/VBox/Speaker
@onready var subtitle_label: Label = $Panel/VBox/Subtitle
@onready var hint_label: Label = $Panel/VBox/Hint
var entries: Array[Dictionary] = []
var index := 0
var visible_characters := 0.0
var active := false

func begin(lines: Array[Dictionary]) -> void:
	entries = lines.duplicate(true)
	index = 0
	active = not entries.is_empty()
	visible = active
	if active:
		_show_line()
	else:
		dialogue_finished.emit()

func _show_line() -> void:
	var line: Dictionary = entries[index]
	speaker_label.text = str(line.get("speaker", ""))
	subtitle_label.text = str(line.get("text", ""))
	subtitle_label.visible_characters = 0
	visible_characters = 0.0
	hint_label.text = "決定：全文表示／次へ    キャンセル：スキップ"
	line_changed.emit(speaker_label.text, str(line.get("id", "")))

func _process(delta: float) -> void:
	if not active:
		return
	visible_characters = minf(float(subtitle_label.get_total_character_count()), visible_characters + maxf(1.0, characters_per_second) * delta)
	subtitle_label.visible_characters = int(visible_characters)

func advance() -> void:
	if not active:
		return
	if subtitle_label.visible_characters < subtitle_label.get_total_character_count():
		visible_characters = float(subtitle_label.get_total_character_count())
		subtitle_label.visible_characters = -1
		return
	index += 1
	if index >= entries.size():
		finish()
	else:
		_show_line()

func finish() -> void:
	if not active:
		return
	active = false
	visible = false
	dialogue_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not active or not event.is_pressed():
		return
	if event is InputEventKey and not event.is_echo():
		if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			advance()
		elif event.keycode in [KEY_ESCAPE, KEY_X]:
			finish()
		else:
			return
	elif event is InputEventJoypadButton:
		if event.button_index == JOY_BUTTON_A:
			advance()
		elif event.button_index in [JOY_BUTTON_B, JOY_BUTTON_START]:
			finish()
		else:
			return
	else:
		return
	get_viewport().set_input_as_handled()

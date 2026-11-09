extends Control
## Standalone playable intermission overlay (proposal dialogue only).
## Run scenes/intermission_preview.tscn with F6; no game.gd changes.
signal finished

const SAMPLE_LINES = [
	{"id": "preview_s01_clear_01", "speaker": "コルミィ", "text": "やった！　でも、まだ先があるよね。", "status": "proposal"},
	{"id": "preview_s01_hangar_01", "speaker": "ムゥ", "text": "帰ってきたな。まず機体を見せてくれ。", "status": "proposal"},
	{"id": "preview_s01_radio_01", "speaker": "クゥ", "text": "……通信を確認。声は届いていますか。", "status": "proposal"},
	{"id": "preview_s01_next_01", "speaker": "ジヨーザ", "text": "進路を確認した。出撃準備に入る。", "status": "proposal"}
]
var lines: Array = []
var index := 0
var shown := 0.0
var show_log := false
var complete := false
var backdrop: ColorRect
var speaker_label: Label
var body_label: Label
var hint_label: Label
var log_label: RichTextLabel
var history: Array[String] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	begin(SAMPLE_LINES)

func _build_ui() -> void:
	backdrop = ColorRect.new()
	backdrop.color = Color(0.035, 0.055, 0.11, 1.0)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var frame := PanelContainer.new()
	frame.anchor_left = 0.06
	frame.anchor_right = 0.94
	frame.anchor_top = 0.60
	frame.anchor_bottom = 0.94
	frame.offset_left = 0
	frame.offset_right = 0
	frame.offset_top = 0
	frame.offset_bottom = 0
	add_child(frame)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 9)
	frame.add_child(stack)
	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 22)
	stack.add_child(speaker_label)
	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 20)
	body_label.custom_minimum_size.y = 48
	stack.add_child(body_label)
	hint_label = Label.new()
	hint_label.add_theme_font_size_override("font_size", 12)
	stack.add_child(hint_label)
	log_label = RichTextLabel.new()
	log_label.anchor_left = 0.06
	log_label.anchor_right = 0.94
	log_label.anchor_top = 0.08
	log_label.anchor_bottom = 0.56
	log_label.offset_left = 0
	log_label.offset_right = 0
	log_label.offset_top = 0
	log_label.offset_bottom = 0
	log_label.bbcode_enabled = false
	log_label.visible = false
	add_child(log_label)

func begin(new_lines: Array) -> void:
	lines.clear()
	for entry in new_lines:
		if entry is Dictionary and entry.has("speaker") and entry.has("text"):
			lines.append(entry.duplicate(true))
	index = 0
	shown = 0.0
	show_log = false
	complete = false
	history.clear()
	_render()

func _process(delta: float) -> void:
	if complete or show_log or lines.is_empty():
		return
	var length := String(lines[index].get("text", "")).length()
	shown = minf(float(length), shown + delta * 26.0)
	body_label.visible_characters = int(shown)
	if int(shown) >= length:
		hint_label.text = "ENTER/A 次へ   L 履歴   ESC スキップ"
	else:
		hint_label.text = "ENTER/A 全文表示   L 履歴   ESC スキップ"

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_L:
		_toggle_log()
	elif event.keycode == KEY_ESCAPE:
		_end()
	elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
		_advance()
	get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			_advance()
		elif event.button_index == JOY_BUTTON_START:
			_end()
		elif event.button_index == JOY_BUTTON_Y:
			_toggle_log()
		get_viewport().set_input_as_handled()

func _advance() -> void:
	if complete or show_log or lines.is_empty():
		return
	var current := lines[index]
	var full_text := String(current.get("text", ""))
	if int(shown) < full_text.length():
		shown = float(full_text.length())
		body_label.visible_characters = -1
		return
	history.append(String(current.get("speaker", "")) + "： " + full_text)
	index += 1
	shown = 0.0
	if index >= lines.size():
		_end()
	else:
		_render()

func _toggle_log() -> void:
	if complete:
		return
	show_log = not show_log
	log_label.visible = show_log
	if show_log:
		var display_lines := history.duplicate()
		if index < lines.size():
			display_lines.append(String(lines[index].get("speaker", "")) + "： " + String(lines[index].get("text", "")))
		log_label.text = "\n\n".join(display_lines)
	hint_label.text = "L 履歴を閉じる   ESC スキップ" if show_log else "ENTER/A 次へ   L 履歴   ESC スキップ"

func _render() -> void:
	if lines.is_empty():
		_end()
		return
	var current := lines[index]
	speaker_label.text = String(current.get("speaker", ""))
	body_label.text = String(current.get("text", ""))
	body_label.visible_characters = 0
	hint_label.text = "ENTER/A 全文表示   L 履歴   ESC スキップ"

func _end() -> void:
	if complete:
		return
	complete = true
	finished.emit()
	# Standalone preview loops back to the first line instead of closing the editor.
	if get_tree().current_scene == self:
		begin(SAMPLE_LINES)
	else:
		hide()

extends Control
## 独立起動できる幕間会話の実装試作。台詞は未承認の仮文。
## 左=主人公、右=ムゥ。正式PNGが未配置でも表示できる。
signal dialogue_finished

const LINES = [
	{"speaker": "クゥ", "line": "全機、帰還信号を確認。整備室へ接続します。", "side": "left"},
	{"speaker": "コルミィ", "line": "やった！ でも、あの敵……何かを守っていたみたい。", "side": "left"},
	{"speaker": "ムゥ", "line": "よく戻った。機体を見せてくれ。話はそれからだ。", "side": "right"},
	{"speaker": "ジヨーザ", "line": "観測値を保存しました。次の出撃前に解析します。", "side": "left"},
	{"speaker": "マフィオ", "line": "わたしも気になる。次はもっと近くで見てみたいな。", "side": "left"}
]
const TICK = 0.035
var line_index := 0
var revealed := 0.0
var finished := false
var speaker_label: Label
var dialogue_label: Label
var progress_label: Label
var left_label: Label
var right_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_refresh()

func _process(delta: float) -> void:
	if finished:
		return
	var full_text: String = LINES[line_index]["line"]
	if revealed < full_text.length():
		revealed = minf(float(full_text.length()), revealed + delta / TICK)
		dialogue_label.text = full_text.substr(0, int(revealed))

func _unhandled_input(event: InputEvent) -> void:
	# Controller A advances/reveals text; B skips. Joypad events must work
	# even when the mouse or keyboard is unavailable (Windows/Web).
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			_advance()
			get_viewport().set_input_as_handled()
		elif event.button_index == JOY_BUTTON_B:
			_finish()
			get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_finish()
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			_advance()
		get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()

func _advance() -> void:
	if finished:
		return
	var full_text: String = LINES[line_index]["line"]
	if revealed < full_text.length():
		revealed = float(full_text.length())
		dialogue_label.text = full_text
	elif line_index + 1 < LINES.size():
		line_index += 1
		_refresh()
	else:
		_finish()

func _finish() -> void:
	if finished:
		return
	finished = true
	dialogue_finished.emit()
	progress_label.text = "幕間終了  /  ESCでスキップ可能"
	# 独立起動時は終了画面を保持。ゲーム本体からはsignalで次面へ接続する。

func _refresh() -> void:
	revealed = 0.0
	speaker_label.text = str(LINES[line_index]["speaker"])
	dialogue_label.text = ""
	progress_label.text = "%d / %d    ENTER・A・クリック: 送る    ESC・B: スキップ" % [line_index + 1, LINES.size()]
	left_label.text = "%s\\n\\n[ PORTRAIT SLOT ]" % str(LINES[line_index]["speaker"]) if LINES[line_index]["side"] == "left" else "PILOT / KUU\\n\\n[ PORTRAIT SLOT ]"
	left_label.modulate = Color.WHITE if LINES[line_index]["side"] == "left" else Color("718093")
	right_label.modulate = Color.WHITE if LINES[line_index]["side"] == "right" else Color("718093")

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("101a30")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var title := _label("STAGE CLEAR  /  CONTROL ROOM", Vector2(28, 14), Vector2(590, 30), 20)
	title.modulate = Color("e7c5ad")
	var left_panel := _panel(Vector2(24, 54), Vector2(190, 164), Color("263d54"))
	var right_panel := _panel(Vector2(426, 54), Vector2(190, 164), Color("493747"))
	left_label = _label("PILOT / KUU\n\n[ PORTRAIT SLOT ]", Vector2(12, 22), Vector2(168, 130), 17, left_panel)
	right_label = _label("MUU\n\n[ PORTRAIT SLOT ]", Vector2(12, 22), Vector2(168, 130), 17, right_panel)
	var dialog_panel := _panel(Vector2(24, 232), Vector2(592, 104), Color("1c2a43"))
	speaker_label = _label("", Vector2(14, 7), Vector2(550, 24), 18, dialog_panel)
	speaker_label.modulate = Color("ffcf9e")
	dialogue_label = _label("", Vector2(14, 37), Vector2(560, 55), 17, dialog_panel)
	progress_label = _label("", Vector2(202, 201), Vector2(410, 26), 13)

func _panel(pos: Vector2, dimensions: Vector2, color: Color) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("c8b4a7")
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	return panel

func _label(value: String, pos: Vector2, dimensions: Vector2, font_size: int, parent: Control = null) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if parent == null:
		add_child(label)
	else:
		parent.add_child(label)
	return label

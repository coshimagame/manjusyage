extends Control
## Provisional, self-contained stage-clear intermission UI.
## Does not change canon dialogue, save data or existing game scenes.
signal continue_requested
signal replay_requested

@export var stage_number: int = 1
@export var next_stage_available: bool = false
var _lines: Array[String] = []
var _line_index := 0
var _char_count := 0.0
var _revealed := false
var _caption: Label
var _status: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_lines = [
		"クゥ：通信を確認。全機、帰投してください。",
		"整備室への帰還を開始します。"
	]
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.085, 0.96)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var panel := VBoxContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_constant_override("separation", 18)
	panel.offset_left = 48
	panel.offset_top = 52
	panel.offset_right = -48
	panel.offset_bottom = -35
	add_child(panel)
	var heading := Label.new()
	heading.text = "STAGE %02d  /  INTERMISSION" % stage_number
	panel.add_child(heading)
	_caption = Label.new()
	_caption.custom_minimum_size = Vector2(0, 100)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_caption)
	_status = Label.new()
	_status.text = "決定：次へ / Esc：スキップ"
	panel.add_child(_status)
	_show_line()

func _process(delta: float) -> void:
	if _revealed:
		return
	_char_count += delta * 28.0
	var full := _lines[_line_index]
	_caption.text = full.substr(0, mini(int(_char_count), full.length()))
	if _char_count >= full.length():
		_revealed = true

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		_finish()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_SPACE]:
		_advance()
		get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_advance()
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()

func _show_line() -> void:
	_char_count = 0.0
	_revealed = false
	_caption.text = ""

func _advance() -> void:
	if not _revealed:
		_caption.text = _lines[_line_index]
		_revealed = true
	elif _line_index + 1 < _lines.size():
		_line_index += 1
		_show_line()
	else:
		_finish()

func _finish() -> void:
	if next_stage_available:
		continue_requested.emit()
	else:
		_status.text = "次ステージは準備中です。決定で結果画面へ戻ります。"
		replay_requested.emit()

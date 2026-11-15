extends Control
## Reusable, optional stage intermission UI. Dialogue is provisional, never canon.
## Instantiate with load("res://ui/stage_intermission.gd").new(), add_child(), then configure().
signal completed(next_stage: int)
signal skipped(next_stage: int)

const W := 640.0
const H := 360.0
const CHARS_PER_SECOND := 28.0

var next_stage := 2
var lines: Array[Dictionary] = []
var index := 0
var reveal := 0.0
var history: Array[String] = []
var show_log := false
var done := false
var _title: Label
var _speaker: Label
var _dialogue: Label
var _hint: Label
var _log: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.065, 0.96)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_title = _make_label(Vector2(30, 20), Vector2(580, 42), 24)
	_speaker = _make_label(Vector2(34, 166), Vector2(570, 32), 21)
	_dialogue = _make_label(Vector2(34, 205), Vector2(570, 92), 19)
	_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint = _make_label(Vector2(34, 318), Vector2(570, 30), 14)
	_log = _make_label(Vector2(34, 70), Vector2(570, 220), 16)
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_log.visible = false
	_refresh()

func _make_label(pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e5f5ff"))
	add_child(label)
	return label

func configure(stage: int, dialogue_lines: Array[Dictionary]) -> void:
	next_stage = maxi(stage, 1)
	lines = dialogue_lines.duplicate(true)
	index = 0
	reveal = 0.0
	history.clear()
	show_log = false
	done = false
	if is_node_ready():
		_refresh()

func _process(delta: float) -> void:
	if done or show_log or lines.is_empty() or index >= lines.size():
		return
	var content := str(lines[index].get("text", ""))
	if reveal < content.length():
		reveal = minf(float(content.length()), reveal + delta * CHARS_PER_SECOND)
		_refresh()

func _refresh() -> void:
	if not is_node_ready() or _title == null:
		return
	_title.text = "STAGE CLEAR  /  次の境界へ"
	_hint.text = "決定/タップ: 続ける   L: 会話ログ   Esc/Start: スキップ"
	_log.visible = show_log
	_speaker.visible = not show_log
	_dialogue.visible = not show_log
	if show_log:
		_log.text = "\n".join(history.slice(maxi(0, history.size() - 7)))
		return
	if index < lines.size():
		var current := lines[index]
		var content := str(current.get("text", ""))
		_speaker.text = str(current.get("speaker", "通信"))
		_dialogue.text = content.substr(0, int(reveal))
	else:
		_speaker.text = "通信終了"
		_dialogue.text = "次のステージへ出撃します。"

func advance() -> void:
	if done:
		return
	if show_log:
		show_log = false
		_refresh()
		return
	if index >= lines.size():
		_complete(false)
		return
	var content := str(lines[index].get("text", ""))
	if reveal < content.length():
		reveal = float(content.length())
	else:
		history.append(str(lines[index].get("speaker", "通信")) + "： " + content)
		index += 1
		reveal = 0.0
	_refresh()

func toggle_log() -> void:
	if done:
		return
	show_log = not show_log
	_refresh()

func _complete(was_skipped: bool) -> void:
	if done:
		return
	done = true
	if was_skipped:
		skipped.emit(next_stage)
	else:
		completed.emit(next_stage)

func _unhandled_input(event: InputEvent) -> void:
	if done:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_complete(true)
		elif event.keycode == KEY_L:
			toggle_log()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			advance()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START:
			_complete(true)
		elif event.button_index == JOY_BUTTON_A:
			advance()
	elif event is InputEventScreenTouch and event.pressed:
		advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()
		get_viewport().set_input_as_handled()

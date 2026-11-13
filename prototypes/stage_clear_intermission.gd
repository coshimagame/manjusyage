extends Control
## Reusable, canon-neutral stage-clear intermission. Does not change saves or scenes.
signal continue_requested(next_stage: int)
signal return_requested
@export_range(1, 8) var next_stage: int = 2
@export var lines: PackedStringArray = PackedStringArray(["クゥ：通信を確認しました。", "ムゥ：機体の点検を始めよう。"])
@export var characters_per_second: float = 28.0
var line_index := 0
var revealed := 0.0
var history: Array[String] = []
var finished := false
var subtitle: Label
var heading: Label
var hint: Label
var log_panel: RichTextLabel
var log_visible := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#091322")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var panel := VBoxContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_constant_override("separation", 16)
	panel.offset_left = 36
	panel.offset_right = -36
	panel.offset_top = 36
	panel.offset_bottom = -28
	add_child(panel)
	heading = Label.new()
	heading.text = "STAGE CLEAR  /  INTERMISSION"
	panel.add_child(heading)
	var space := Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(space)
	subtitle = Label.new()
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size.y = 90
	panel.add_child(subtitle)
	hint = Label.new()
	hint.text = "Enter / Space / Tap: next   L: log   Esc: skip"
	panel.add_child(hint)
	log_panel = RichTextLabel.new()
	log_panel.custom_minimum_size.y = 100
	log_panel.visible = false
	panel.add_child(log_panel)
	_show_line()

func _process(delta: float) -> void:
	if finished or lines.is_empty() or log_visible:
		return
	revealed = minf(float(lines[line_index].length()), revealed + delta * characters_per_second)
	subtitle.text = lines[line_index].substr(0, int(revealed))

func _show_line() -> void:
	revealed = 0.0
	if lines.is_empty():
		finished = true
		subtitle.text = "通信記録はありません。"
	else:
		subtitle.text = ""

func _advance() -> void:
	if log_visible:
		_toggle_log()
		return
	if finished:
		continue_requested.emit(next_stage)
		return
	var full := lines[line_index]
	if revealed < full.length():
		revealed = float(full.length())
		subtitle.text = full
		return
	history.append(full)
	line_index += 1
	if line_index >= lines.size():
		finished = true
		subtitle.text = "通信終了。次のステージへ。"
		hint.text = "Enter / Space / Tap: continue   L: log   Esc: return"
	else:
		_show_line()

func _toggle_log() -> void:
	log_visible = not log_visible
	log_panel.visible = log_visible
	var entries := history.duplicate()
	if not finished and not lines.is_empty():
		entries.append(lines[line_index])
	log_panel.text = "\n".join(entries)
	hint.text = "L / Enter: close log" if log_visible else "Enter / Space / Tap: next   L: log   Esc: skip"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			_toggle_log()
		elif event.keycode == KEY_ESCAPE:
			if log_visible:
				_toggle_log()
			else:
				return_requested.emit()
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			_advance()
	elif event is InputEventScreenTouch and event.pressed:
		_advance()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			_advance()
		elif event.button_index == JOY_BUTTON_B:
			return_requested.emit()

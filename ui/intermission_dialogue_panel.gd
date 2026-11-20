extends Control
## Reusable intermission dialogue panel. Proposed lines are supplied by the caller.
## No canon portraits are embedded; art/active assets remain untouched.
signal dialogue_finished
signal dialogue_advanced(index: int)

@export var letters_per_second: float = 26.0
@export var left_portrait: Texture2D
@export var right_mu_portrait: Texture2D

var entries: Array[Dictionary] = []
var index := 0
var visible_letters := 0.0
var history: Array[String] = []
var history_open := false
var complete := false
var font: Font

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	font = SystemFont.new()
	(font as SystemFont).font_names = PackedStringArray(["Noto Sans CJK JP", "Yu Gothic", "Meiryo"])
	set_process(false)

func begin_dialogue(lines: Array[Dictionary]) -> void:
	entries = lines.duplicate(true)
	index = 0
	visible_letters = 0.0
	history.clear()
	history_open = false
	complete = entries.is_empty()
	visible = not complete
	set_process(not complete)
	queue_redraw()
	if complete:
		dialogue_finished.emit()

func _process(delta: float) -> void:
	if complete or history_open:
		return
	visible_letters += maxf(0.0, letters_per_second) * delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if complete or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			history_open = not history_open
			queue_redraw()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			advance()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			skip_dialogue()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			advance()
			get_viewport().set_input_as_handled()
		elif event.button_index == JOY_BUTTON_START:
			skip_dialogue()
			get_viewport().set_input_as_handled()

func advance() -> void:
	if complete:
		return
	if history_open:
		history_open = false
		queue_redraw()
		return
	var line := str(entries[index].get("text", ""))
	if int(visible_letters) < line.length():
		visible_letters = float(line.length())
		queue_redraw()
		return
	history.append(str(entries[index].get("speaker", "")) + "： " + line)
	index += 1
	if index >= entries.size():
		skip_dialogue()
		return
	visible_letters = 0.0
	dialogue_advanced.emit(index)
	queue_redraw()

func skip_dialogue() -> void:
	if complete:
		return
	complete = true
	visible = false
	set_process(false)
	dialogue_finished.emit()

func _draw() -> void:
	if complete or entries.is_empty() or font == null:
		return
	var w := size.x
	var h := size.y
	if w < 320.0 or h < 160.0:
		return
	draw_rect(Rect2(0, h - 125, w, 125), Color(0.025, 0.045, 0.085, 0.95))
	draw_line(Vector2(12, h - 125), Vector2(w - 12, h - 125), Color(0.55, 0.72, 0.78), 2)
	var portrait_size := Vector2(82, 88)
	var left_box := Rect2(14, h - 116, portrait_size.x, portrait_size.y)
	var right_box := Rect2(w - 96, h - 116, portrait_size.x, portrait_size.y)
	draw_rect(left_box, Color(0.11, 0.19, 0.26))
	draw_rect(right_box, Color(0.19, 0.13, 0.17))
	if left_portrait != null:
		draw_texture_rect(left_portrait, left_box, false)
	if right_mu_portrait != null:
		draw_texture_rect(right_mu_portrait, right_box, false)
	draw_string(font, Vector2(w - 87, h - 16), "ムゥ", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	if history_open:
		draw_string(font, Vector2(112, h - 94), "会話ログ / Lで戻る", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.AQUA)
		var start := maxi(0, history.size() - 3)
		for i in range(start, history.size()):
			draw_string(font, Vector2(112, h - 72 + (i - start) * 22), history[i], HORIZONTAL_ALIGNMENT_LEFT, int(w - 225), 12, Color.WHITE)
		return
	var entry: Dictionary = entries[index]
	var speaker := str(entry.get("speaker", ""))
	var line := str(entry.get("text", ""))
	draw_string(font, Vector2(112, h - 95), speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.75, 0.57))
	draw_string(font, Vector2(112, h - 62), line.substr(0, int(visible_letters)), HORIZONTAL_ALIGNMENT_LEFT, int(w - 225), 14, Color.WHITE)
	draw_string(font, Vector2(112, h - 17), "Enter/A 次へ  L ログ  Esc/Start スキップ", HORIZONTAL_ALIGNMENT_LEFT, int(w - 225), 10, Color(0.64, 0.76, 0.84))

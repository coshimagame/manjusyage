extends Control
## Reusable stage-clear communication overlay (prototype, not canon dialogue).
## Instantiate with StageCommsPanel.new(), add as child, then call begin(lines).
## Does not change the current stage, save data, or existing portrait assets.
signal dialogue_finished

@export var letters_per_second: float = 32.0
@export var left_portrait_path: String = ""
@export var mu_portrait_path: String = ""

var lines: Array[Dictionary] = []
var line_index := 0
var revealed := 0.0
var running := false
var history: Array[Dictionary] = []
var left_portrait: Texture2D
var right_portrait: Texture2D

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_process(false)
	set_process_unhandled_input(false)

func begin(new_lines: Array[Dictionary]) -> void:
	lines = new_lines.duplicate(true)
	history.clear()
	line_index = 0
	revealed = 0.0
	running = not lines.is_empty()
	left_portrait = _load_portrait(left_portrait_path)
	right_portrait = _load_portrait(mu_portrait_path)
	visible = running
	set_process(running)
	set_process_unhandled_input(running)
	queue_redraw()
	if not running:
		dialogue_finished.emit()

func _load_portrait(path: String) -> Texture2D:
	if not path.begins_with("res://"):
		return null
	var img := Image.load_from_file(path)
	if img == null or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
	if not running:
		return
	revealed = minf(float(str(lines[line_index].get("text", "")).length()), revealed + delta * letters_per_second)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not running:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			finish()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_ENTER, KEY_SPACE]:
			advance()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed and event.button_index in [JOY_BUTTON_A, JOY_BUTTON_START]:
		advance()
		get_viewport().set_input_as_handled()

func advance() -> void:
	if not running:
		return
	var current := str(lines[line_index].get("text", ""))
	if revealed < current.length():
		revealed = float(current.length())
	else:
		history.append(lines[line_index].duplicate(true))
		line_index += 1
		revealed = 0.0
		if line_index >= lines.size():
			finish()
	queue_redraw()

func finish() -> void:
	if not running:
		return
	running = false
	visible = false
	set_process(false)
	set_process_unhandled_input(false)
	dialogue_finished.emit()

func get_dialogue_log() -> Array[Dictionary]:
	return history.duplicate(true)

func _draw() -> void:
	if not running:
		return
	var size_px := get_rect().size
	var sx := size_px.x / 640.0
	var sy := size_px.y / 360.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
	draw_rect(Rect2(0, 0, 640, 360), Color(0.015, 0.025, 0.06, 0.88))
	_draw_portrait(Rect2(28, 48, 156, 172), left_portrait, Color(0.20, 0.64, 0.77))
	_draw_portrait(Rect2(456, 48, 156, 172), right_portrait, Color(0.86, 0.29, 0.38))
	draw_rect(Rect2(25, 239, 590, 101), Color(0.045, 0.07, 0.14))
	draw_rect(Rect2(25, 239, 590, 101), Color(0.63, 0.77, 0.88), false, 2.0)
	var current := lines[line_index]
	var font := ThemeDB.fallback_font
	var speaker := str(current.get("speaker", ""))
	var message := str(current.get("text", "")).substr(0, int(revealed))
	draw_string(font, Vector2(42, 265), speaker, HORIZONTAL_ALIGNMENT_LEFT, 555, 18, Color(0.95, 0.72, 0.72))
	draw_multiline_string(font, Vector2(42, 292), message, HORIZONTAL_ALIGNMENT_LEFT, 555, 17, -1, Color(0.93, 0.96, 1.0))
	draw_string(font, Vector2(450, 331), "ENTER / TAP  •  ESC SKIP", HORIZONTAL_ALIGNMENT_LEFT, 160, 10, Color(0.63, 0.76, 0.84))
	draw_set_transform(Vector2.ZERO)

func _draw_portrait(rect: Rect2, portrait: Texture2D, tint: Color) -> void:
	draw_rect(rect, Color(0.07, 0.10, 0.18))
	if portrait != null:
		draw_texture_rect(portrait, rect, false)
	else:
		# Empty portrait slot is intentional; never fabricate an approved face.
		draw_line(rect.position + Vector2(10, 10), rect.end - Vector2(10, 10), tint.darkened(0.55), 1)
	draw_rect(rect, tint, false, 2)

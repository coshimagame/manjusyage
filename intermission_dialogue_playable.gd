extends Control
## Standalone playable intermission dialogue. Provisional lines, not official canon.
## Call begin(lines, portrait_paths) from the stage-clear controller.
signal finished

const PILOTS = ["コルミィ", "ジヨーザ", "マフィオ"]
var lines: Array[Dictionary] = []
var index := 0
var visible_chars := 0.0
var characters_per_second := 28.0
var running := false
var left_image: TextureRect
var right_image: TextureRect
var speaker_label: Label
var dialogue_label: Label
var progress_label: Label
var left_label: Label
var right_label: Label
var portrait_paths: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	if lines.is_empty():
		begin([
			{"speaker":"ムゥ", "text":"通信確認。機体の状態を調べる。"},
			{"speaker":"コルミィ", "text":"了解！ 次の出撃に備えるね。"}
		])

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.018, 0.025, 0.075, 0.96)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	left_image = _portrait(Vector2(22, 36))
	right_image = _portrait(Vector2(490, 36))
	left_label = _label(Vector2(22, 164), Vector2(130, 24))
	right_label = _label(Vector2(490, 164), Vector2(130, 24))
	right_label.text = "ムゥ"
	var panel := ColorRect.new()
	panel.color = Color(0.08, 0.10, 0.18, 0.96)
	panel.position = Vector2(16, 206)
	panel.size = Vector2(608, 136)
	add_child(panel)
	speaker_label = _label(Vector2(30, 216), Vector2(580, 24))
	dialogue_label = _label(Vector2(30, 245), Vector2(576, 68))
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	progress_label = _label(Vector2(30, 316), Vector2(580, 22))
	progress_label.text = "Enter / Space: 次へ   Esc: スキップ"

func _portrait(pos: Vector2) -> TextureRect:
	var frame := ColorRect.new()
	frame.position = pos
	frame.size = Vector2(128, 120)
	frame.color = Color(0.15, 0.20, 0.30)
	add_child(frame)
	var image := TextureRect.new()
	image.position = pos + Vector2(4, 4)
	image.size = Vector2(120, 112)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(image)
	return image

func _label(pos: Vector2, dimensions: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = dimensions
	label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	add_child(label)
	return label

func begin(new_lines: Array, paths: Dictionary = {}) -> void:
	lines.clear()
	for entry in new_lines:
		if entry is Dictionary and entry.has("speaker") and entry.has("text"):
			lines.append(entry.duplicate())
	portrait_paths = paths.duplicate()
	index = 0
	visible_chars = 0.0
	running = not lines.is_empty()
	visible = running
	if running:
		_show_line()
	else:
		finished.emit()

func _load_portrait(name: String) -> Texture2D:
	var path := str(portrait_paths.get(name, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource
	return null

func _show_line() -> void:
	var line := lines[index]
	var speaker := str(line["speaker"])
	speaker_label.text = speaker
	dialogue_label.text = str(line["text"])
	dialogue_label.visible_characters = 0
	visible_chars = 0.0
	var pilot := speaker if speaker in PILOTS else "コルミィ"
	left_label.text = pilot
	left_image.texture = _load_portrait(pilot)
	right_image.texture = _load_portrait("ムゥ")
	left_image.modulate.a = 1.0 if speaker != "ムゥ" else 0.5
	right_image.modulate.a = 1.0 if speaker == "ムゥ" else 0.5
	progress_label.text = "%d / %d  |  Enter / Space: 次へ   Esc: スキップ" % [index + 1, lines.size()]

func _process(delta: float) -> void:
	if not running:
		return
	visible_chars = minf(float(dialogue_label.get_total_character_count()), visible_chars + delta * characters_per_second)
	dialogue_label.visible_characters = int(visible_chars)

func _unhandled_key_input(event: InputEvent) -> void:
	if not running or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		_complete()
	elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
		if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
			dialogue_label.visible_characters = -1
			visible_chars = float(dialogue_label.get_total_character_count())
		else:
			index += 1
			if index >= lines.size():
				_complete()
			else:
				_show_line()
	get_viewport().set_input_as_handled()

func _complete() -> void:
	running = false
	visible = false
	finished.emit()

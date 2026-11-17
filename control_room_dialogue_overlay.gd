extends Control
## Reusable stage-clear communications overlay. No canon dialogue or portrait art is bundled.
signal dialogue_finished
signal line_changed(line_id: String)

@export var characters_left: Texture2D
@export var muu_right: Texture2D
@export var characters_name: String = "コルミィ"
@export var characters_lines: Array[Dictionary] = []
@export var characters_per_second: float = 34.0

var index := 0
var visible_characters := 0.0
var log_open := false
var completed := false
var speaker_label: Label
var dialogue_label: Label
var log_label: RichTextLabel
var left_portrait: TextureRect
var right_portrait: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.065, 0.92)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	left_portrait = _portrait(Vector2(16, 38), characters_left)
	right_portrait = _portrait(Vector2(480, 38), muu_right)
	speaker_label = Label.new()
	speaker_label.position = Vector2(24, 218)
	speaker_label.add_theme_font_size_override("font_size", 17)
	add_child(speaker_label)
	dialogue_label = Label.new()
	dialogue_label.position = Vector2(24, 244)
	dialogue_label.custom_minimum_size = Vector2(590, 76)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(dialogue_label)
	log_label = RichTextLabel.new()
	log_label.position = Vector2(24, 40)
	log_label.size = Vector2(592, 168)
	log_label.visible = false
	add_child(log_label)
	if characters_lines.is_empty():
		characters_lines = [{"id": "placeholder_01", "speaker": "クゥ", "text": "通信を確認。次の航路へ進めます。"}]
	_show_line()

func _portrait(pos: Vector2, art: Texture2D) -> TextureRect:
	var p := TextureRect.new()
	p.position = pos
	p.size = Vector2(144, 166)
	p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	p.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p.texture = art
	add_child(p)
	return p

func set_lines(lines: Array[Dictionary], start_index: int = 0) -> void:
	characters_lines = lines.duplicate(true)
	index = clampi(start_index, 0, maxi(0, characters_lines.size() - 1))
	completed = false
	visible_characters = 0.0
	if is_node_ready():
		_show_line()

func _show_line() -> void:
	if characters_lines.is_empty():
		completed = true
		dialogue_finished.emit()
		return
	var entry: Dictionary = characters_lines[index]
	speaker_label.text = str(entry.get("speaker", ""))
	dialogue_label.text = str(entry.get("text", ""))
	dialogue_label.visible_characters = 0
	visible_characters = 0.0
	var speaker := speaker_label.text
	left_portrait.modulate.a = 1.0 if speaker != "ムゥ" else 0.5
	right_portrait.modulate.a = 1.0 if speaker == "ムゥ" else 0.5
	line_changed.emit(str(entry.get("id", "")))

func _process(delta: float) -> void:
	if completed or log_open:
		return
	visible_characters += delta * characters_per_second
	dialogue_label.visible_characters = mini(int(visible_characters), dialogue_label.get_total_character_count())

func advance() -> void:
	if completed or log_open:
		return
	if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		dialogue_label.visible_characters = -1
		return
	if index + 1 < characters_lines.size():
		index += 1
		_show_line()
	else:
		completed = true
		dialogue_finished.emit()

func toggle_log() -> void:
	log_open = not log_open
	log_label.visible = log_open
	if log_open:
		log_label.clear()
		for i in range(index + 1):
			var line: Dictionary = characters_lines[i]
			log_label.add_text(str(line.get("speaker", "")) + ": " + str(line.get("text", "")) + "\n")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			toggle_log()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_D]:
			advance()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_A:
		advance()
		get_viewport().set_input_as_handled()

func snapshot() -> Dictionary:
	return {"line_index": index, "line_id": str(characters_lines[index].get("id", "")) if not characters_lines.is_empty() else "", "completed": completed}

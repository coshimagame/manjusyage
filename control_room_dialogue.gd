extends Control
## Reusable stage intermission dialogue view. No canon dialogue or artwork is embedded.
## Left: current speaker's portrait; right: Mu's portrait (approved layout).
signal dialogue_finished
signal line_advanced(index: int)

var lines: Array[Dictionary] = []
var line_index := 0
var reveal_count := 0.0
var characters_per_second := 36.0
var left_portrait: TextureRect
var right_portrait: TextureRect
var speaker_label: Label
var dialogue_label: Label
var log_lines: Array[String] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	set_process(false)

func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var root := VBoxContainer.new()
	panel.add_child(root)
	var portraits := HBoxContainer.new()
	portraits.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(portraits)
	left_portrait = _portrait()
	portraits.add_child(left_portrait)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portraits.add_child(gap)
	right_portrait = _portrait()
	portraits.add_child(right_portrait)
	speaker_label = Label.new()
	root.add_child(speaker_label)
	dialogue_label = Label.new()
	dialogue_label.custom_minimum_size = Vector2(0, 90)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(dialogue_label)

func _portrait() -> TextureRect:
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(116, 170)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return portrait

## Each line: {speaker, text, left_texture, mu_texture, mu_speaking}.
## Texture fields are optional; missing approved artwork remains blank.
func start_dialogue(new_lines: Array[Dictionary]) -> void:
	lines = new_lines.duplicate(true)
	log_lines.clear()
	line_index = 0
	if lines.is_empty():
		dialogue_finished.emit()
		hide()
		return
	show()
	_show_line()
	set_process(true)

func _show_line() -> void:
	var entry: Dictionary = lines[line_index]
	var speaker := str(entry.get("speaker", ""))
	var body := str(entry.get("text", ""))
	speaker_label.text = speaker
	dialogue_label.text = body
	dialogue_label.visible_characters = 0
	reveal_count = 0.0
	left_portrait.texture = entry.get("left_texture", null) as Texture2D
	right_portrait.texture = entry.get("mu_texture", null) as Texture2D
	var mu_speaking := bool(entry.get("mu_speaking", false))
	left_portrait.modulate.a = 0.55 if mu_speaking else 1.0
	right_portrait.modulate.a = 1.0 if mu_speaking else 0.55
	log_lines.append("%s: %s" % [speaker, body])
	line_advanced.emit(line_index)

func _process(delta: float) -> void:
	if line_index >= lines.size():
		return
	reveal_count += delta * characters_per_second
	dialogue_label.visible_characters = mini(int(reveal_count), dialogue_label.get_total_character_count())

func advance() -> void:
	if lines.is_empty():
		return
	if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		dialogue_label.visible_characters = -1
		reveal_count = float(dialogue_label.get_total_character_count())
		return
	line_index += 1
	if line_index >= lines.size():
		set_process(false)
		hide()
		dialogue_finished.emit()
	else:
		_show_line()

func skip() -> void:
	set_process(false)
	hide()
	dialogue_finished.emit()

func get_dialogue_log() -> Array[String]:
	return log_lines.duplicate()

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.pressed or event.is_echo():
		return
	if event.is_action_pressed("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		skip()
		get_viewport().set_input_as_handled()

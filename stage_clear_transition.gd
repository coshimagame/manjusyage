extends Control
## Stage-clear transition for the 640x360 viewport.
## No canon dialogue or approved portraits are embedded in this component.
signal continue_requested
signal retry_requested
signal title_requested

@export var left_portrait: Texture2D
@export var muu_portrait: Texture2D
@export var stage_label: String = "STAGE 1 CLEAR"
@export var speaker: String = "管制"
@export_multiline var message: String = "通信を確認。次の出撃に備えてください。"
@export var characters_per_second: float = 28.0

var _visible_characters := 0.0
var _finished := false
var _message_label: Label
var _next_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color(0.015, 0.025, 0.07, 0.96)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var heading := Label.new()
	heading.text = stage_label
	heading.position = Vector2(16, 10)
	heading.add_theme_color_override("font_color", Color("f0b4b4"))
	add_child(heading)
	_add_portrait(left_portrait, Vector2(20, 46))
	_add_portrait(muu_portrait, Vector2(492, 46))
	var panel := PanelContainer.new()
	panel.position = Vector2(14, 208)
	panel.size = Vector2(612, 140)
	add_child(panel)
	var layout := VBoxContainer.new()
	panel.add_child(layout)
	var name_label := Label.new()
	name_label.text = speaker
	layout.add_child(name_label)
	_message_label = Label.new()
	_message_label.text = message
	_message_label.visible_characters = 0
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.custom_minimum_size = Vector2(575, 49)
	layout.add_child(_message_label)
	var actions := HBoxContainer.new()
	layout.add_child(actions)
	_next_button = _add_action(actions, "次へ", _on_next)
	_add_action(actions, "再出撃", _on_retry)
	_add_action(actions, "タイトル", _on_title)
	_next_button.grab_focus()

func _add_portrait(texture: Texture2D, at: Vector2) -> void:
	var frame := Panel.new()
	frame.position = at
	frame.size = Vector2(128, 144)
	add_child(frame)
	if texture == null:
		return # Missing approved portrait stays empty; never fabricate one.
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_child(image)

func _add_action(parent: Node, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(125, 28)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _process(delta: float) -> void:
	if _finished:
		return
	_visible_characters += delta * maxf(1.0, characters_per_second)
	_message_label.visible_characters = int(_visible_characters)
	if _message_label.visible_characters >= message.length():
		_finished = true

func _on_next() -> void:
	if not _finished:
		_finished = true
		_message_label.visible_characters = -1
		return
	continue_requested.emit()

func _on_retry() -> void:
	retry_requested.emit()

func _on_title() -> void:
	title_requested.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_finished = true
		_message_label.visible_characters = -1
		get_viewport().set_input_as_handled()

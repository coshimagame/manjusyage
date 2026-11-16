extends Control
## Standalone 640x360 stage-comms preview; no approved portraits are modified.
## This is a reusable prototype, not yet connected to game.gd.
signal dialogue_finished

@export var left_portrait_path: String = ""
@export var muu_portrait_path: String = ""
@export var lines: Array[String] = [
    "クゥ：通信状態を確認中。",
    "ムゥ：機体の整備を始める。"
]
var line_index := 0
var visible_chars := 0.0
var complete := false
var speaker_label: Label
var dialogue_label: Label
var left_texture: TextureRect
var right_texture: TextureRect

func _ready() -> void:
    custom_minimum_size = Vector2(640, 360)
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shade := ColorRect.new()
    shade.color = Color(0.015, 0.025, 0.06, 0.94)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    left_texture = _portrait(Vector2(22, 34), "相手 / 仮枠")
    right_texture = _portrait(Vector2(506, 34), "ムゥ / 仮枠")
    _load_portrait(left_texture, left_portrait_path)
    _load_portrait(right_texture, muu_portrait_path)
    var panel := ColorRect.new()
    panel.position = Vector2(24, 236)
    panel.size = Vector2(592, 108)
    panel.color = Color(0.045, 0.065, 0.12, 0.98)
    add_child(panel)
    speaker_label = Label.new()
    speaker_label.position = Vector2(40, 244)
    speaker_label.add_theme_color_override("font_color", Color(1, 0.75, 0.53))
    add_child(speaker_label)
    dialogue_label = Label.new()
    dialogue_label.position = Vector2(40, 270)
    dialogue_label.size = Vector2(555, 57)
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(dialogue_label)
    _show_line()

func _portrait(at: Vector2, placeholder: String) -> TextureRect:
    var frame := Panel.new()
    frame.position = at
    frame.size = Vector2(112, 170)
    add_child(frame)
    var tex := TextureRect.new()
    tex.position = at + Vector2(4, 4)
    tex.size = Vector2(104, 162)
    tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    add_child(tex)
    var fallback := Label.new()
    fallback.position = at + Vector2(8, 75)
    fallback.text = placeholder
    fallback.add_theme_font_size_override("font_size", 11)
    add_child(fallback)
    fallback.set_meta("portrait_for", tex)
    tex.set_meta("fallback", fallback)
    return tex

func _load_portrait(tex: TextureRect, path: String) -> void:
    if path.is_empty() or not FileAccess.file_exists(path):
        return
    var img := Image.load_from_file(path)
    if img == null or img.is_empty():
        return
    tex.texture = ImageTexture.create_from_image(img)
    (tex.get_meta("fallback") as Label).hide()

func _show_line() -> void:
    if line_index >= lines.size():
        dialogue_finished.emit()
        queue_free()
        return
    var parts := lines[line_index].split("：", false, 1)
    speaker_label.text = parts[0] if parts.size() > 1 else "通信"
    dialogue_label.text = parts[1] if parts.size() > 1 else lines[line_index]
    visible_chars = 0.0
    complete = false
    dialogue_label.visible_characters = 0

func _process(delta: float) -> void:
    if complete:
        return
    visible_chars += delta * 34.0
    dialogue_label.visible_characters = int(visible_chars)
    if visible_chars >= dialogue_label.get_total_character_count():
        complete = true
        dialogue_label.visible_characters = -1

func _unhandled_key_input(event: InputEvent) -> void:
    if event.pressed and not event.echo and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
        _advance()
        get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _advance()
        accept_event()
    elif event is InputEventScreenTouch and event.pressed:
        _advance()
        accept_event()

func _advance() -> void:
    if not complete:
        complete = true
        dialogue_label.visible_characters = -1
    else:
        line_index += 1
        _show_line()

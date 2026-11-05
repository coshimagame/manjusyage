extends CanvasLayer
## MANJUSHAGE: non-blocking radio dialogue prototype (Godot 4.6).
## Add this script to a CanvasLayer node in a stage scene, then call play_lines().
## Does not pause gameplay. No existing art or audio is replaced.
signal dialogue_finished
var _queue: Array[Dictionary] = []
var _current: Dictionary = {}
var _remaining := 0.0
var _panel: PanelContainer
var _speaker: Label
var _body: Label
var _portrait: TextureRect

func _ready() -> void:
    layer = 20
    _panel = PanelContainer.new()
    _panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    _panel.offset_top = -88
    _panel.offset_bottom = -8
    _panel.offset_left = 12
    _panel.offset_right = -12
    _panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var layout := HBoxContainer.new()
    layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _panel.add_child(layout)
    _portrait = TextureRect.new()
    _portrait.custom_minimum_size = Vector2(64, 64)
    _portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layout.add_child(_portrait)
    var column := VBoxContainer.new()
    column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    column.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layout.add_child(column)
    _speaker = Label.new()
    column.add_child(_speaker)
    _body = Label.new()
    _body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(_body)
    add_child(_panel)
    _panel.hide()
    set_process(false)

func play_lines(lines: Array[Dictionary]) -> void:
    for line in lines:
        _queue.append(line.duplicate(true))
    if _current.is_empty():
        _next_line()

func _next_line() -> void:
    if _queue.is_empty():
        _current = {}
        _panel.hide()
        set_process(false)
        dialogue_finished.emit()
        return
    _current = _queue.pop_front()
    _speaker.text = str(_current.get("speaker", ""))
    _body.text = str(_current.get("text", ""))
    _remaining = maxf(0.5, float(_current.get("duration", 3.5)))
    var portrait_path := str(_current.get("portrait", ""))
    _portrait.texture = load(portrait_path) as Texture2D if portrait_path.begins_with("res://") and ResourceLoader.exists(portrait_path) else null
    _portrait.visible = _portrait.texture != null
    _panel.show()
    set_process(true)

func _process(delta: float) -> void:
    _remaining -= delta
    if _remaining <= 0.0:
        _next_line()

func clear_dialogue() -> void:
    _queue.clear()
    _current = {}
    _panel.hide()
    set_process(false)

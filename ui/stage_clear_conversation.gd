extends Control
## Reusable stage-clear conversation screen. Provisional lines; not approved canon.
signal finished

@export var character_portrait: Texture2D
@export var muu_portrait: Texture2D
@export var letters_per_second := 34.0

var lines: Array[Dictionary] = [
    {"speaker": "コルミィ", "text": "やった！ ……でも、あの敵は何を守っていたの？"},
    {"speaker": "ムゥ", "text": "まだ分からん。帰ってきたら、機体の傷を見せてくれ。"},
    {"speaker": "クゥ", "text": "みんな、無事でよかった。次の航路を確認するね。"}
]
var line_index := 0
var visible_letters := 0.0
var history: Array[String] = []
var speaker_label: Label
var message_label: Label
var history_label: Label
var left_portrait: TextureRect
var right_portrait: TextureRect
var showing_history := false

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var background := ColorRect.new()
    background.color = Color(0.018, 0.025, 0.075, 0.96)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    left_portrait = _portrait(Vector2(22, 50), character_portrait)
    right_portrait = _portrait(Vector2(502, 50), muu_portrait)
    var panel := Panel.new()
    panel.position = Vector2(18, 222)
    panel.size = Vector2(604, 119)
    add_child(panel)
    speaker_label = _label(Vector2(34, 230), Vector2(560, 26), 18)
    message_label = _label(Vector2(34, 260), Vector2(560, 67), 17)
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    history_label = _label(Vector2(34, 50), Vector2(570, 160), 15)
    history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    history_label.visible = false
    _show_line()

func _portrait(at: Vector2, texture: Texture2D) -> TextureRect:
    var portrait := TextureRect.new()
    portrait.position = at
    portrait.size = Vector2(116, 158)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait.texture = texture
    add_child(portrait)
    return portrait

func _label(at: Vector2, dimensions: Vector2, font_size: int) -> Label:
    var label := Label.new()
    label.position = at
    label.size = dimensions
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
    add_child(label)
    return label

func _process(delta: float) -> void:
    if showing_history or line_index >= lines.size():
        return
    var full_text := str(lines[line_index].get("text", ""))
    visible_letters = minf(float(full_text.length()), visible_letters + letters_per_second * delta)
    message_label.text = full_text.substr(0, int(visible_letters))

func _unhandled_key_input(event: InputEvent) -> void:
    if not event.is_pressed() or event.is_echo():
        return
    if event.is_action_pressed("ui_cancel"):
        if showing_history:
            showing_history = false
            history_label.visible = false
        else:
            finished.emit()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("ui_up"):
        showing_history = not showing_history
        history_label.visible = showing_history
        history_label.text = "\n".join(history.slice(maxi(0, history.size() - 5)))
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("ui_accept"):
        if showing_history:
            showing_history = false
            history_label.visible = false
        else:
            _advance()
        get_viewport().set_input_as_handled()

func _advance() -> void:
    var full_text := str(lines[line_index].get("text", ""))
    if int(visible_letters) < full_text.length():
        visible_letters = float(full_text.length())
        message_label.text = full_text
        return
    history.append(str(lines[line_index].get("speaker", "")) + "： " + full_text)
    line_index += 1
    if line_index >= lines.size():
        finished.emit()
    else:
        _show_line()

func _show_line() -> void:
    visible_letters = 0.0
    speaker_label.text = str(lines[line_index].get("speaker", ""))
    message_label.text = ""

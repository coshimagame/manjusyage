extends Control
## Reusable, non-canon interlude UI. Launch res://interlude_preview.tscn to inspect.
## Caller may set lines and next_scene before adding the scene to the tree.
signal completed
@export_file("*.tscn") var next_scene: String = ""
@export var characters_per_second := 28.0
var lines: Array[Dictionary] = [
    {"speaker": "クゥ", "text": "通信を確認。みんな、無事ね。"},
    {"speaker": "ムゥ", "text": "機体を点検する。少し待っていてくれ。"},
    {"speaker": "コルミィ", "text": "うん！ 次も行けるよ！"}
]
var line_index := 0
var visible_characters_float := 0.0
var log_visible := false
var finished := false
var speaker_label: Label
var dialogue_label: Label
var log_label: RichTextLabel
var prompt_label: Label
var touch_controls: HBoxContainer

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var backdrop := Control.new()
    backdrop.set_script(load("res://interlude_workshop_visual.gd"))
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var panel := PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    panel.offset_top = -155
    panel.offset_bottom = -10
    panel.offset_left = 18
    panel.offset_right = -18
    add_child(panel)
    var column := VBoxContainer.new()
    panel.add_child(column)
    speaker_label = Label.new()
    column.add_child(speaker_label)
    dialogue_label = Label.new()
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_label.custom_minimum_size.y = 72
    column.add_child(dialogue_label)
    prompt_label = Label.new()
    prompt_label.text = "Enter / A / タップ: 次へ   L: ログ   Esc: スキップ"
    column.add_child(prompt_label)
    log_label = RichTextLabel.new()
    log_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    log_label.offset_left = 28
    log_label.offset_top = 20
    log_label.offset_right = -28
    log_label.offset_bottom = -175
    log_label.visible = false
    log_label.scroll_active = true
    add_child(log_label)
    touch_controls = HBoxContainer.new()
    touch_controls.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    touch_controls.offset_left = -226
    touch_controls.offset_top = 8
    touch_controls.offset_right = -8
    touch_controls.offset_bottom = 42
    add_child(touch_controls)
    for label in ["ログ", "次へ", "スキップ"]:
        var button := Button.new()
        button.text = label
        button.custom_minimum_size = Vector2(70, 34)
        touch_controls.add_child(button)
        if label == "ログ":
            button.pressed.connect(_toggle_log)
        elif label == "次へ":
            button.pressed.connect(_advance)
        else:
            button.pressed.connect(_finish)
    _show_line()

func _process(delta: float) -> void:
    if lines.is_empty() or log_visible:
        return
    var target := dialogue_label.get_total_character_count()
    if dialogue_label.visible_characters < target:
        visible_characters_float += delta * characters_per_second
        dialogue_label.visible_characters = mini(target, int(visible_characters_float))

func _show_line() -> void:
    if line_index >= lines.size():
        _finish()
        return
    speaker_label.text = str(lines[line_index].get("speaker", ""))
    dialogue_label.text = str(lines[line_index].get("text", ""))
    dialogue_label.visible_characters = 0
    visible_characters_float = 0.0
    _refresh_log()

func _advance() -> void:
    if finished:
        return
    if log_visible:
        log_visible = false
        log_label.hide()
        return
    if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
        dialogue_label.visible_characters = -1
        visible_characters_float = float(dialogue_label.get_total_character_count())
        return
    line_index += 1
    _show_line()

func _refresh_log() -> void:
    log_label.clear()
    for i in range(mini(line_index + 1, lines.size())):
        log_label.add_text(str(lines[i].get("speaker", "")) + "： " + str(lines[i].get("text", "")) + "\n")

func _toggle_log() -> void:
    if finished:
        return
    log_visible = not log_visible
    log_label.visible = log_visible

func _finish() -> void:
    if finished:
        return
    finished = true
    set_process(false)
    set_process_unhandled_input(false)
    completed.emit()
    if not next_scene.is_empty() and ResourceLoader.exists(next_scene):
        get_tree().change_scene_to_file.call_deferred(next_scene)
    else:
        queue_free()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            _finish()
        elif event.keycode == KEY_L:
            _toggle_log()
        elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
            _advance()
    elif event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_START:
            _finish()
        elif event.button_index == JOY_BUTTON_A:
            _advance()

# Touch and mouse input are handled by explicit buttons, avoiding double advance.

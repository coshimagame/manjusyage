extends Control
## Standalone, replaceable intermission prototype. Dialogue is provisional, not canon.
signal finished(next_stage: int)

@export_range(1, 8) var cleared_stage: int = 1
@export var run_index: int = 1
@export var auto_advance_to_game: bool = false
@export_file("*.tscn") var game_scene: String = "res://game.tscn"

const LINES := [
    {"speaker": "クゥ", "text": "通信を確認。みんな、無事でよかった。"},
    {"speaker": "ムゥ", "text": "機体を見せてくれ。次に備えて整備しよう。"},
    {"speaker": "コルミィ", "text": "よーし！ 次も飛ぶよ！"},
    {"speaker": "ジヨーザ", "text": "先に機体の状態を確認しよう。"},
    {"speaker": "マフィオ", "text": "おなかすいた！ でも、まだ行けるよ！"}
]
var index := 0
var visible_characters := 0.0
var reveal_rate := 34.0
var log_open := false
var speaker_label: Label
var body_label: Label
var help_label: Label
var log_panel: RichTextLabel
var history: Array[String] = []

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.025, 0.035, 0.085)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var box := PanelContainer.new()
    box.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    box.offset_top = -152
    box.offset_bottom = -12
    box.offset_left = 18
    box.offset_right = -18
    add_child(box)
    var column := VBoxContainer.new()
    box.add_child(column)
    speaker_label = Label.new()
    column.add_child(speaker_label)
    body_label = Label.new()
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body_label.custom_minimum_size.y = 64
    column.add_child(body_label)
    help_label = Label.new()
    help_label.text = "Enter/Space: 次へ    L: ログ    Esc: スキップ"
    column.add_child(help_label)
    log_panel = RichTextLabel.new()
    log_panel.visible = false
    log_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    log_panel.offset_left = 32
    log_panel.offset_right = -32
    log_panel.offset_top = 22
    log_panel.offset_bottom = -170
    log_panel.scroll_active = true
    add_child(log_panel)
    _show_line()

func _process(delta: float) -> void:
    if log_open:
        return
    visible_characters = minf(float(LINES[index]["text"].length()), visible_characters + reveal_rate * delta)
    body_label.visible_characters = int(visible_characters)

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_L:
        log_open = not log_open
        log_panel.visible = log_open
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_ESCAPE:
        _finish()
        get_viewport().set_input_as_handled()
    elif event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
        if log_open:
            log_open = false
            log_panel.visible = false
        elif visible_characters < float(LINES[index]["text"].length()):
            visible_characters = float(LINES[index]["text"].length())
            body_label.visible_characters = -1
        elif index + 1 < LINES.size():
            index += 1
            _show_line()
        else:
            _finish()
        get_viewport().set_input_as_handled()

func _show_line() -> void:
    var entry: Dictionary = LINES[index]
    speaker_label.text = str(entry["speaker"]) + "  /  第" + str(cleared_stage) + "面クリア後（仮台詞）"
    body_label.text = str(entry["text"])
    body_label.visible_characters = 0
    visible_characters = 0.0
    history.append(str(entry["speaker"]) + "： " + str(entry["text"]))
    log_panel.text = "\n".join(history)

func _finish() -> void:
    finished.emit(mini(cleared_stage + 1, 8))
    if auto_advance_to_game and ResourceLoader.exists(game_scene):
        get_tree().change_scene_to_file(game_scene)

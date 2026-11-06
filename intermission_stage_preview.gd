extends Control
## Stage-clear intermission prototype. All dialogue is provisional.
## Launch this scene directly; it does not modify game.gd or save files.
signal completed(next_stage: int)
@export_range(1, 8) var cleared_stage := 1
@export_range(1, 4) var worldline := 1
@export_range(1, 3) var player_count := 1
var index := 0
var reveal := 0.0
var history: Array[String] = []
var showing_log := false
var finished := false
var lines: Array[Dictionary] = []
var panel: PanelContainer
var caption: Label
var hint: Label
var heading: Label
var timer := 0.0

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    lines = _make_lines()
    var bg := ColorRect.new()
    bg.color = Color("#101827")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    panel = PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    panel.offset_top = -160
    add_child(panel)
    var box := VBoxContainer.new()
    panel.add_child(box)
    heading = Label.new()
    heading.text = "STAGE %02d CLEAR / WORLDLINE %d" % [cleared_stage, worldline]
    box.add_child(heading)
    caption = Label.new()
    caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    caption.custom_minimum_size.y = 76
    box.add_child(caption)
    hint = Label.new()
    hint.text = "Enter/A: 進む  L/Y: ログ  Esc/Start: スキップ"
    box.add_child(hint)
    _refresh()

func _make_lines() -> Array[Dictionary]:
    # No unapproved appearance, relationship, or worldline memory is asserted.
    var result: Array[Dictionary] = []
    result.append({"id":"INTERMISSION_%02d_01" % cleared_stage, "speaker":"クゥ", "text":"通信を確認。全機、応答してください。"})
    result.append({"id":"INTERMISSION_%02d_02" % cleared_stage, "speaker":"ムゥ", "text":"帰還後に機体を点検する。無理はするな。"})
    if worldline > 1:
        result.append({"id":"INTERMISSION_%02d_03" % cleared_stage, "speaker":"ジヨーザ", "text":"前と同じとは限らない。記録を照合しよう。"})
    else:
        result.append({"id":"INTERMISSION_%02d_03" % cleared_stage, "speaker":"コルミィ", "text":"よーし、次も行こう！"})
    result.append({"id":"INTERMISSION_%02d_04" % cleared_stage, "speaker":"マフィオ", "text":"次の敵はどんな力を持ってるかな？"})
    return result

func _process(delta: float) -> void:
    if finished or showing_log:
        return
    timer += delta
    reveal = minf(float(_current_text().length()), reveal + delta * 28.0)
    _refresh()

func _current_text() -> String:
    if index >= lines.size():
        return ""
    return str(lines[index]["text"])

func _refresh() -> void:
    if showing_log:
        caption.text = "\n".join(history)
    elif index < lines.size():
        caption.text = "%s：%s" % [lines[index]["speaker"], _current_text().substr(0, int(reveal))]

func _advance() -> void:
    if showing_log:
        showing_log = false
        _refresh()
        return
    if reveal < _current_text().length():
        reveal = float(_current_text().length())
        _refresh()
        return
    history.append("%s：%s" % [lines[index]["speaker"], lines[index]["text"]])
    index += 1
    reveal = 0.0
    if index >= lines.size():
        _finish()
    else:
        _refresh()

func _finish() -> void:
    if finished:
        return
    finished = true
    completed.emit(mini(cleared_stage + 1, 8))
    # Standalone preview returns to title; real stage routing is a later integration.
    get_tree().change_scene_to_file.call_deferred("res://main.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
            _advance()
        elif event.keycode == KEY_L:
            showing_log = not showing_log
            _refresh()
        elif event.keycode == KEY_ESCAPE:
            _finish()
    elif event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_A:
            _advance()
        elif event.button_index == JOY_BUTTON_Y:
            showing_log = not showing_log
            _refresh()
        elif event.button_index == JOY_BUTTON_START:
            _finish()

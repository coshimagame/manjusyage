extends Control
## Reusable stage-clear conversation overlay. Provisional dialogue only.
## Instantiate above the game scene; connect completed and return to gameplay.
signal completed(next_stage: int)
signal replay_requested
signal campaign_completed

const PILOTS := ["コルミィ", "ジヨーザ", "マフィオ"]
const PORTRAITS := [
    "res://art/active/kolmy_portrait.png",
    "res://art/active/jyoza_portrait.png",
    "res://art/active/mafio_portrait.png"
]
const MU_PORTRAIT := "res://art/active/mu_portrait.png"
var stage := 1
var pilot := 0
var party_size := 1
var line_index := 0
var dialogue: Array[Dictionary] = []
var history: Array[String] = []
var log_open := false
var finished := false
var label: Label
var left_portrait: TextureRect
var right_portrait: TextureRect
var log_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.018, 0.025, 0.07, 0.97)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    left_portrait = _portrait(Vector2(22, 36))
    right_portrait = _portrait(Vector2(474, 36))
    var panel := ColorRect.new()
    panel.position = Vector2(18, 206)
    panel.size = Vector2(604, 137)
    panel.color = Color(0.08, 0.1, 0.17, 0.96)
    add_child(panel)
    label = Label.new()
    label.position = Vector2(35, 220)
    label.size = Vector2(570, 90)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(label)
    log_label = Label.new()
    log_label.position = Vector2(35, 40)
    log_label.size = Vector2(570, 165)
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    log_label.visible = false
    add_child(log_label)
    configure(stage, pilot, party_size)

func _portrait(at: Vector2) -> TextureRect:
    var slot := TextureRect.new()
    slot.position = at
    slot.size = Vector2(144, 150)
    slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    add_child(slot)
    return slot

func _load_optional(path: String) -> Texture2D:
    if not FileAccess.file_exists(path):
        return null
    var img := Image.load_from_file(path)
    if img == null or img.is_empty():
        return null
    return ImageTexture.create_from_image(img)

func configure(cleared_stage: int, active_pilot: int, participants: int) -> void:
    stage = clampi(cleared_stage, 1, 8)
    pilot = clampi(active_pilot, 0, 2)
    party_size = clampi(participants, 1, 3)
    line_index = 0
    finished = false
    log_open = false
    history.clear()
    # Placeholder text is intentionally not entered into canon or save data.
    dialogue = [
        {"speaker": "ムゥ", "text": "機体を確認する。全員、無事か？"},
        {"speaker": PILOTS[pilot], "text": "こちらは大丈夫。次の出撃に備えるよ。"},
        {"speaker": "クゥ", "text": "通信確認。次の座標を準備します。"}
    ]
    if label != null:
        left_portrait.texture = _load_optional(PORTRAITS[pilot])
        right_portrait.texture = _load_optional(MU_PORTRAIT)
        _show_line()

func _show_line() -> void:
    if line_index >= dialogue.size():
        if finished:
            return
        finished = true
        hide()
        if stage >= 8:
            campaign_completed.emit()
        else:
            completed.emit(stage + 1)
        return
    var entry: Dictionary = dialogue[line_index]
    label.text = "%s  /  第%d面クリア  /  %d人参加\n\n%s\n\n[Enter] 次へ   [L] ログ   [S] スキップ" % [
        entry["speaker"], stage, party_size, entry["text"]]
    if history.size() <= line_index:
        history.append("%s: %s" % [entry["speaker"], entry["text"]])

func _unhandled_key_input(event: InputEvent) -> void:
    if finished or not visible or not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_L:
        log_open = not log_open
        log_label.visible = log_open
        log_label.text = "\n".join(history)
        get_viewport().set_input_as_handled()
        return
    if log_open:
        if event.keycode in [KEY_ENTER, KEY_ESCAPE]:
            log_open = false
            log_label.visible = false
            get_viewport().set_input_as_handled()
        return
    if event.keycode == KEY_S:
        line_index = dialogue.size()
        _show_line()
        get_viewport().set_input_as_handled()
    elif event.keycode in [KEY_ENTER, KEY_SPACE]:
        line_index += 1
        _show_line()
        get_viewport().set_input_as_handled()

## Return a validated checkpoint for the parent game's existing save system.
## No disk writes here: avoid changing the established save format.
func snapshot() -> Dictionary:
    return {
        "version": 1,
        "stage": stage,
        "pilot": pilot,
        "party_size": party_size,
        "line_index": line_index,
        "finished": finished
    }


## Restore without emitting stage transition signals during loading.
func restore_snapshot(data: Dictionary) -> bool:
    if data.get("version", -1) != 1:
        return false
    for key in ["stage", "pilot", "party_size", "line_index"]:
        if typeof(data.get(key)) != TYPE_INT:
            return false
    if typeof(data.get("finished")) != TYPE_BOOL:
        return false
    var saved_stage: int = data["stage"]
    var saved_pilot: int = data["pilot"]
    var saved_party: int = data["party_size"]
    var saved_line: int = data["line_index"]
    var saved_finished: bool = data["finished"]
    if saved_stage < 1 or saved_stage > 8 or saved_pilot < 0 or saved_pilot > 2:
        return false
    if saved_party < 1 or saved_party > 3 or saved_line < 0 or saved_line > 3:
        return false
    # An unfinished checkpoint at the end would emit a transition on load.
    # Only a completed checkpoint may point past the last dialogue line.
    if saved_finished != (saved_line == 3):
        return false
    configure(saved_stage, saved_pilot, saved_party)
    line_index = saved_line
    finished = saved_finished
    history.clear()
    for i in range(mini(line_index + (0 if finished else 1), dialogue.size())):
        var entry: Dictionary = dialogue[i]
        history.append("%s: %s" % [entry["speaker"], entry["text"]])
    if finished:
        hide()
    else:
        show()
        _show_line()
    return true

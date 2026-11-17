extends Control
## Reusable stage-clear conversation overlay. Provisional dialogue only.
## Instantiate above the game scene; connect completed and return to gameplay.
signal completed(next_stage: int)
signal replay_requested

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
        completed.emit(mini(stage + 1, 8))
        hide()
        return
    var entry: Dictionary = dialogue[line_index]
    label.text = "%s  /  第%d面クリア  /  %d人参加\n\n%s\n\n[Enter] 次へ   [L] ログ   [S] スキップ" % [
        entry["speaker"], stage, party_size, entry["text"]]
    if history.size() <= line_index:
        history.append("%s: %s" % [entry["speaker"], entry["text"]])

func _unhandled_key_input(event: InputEvent) -> void:
    if not visible or not (event is InputEventKey) or not event.pressed or event.echo:
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

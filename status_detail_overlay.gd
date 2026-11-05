extends CanvasLayer
## Optional pause-status overlay. Add this node under the active game scene.
## Call open_status(snapshot) from the existing pause/start input handler.
## No input is intercepted while hidden. Art paths are replaceable.
signal close_requested

const PORTRAITS := [
    "res://art/active/portrait_cormii.png",
    "res://art/active/portrait_jiyoza.png",
    "res://art/active/portrait_mafio.png"
]
const NAMES := ["コルミィ", "ジヨーザ", "マフィオ"]
const ACCENTS := [Color("#67ecff"), Color("#ff668e"), Color("#ffce63")]
var _root: Control
var _cards: Array[VBoxContainer] = []

func _ready() -> void:
    layer = 30
    _root = Control.new()
    _root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _root.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(_root)
    var shade := ColorRect.new()
    shade.color = Color(0.015, 0.025, 0.06, 0.93)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _root.add_child(shade)
    var layout := VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 8)
    _root.add_child(layout)
    var heading := Label.new()
    heading.text = "MANJUSHAGE   /   STATUS"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 22)
    layout.add_child(heading)
    var row := HBoxContainer.new()
    row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    row.add_theme_constant_override("separation", 6)
    layout.add_child(row)
    for i in range(3):
        var panel := PanelContainer.new()
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(panel)
        var card := VBoxContainer.new()
        card.add_theme_constant_override("separation", 3)
        panel.add_child(card)
        _cards.append(card)
        var portrait := TextureRect.new()
        portrait.custom_minimum_size = Vector2(0, 72)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        if ResourceLoader.exists(PORTRAITS[i]):
            portrait.texture = load(PORTRAITS[i]) as Texture2D
        card.add_child(portrait)
        _add_line(card, NAMES[i], ACCENTS[i], 18)
        for key in ["HP", "SHIELD", "WEAPON", "BOMB", "運気", "解析", "固有能力"]:
            _add_line(card, key + "  --", Color("#d5e7ff"), 13)
    var close_button := Button.new()
    close_button.text = "戻る / BACK"
    close_button.pressed.connect(request_close)
    layout.add_child(close_button)
    visible = false

func _add_line(parent: VBoxContainer, value: String, color: Color, font_size: int) -> void:
    var label := Label.new()
    label.text = value
    label.modulate = color
    label.add_theme_font_size_override("font_size", font_size)
    label.clip_text = true
    parent.add_child(label)

func open_status(snapshots: Array = []) -> void:
    for i in range(_cards.size()):
        var data: Dictionary = snapshots[i] if i < snapshots.size() and snapshots[i] is Dictionary else {}
        var card := _cards[i]
        var keys := ["HP", "SHIELD", "WEAPON", "BOMB", "運気", "解析", "固有能力"]
        for j in range(keys.size()):
            var label := card.get_child(j + 2) as Label
            var key: String = keys[j]
            label.text = key + "  " + str(data.get(key, "—"))
    visible = true

func request_close() -> void:
    visible = false
    close_requested.emit()

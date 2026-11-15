extends Control
## 管制会話の左右顔配置。正式PNGを変更せず外部からTexture2Dを渡す。
## 会話進行・セーブは呼び出し元が管理する。Godot 4.6 実行未検証。
signal advance_requested

var left_portrait: TextureRect
var mu_portrait: TextureRect
var left_name: Label
var mu_name: Label
var speaker_label: Label
var dialogue_label: RichTextLabel
var _speaker: String = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()

func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.055, 0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	left_portrait = _portrait(Vector2(12, 26))
	mu_portrait = _portrait(Vector2(500, 26))
	left_name = _label(Vector2(12, 164), Vector2(128, 24), "相手")
	mu_name = _label(Vector2(500, 164), Vector2(128, 24), "ムゥ")
	speaker_label = _label(Vector2(154, 201), Vector2(330, 24), "")
	dialogue_label = RichTextLabel.new()
	dialogue_label.position = Vector2(154, 229)
	dialogue_label.size = Vector2(332, 100)
	dialogue_label.bbcode_enabled = false
	dialogue_label.scroll_active = false
	dialogue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dialogue_label)

func _portrait(at: Vector2) -> TextureRect:
	var portrait := TextureRect.new()
	portrait.position = at
	portrait.size = Vector2(128, 128)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	return portrait

func _label(at: Vector2, dimensions: Vector2, value: String) -> Label:
	var label := Label.new()
	label.position = at
	label.size = dimensions
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

## speaker_id は "mu" または左側の相手のID。本文は呼び出し元の正史台詞を渡す。
func show_line(speaker_id: String, partner_name: String, body: String, partner_texture: Texture2D = null, mu_texture: Texture2D = null) -> void:
	if left_portrait == null:
		return
	_speaker = speaker_id
	left_name.text = partner_name
	left_portrait.texture = partner_texture
	mu_portrait.texture = mu_texture
	speaker_label.text = "ムゥ" if speaker_id == "mu" else partner_name
	dialogue_label.text = body
	left_portrait.modulate = Color.WHITE if speaker_id != "mu" else Color(0.55, 0.55, 0.65)
	mu_portrait.modulate = Color.WHITE if speaker_id == "mu" else Color(0.55, 0.55, 0.65)
	# 未登録の顔PNGを勝手に代用しない。空スロットは未配置のまま残す。

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		advance_requested.emit()
		get_viewport().set_input_as_handled()

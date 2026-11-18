extends Control
## 管制会話の左右顔スロット。既存の正式画像は変更せず、参照先だけを差し替える。
## 640x360 の画面に重ねる Control。ムゥは常に右、会話相手は常に左。
## 未登録画像は「画像未登録」と表示し、架空の正式顔を描かない。

@export_file("*.png") var partner_portrait_path: String = ""
@export_file("*.png") var mu_portrait_path: String = ""
@export var partner_name: String = "通信相手"
@export var mu_name: String = "ムゥ"
@export_enum("left", "right", "none") var speaking_side: String = "none"

const PANEL_WIDTH := 112.0
const PANEL_HEIGHT := 126.0
const TOP := 18.0
const LEFT := 16.0
const RIGHT_MARGIN := 16.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_slot(false)
	_build_slot(true)

func _build_slot(is_mu: bool) -> void:
	var panel := PanelContainer.new()
	panel.name = "MuPortrait" if is_mu else "PartnerPortrait"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(640.0 - RIGHT_MARGIN - PANEL_WIDTH if is_mu else LEFT, TOP)
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	add_child(panel)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)

	var image := TextureRect.new()
	image.custom_minimum_size = Vector2(104, 98)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path := mu_portrait_path if is_mu else partner_portrait_path
	if not path.is_empty() and ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			image.texture = resource
	column.add_child(image)

	if image.texture == null:
		var missing := Label.new()
		missing.text = "画像未登録"
		missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		missing.mouse_filter = Control.MOUSE_FILTER_IGNORE
		image.add_child(missing)
		missing.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	var label := Label.new()
	label.text = mu_name if is_mu else partner_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(label)
	panel.modulate.a = 1.0 if speaking_side == ("right" if is_mu else "left") or speaking_side == "none" else 0.55

func set_speaker(side: String) -> void:
	if side not in ["left", "right", "none"]:
		return
	speaking_side = side
	if has_node("PartnerPortrait"):
		get_node("PartnerPortrait").modulate.a = 1.0 if side == "left" or side == "none" else 0.55
	if has_node("MuPortrait"):
		get_node("MuPortrait").modulate.a = 1.0 if side == "right" or side == "none" else 0.55

extends Control
## Standalone, non-canon control-room dialogue preview. No existing art is modified.
## Open res://prototypes/control_room_dialogue_demo.tscn in Godot 4.6.
const VIEW_SIZE := Vector2(640, 360)
const PORTRAITS := {
	"コルミィ": "res://art/active/portrait_cormii.png",
	"ジヨーザ": "res://art/active/portrait_jiyoza.png",
	"マフィオ": "res://art/active/portrait_mafio.png",
	"ムゥ": "res://art/active/portrait_mu.png"
}
const LINES := [
	{"speaker": "ムゥ", "partner": "コルミィ", "text": "帰還を確認した。機体の状態を見せてくれ。"},
	{"speaker": "コルミィ", "partner": "コルミィ", "text": "うん！ でも、あの光が少し気になるんだ。"},
	{"speaker": "ムゥ", "partner": "ジヨーザ", "text": "解析結果はまだ確定していない。"},
	{"speaker": "ジヨーザ", "partner": "ジヨーザ", "text": "了解。記録をもう一度確認する。"},
	{"speaker": "マフィオ", "partner": "マフィオ", "text": "次の出撃までに、何か食べたいな。"}
]
var index := 0
var shown_characters := 0.0
var speed := 26.0
var dialogue_label: Label
var name_label: Label
var left_portrait: TextureRect
var right_portrait: TextureRect
var left_fallback: Label
var right_fallback: Label
var next_button: Button
var log_lines: Array[String] = []

func _ready() -> void:
	custom_minimum_size = VIEW_SIZE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	_show_line()

func _panel(rect: Rect2, color: Color) -> ColorRect:
	var node := ColorRect.new()
	node.position = rect.position
	node.size = rect.size
	node.color = color
	add_child(node)
	return node

func _portrait(rect: Rect2) -> TextureRect:
	var node := TextureRect.new()
	node.position = rect.position
	node.size = rect.size
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(node)
	return node

func _label(rect: Rect2, font_size: int) -> Label:
	var node := Label.new()
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_size_override("font_size", font_size)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(node)
	return node

func _build() -> void:
	_panel(Rect2(0, 0, 640, 360), Color("#090f20"))
	_panel(Rect2(18, 28, 174, 211), Color("#202e43"))
	_panel(Rect2(448, 28, 174, 211), Color("#302b3b"))
	left_portrait = _portrait(Rect2(22, 32, 166, 201))
	right_portrait = _portrait(Rect2(452, 32, 166, 201))
	left_fallback = _label(Rect2(38, 104, 136, 65), 17)
	right_fallback = _label(Rect2(467, 104, 140, 65), 17)
	left_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel(Rect2(14, 247, 612, 103), Color("#111a2d"))
	name_label = _label(Rect2(29, 254, 560, 24), 17)
	dialogue_label = _label(Rect2(29, 281, 572, 49), 16)
	next_button = Button.new()
	next_button.text = "次へ ▶"
	next_button.position = Vector2(530, 326)
	next_button.size = Vector2(90, 28)
	next_button.pressed.connect(advance)
	add_child(next_button)

func _load_portrait(who: String, node: TextureRect, fallback: Label) -> void:
	var path: String = PORTRAITS.get(who, "")
	node.texture = null
	fallback.text = who + "\n（仮表示）"
	if path != "" and ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			node.texture = resource
			fallback.hide()
			return
	fallback.show()

func _show_line() -> void:
	if index >= LINES.size():
		name_label.text = "通信終了"
		dialogue_label.text = "会話プレビューを終了しました。"
		next_button.disabled = true
		return
	var line: Dictionary = LINES[index]
	var partner: String = line["partner"]
	var speaker: String = line["speaker"]
	_load_portrait(partner, left_portrait, left_fallback)
	_load_portrait("ムゥ", right_portrait, right_fallback)
	left_portrait.modulate = Color.WHITE if speaker != "ムゥ" else Color("#858585")
	right_portrait.modulate = Color.WHITE if speaker == "ムゥ" else Color("#858585")
	name_label.text = speaker
	dialogue_label.text = line["text"]
	dialogue_label.visible_characters = 0
	shown_characters = 0.0
	log_lines.append(speaker + "：" + str(line["text"]))

func _process(delta: float) -> void:
	if index >= LINES.size():
		return
	if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		shown_characters += speed * delta
		dialogue_label.visible_characters = mini(int(shown_characters), dialogue_label.get_total_character_count())

func advance() -> void:
	if index >= LINES.size():
		return
	if dialogue_label.visible_characters < dialogue_label.get_total_character_count():
		dialogue_label.visible_characters = -1
	else:
		index += 1
		_show_line()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		advance()
		get_viewport().set_input_as_handled()

func get_dialogue_log() -> Array[String]:
	return log_lines.duplicate()

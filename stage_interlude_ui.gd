extends Control
## Reusable stage interlude. Dialogue is provisional until canon dialogue IDs are approved.
## Does not replace approved portraits; missing portraits display neutral labels.
signal completed

@export var lines: Array[Dictionary] = [
	{"speaker":"クゥ", "text":"通信を確認。次の境界への航路を表示します。"},
	{"speaker":"ムゥ", "text":"機体の点検を始める。少し待っていてくれ。"}
]
@export var mu_portrait: Texture2D
@export var partner_portrait: Texture2D
@export var letters_per_second: float = 34.0

var index := 0
var visible_characters := 0.0
var history: Array[String] = []
var log_open := false
var speaker_label: Label
var dialogue_label: Label
var help_label: Label
var log_label: RichTextLabel

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = Color("#10162b")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	# Left: current speaker/partner; right: Mu. Keep portrait resources optional.
	_add_portrait(partner_portrait, false)
	_add_portrait(mu_portrait, true)
	speaker_label = _label(Vector2(30, 230), Vector2(570, 25), 18)
	dialogue_label = _label(Vector2(30, 260), Vector2(580, 65), 16)
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help_label = _label(Vector2(30, 333), Vector2(580, 20), 11)
	help_label.text = "ENTER: 次へ   TAB: 会話ログ   ESC: スキップ"
	log_label = RichTextLabel.new()
	log_label.position = Vector2(28, 25)
	log_label.size = Vector2(584, 195)
	log_label.visible = false
	log_label.scroll_following = true
	add_child(log_label)
	_show_line()

func _label(pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	add_child(label)
	return label

func _add_portrait(texture: Texture2D, right: bool) -> void:
	var rect := TextureRect.new()
	rect.position = Vector2(452 if right else 24, 24)
	rect.size = Vector2(164, 190)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture = texture
	add_child(rect)
	if texture == null:
		var placeholder := _label(rect.position + Vector2(8, 78), Vector2(148, 30), 13)
		placeholder.text = "ムゥ：画像未設定" if right else "相手：画像未設定"

func _process(delta: float) -> void:
	if log_open or index >= lines.size():
		return
	visible_characters += maxf(0.0, letters_per_second) * delta
	dialogue_label.visible_characters = mini(int(visible_characters), dialogue_label.text.length())

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_TAB:
			log_open = not log_open
			log_label.visible = log_open
			get_viewport().set_input_as_handled()
		KEY_ESCAPE:
			completed.emit()
			get_viewport().set_input_as_handled()
		KEY_ENTER, KEY_SPACE:
			if log_open:
				log_open = false
				log_label.visible = false
			elif dialogue_label.visible_characters < dialogue_label.text.length():
				visible_characters = float(dialogue_label.text.length())
				dialogue_label.visible_characters = -1
			else:
				index += 1
				if index >= lines.size():
					completed.emit()
				else:
					_show_line()
			get_viewport().set_input_as_handled()

func _show_line() -> void:
	if index >= lines.size():
		completed.emit()
		return
	var entry: Dictionary = lines[index]
	var speaker := str(entry.get("speaker", "通信"))
	var message := str(entry.get("text", ""))
	speaker_label.text = speaker
	dialogue_label.text = message
	dialogue_label.visible_characters = 0
	visible_characters = 0.0
	history.append(speaker + "： " + message)
	log_label.text = "\n".join(history)

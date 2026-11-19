extends Control
## Reusable, optional stage intermission UI. Dialogue is provisional, never canon.
## Instantiate with load("res://ui/stage_intermission.gd").new(), add_child(), then configure().
signal completed(next_stage: int)
signal skipped(next_stage: int)

const PixelType = preload("res://ui/pixel_type.gd")
const W := 640.0
const H := 360.0
const CHARS_PER_SECOND := 28.0
const PILOT_PORTRAIT_PATHS := {
	"コルミィ": "res://art/active/pilots/cormii_dialogue_pixel_v01.png",
	"ジヨーザ": "res://art/active/pilots/jiyoza_dialogue_pixel_v01.png",
	"マフィオ": "res://art/active/pilots/mafio_dialogue_pixel_v01.png"
}

var next_stage := 2
var lines: Array[Dictionary] = []
var index := 0
var reveal := 0.0
var history: Array[String] = []
var show_log := false
var done := false
var _title: Label
var _speaker: Label
var _dialogue: Label
var _hint: Label
var _log: Label
var _portrait_panel: ColorRect
var _portrait: TextureRect
var _pilot_portraits: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.065, 0.96)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	for speaker in PILOT_PORTRAIT_PATHS:
		var texture := _load_pilot_portrait(PILOT_PORTRAIT_PATHS[speaker])
		if texture != null:
			_pilot_portraits[speaker] = texture
	_portrait_panel = ColorRect.new()
	_portrait_panel.color = Color(0.03, 0.07, 0.13, 0.86)
	_portrait_panel.position = Vector2(30, 72)
	_portrait_panel.size = Vector2(138, 177)
	_portrait_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_panel.visible = false
	add_child(_portrait_panel)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(34, 76)
	_portrait.size = Vector2(130, 169)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.visible = false
	add_child(_portrait)
	_title = _make_label(Vector2(30, 20), Vector2(580, 42), 24)
	_speaker = _make_label(Vector2(34, 166), Vector2(570, 32), 21)
	_dialogue = _make_label(Vector2(34, 205), Vector2(570, 92), 19)
	_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint = _make_label(Vector2(34, 318), Vector2(570, 30), 14)
	_log = _make_label(Vector2(34, 70), Vector2(570, 220), 16)
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_log.visible = false
	_refresh()

func _load_pilot_portrait(path: String) -> Texture2D:
	if ResourceLoader.exists(path, "Texture2D"):
		return load(path) as Texture2D
	if not FileAccess.file_exists(path):
		return null
	var image := Image.load_from_file(path)
	return ImageTexture.create_from_image(image) if image and not image.is_empty() else null

func _make_label(pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = dimensions
	var size := PixelType.native_size(font_size)
	label.add_theme_font_override("font", PixelType.font_at(size))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("e5f5ff"))
	add_child(label)
	return label

func configure(stage: int, dialogue_lines: Array[Dictionary]) -> void:
	next_stage = maxi(stage, 1)
	lines = dialogue_lines.duplicate(true)
	index = 0
	reveal = 0.0
	history.clear()
	show_log = false
	done = false
	if is_node_ready():
		_refresh()

func _process(delta: float) -> void:
	if done or show_log or lines.is_empty() or index >= lines.size():
		return
	var content := str(lines[index].get("text", ""))
	if reveal < content.length():
		reveal = minf(float(content.length()), reveal + delta * CHARS_PER_SECOND)
		_refresh()

func _refresh() -> void:
	if not is_node_ready() or _title == null:
		return
	_title.text = "STAGE CLEAR  /  次の境界へ"
	_hint.text = "決定/タップ: 続ける   L: 会話ログ   Esc/Start: スキップ"
	_log.visible = show_log
	_speaker.visible = not show_log
	_dialogue.visible = not show_log
	if show_log:
		_portrait_panel.visible = false
		_portrait.visible = false
		_log.text = "\n".join(history.slice(maxi(0, history.size() - 7)))
		return
	if index < lines.size():
		var current := lines[index]
		var content := str(current.get("text", ""))
		var speaker := str(current.get("speaker", "通信"))
		_set_portrait(speaker)
		_speaker.text = speaker
		_dialogue.text = content.substr(0, int(reveal))
	else:
		_set_portrait("")
		_speaker.text = "通信終了"
		_dialogue.text = "次のステージへ出撃します。"

# STORY-VIS-001 — the selected pilot portraits appear only on their own lines.
# Mu and Kuu retain a text-only channel because no portrait is defined here.
func _set_portrait(speaker: String) -> void:
	var texture: Texture2D = _pilot_portraits.get(speaker)
	var visible := texture != null
	_portrait_panel.visible = visible
	_portrait.visible = visible
	if visible:
		_portrait.texture = texture
		_speaker.position = Vector2(190, 166)
		_speaker.size = Vector2(384, 32)
		_dialogue.position = Vector2(190, 205)
		_dialogue.size = Vector2(384, 92)
	else:
		_speaker.position = Vector2(34, 166)
		_speaker.size = Vector2(570, 32)
		_dialogue.position = Vector2(34, 205)
		_dialogue.size = Vector2(570, 92)

func advance() -> void:
	if done:
		return
	if show_log:
		show_log = false
		_refresh()
		return
	if index >= lines.size():
		_complete(false)
		return
	var content := str(lines[index].get("text", ""))
	if reveal < content.length():
		reveal = float(content.length())
	else:
		history.append(str(lines[index].get("speaker", "通信")) + "： " + content)
		index += 1
		reveal = 0.0
	_refresh()

func toggle_log() -> void:
	if done:
		return
	show_log = not show_log
	_refresh()

func _complete(was_skipped: bool) -> void:
	if done:
		return
	done = true
	if was_skipped:
		skipped.emit(next_stage)
	else:
		completed.emit(next_stage)

func _unhandled_input(event: InputEvent) -> void:
	if done:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_complete(true)
		elif event.keycode == KEY_L:
			toggle_log()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			advance()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START:
			_complete(true)
		elif event.button_index == JOY_BUTTON_A:
			advance()
	elif event is InputEventScreenTouch and event.pressed:
		advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()
		get_viewport().set_input_as_handled()

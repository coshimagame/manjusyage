extends Control
## Reusable, optional stage intermission UI. Dialogue is provisional, never canon.
## Instantiate with load("res://ui/stage_intermission.gd").new(), add_child(), then configure().
signal completed(next_stage: int)
signal skipped(next_stage: int)

const PixelType = preload("res://ui/pixel_type.gd")
const ArtCatalog = preload("res://art_catalog.gd")
const LANDSCAPE := preload("res://art/concept/eight_stage_retro_pixel_concepts_20261106.png")
const CHARS_PER_SECOND := 28.0
const INK := Color("111528")
const PAPER := Color("fff3df")
const ACCENTS := {"コルミィ":Color("ff8f99"), "ジヨーザ":Color("8ec9ff"), "マフィオ":Color("ffce76")}

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
var _accent := Color("8ad5d1")
var _scroll: ScrollContainer
var _portrait: TextureRect
var _pilot_portraits: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(640,360)
	for i in range(ArtCatalog.PILOT_NAMES.size()):
		_pilot_portraits[ArtCatalog.PILOT_NAMES[i]] = ArtCatalog.portrait(i)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(21,109)
	_portrait.size = Vector2(174,183)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_portrait)
	_title = _make_label(Vector2(23,12),Vector2(490,29),20)
	_speaker = _make_label(Vector2(218,136),Vector2(380,33),24)
	_dialogue = _make_label(Vector2(218,181),Vector2(400,121),24)
	_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue.add_theme_constant_override("line_spacing",5)
	_hint = _make_label(Vector2(24,322),Vector2(602,25),12)
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(26,61)
	_scroll.size = Vector2(588,241)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_log = _make_label(Vector2.ZERO,Vector2(554,0),20)
	_log.custom_minimum_size.x = 554
	_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_log.reparent(_scroll,false)
	_refresh()

func _draw() -> void:
	draw_rect(Rect2(0,0,640,360),INK)
	if not show_log:
		draw_texture_rect_region(LANDSCAPE,Rect2(0,0,640,124),Rect2(186,121,628,112),Color("afbaca"))
		draw_rect(Rect2(0,0,640,48),Color("101425",.92))
		draw_rect(Rect2(0,121,640,3),_accent.darkened(.35))
		draw_rect(Rect2(14,101,188,198),Color("151e30"))
		draw_rect(Rect2(14,101,188,198),_accent.darkened(.43),false,1)
		if _portrait and not _portrait.visible:
			var trace := PackedVector2Array()
			for x in range(0,150,2):
				var u := x / 150.0
				var wave := sin(x*.56)*sin(PI*u)*sin(PI*u)*sin(x*.084)
				trace.append(Vector2(34+x,201+roundf(wave*25)))
			draw_polyline(trace,_accent,2)
	draw_rect(Rect2(0,313,640,47),Color("0b101e"))
	draw_line(Vector2(24,313),Vector2(616,313),Color("48506a"))

func _make_label(pos: Vector2, dimensions: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = dimensions
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", PixelType.font_at(font_size))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", PAPER)
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
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
		_dialogue.visible_characters = int(reveal) if reveal < content.length() else -1

func _refresh() -> void:
	if not is_node_ready() or _title == null:
		return
	queue_redraw()
	_title.text = "通信履歴" if show_log else "幕間通信"
	_hint.text = "Enter / A　会話に戻る　　↑ ↓　履歴を読む" if show_log else "Enter / A　次へ　　 L　通信履歴　　 Esc / Start　スキップ"
	_scroll.visible = show_log
	_speaker.visible = not show_log
	_dialogue.visible = not show_log
	var current: Dictionary = lines[index] if index < lines.size() else {}
	var speaker := str(current.get("speaker","通信終了"))
	var face: Texture2D = _pilot_portraits.get(speaker)
	_portrait.texture = face
	_portrait.visible = face != null and not show_log
	_accent = ACCENTS.get(speaker, Color("8ad5d1"))
	_speaker.add_theme_color_override("font_color",_accent)
	_speaker.text = speaker
	_dialogue.text = str(current.get("text","次のステージへ出撃します。"))
	var wrap_after := str(current.get("wrap_after",""))
	var finished_line := reveal >= _dialogue.text.length()
	if not wrap_after.is_empty():
		_dialogue.text = _dialogue.text.replace(wrap_after,wrap_after.strip_edges()+"\n")
	_dialogue.visible_characters = -1 if finished_line or current.is_empty() else int(reveal)
	if show_log:
		_log.text = "\n\n".join(history) if not history.is_empty() else "通信履歴はまだありません。"
		_scroll.set_deferred("scroll_vertical", 100000)

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

func _input(event: InputEvent) -> void:
	if done:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if show_log and event.keycode in [KEY_UP,KEY_DOWN]:
			_scroll.scroll_vertical += 36 if event.keycode == KEY_DOWN else -36
		elif event.keycode == KEY_ESCAPE:
			_complete(true)
		elif event.keycode == KEY_L:
			toggle_log()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			advance()
		else: return
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		if show_log and event.button_index in [JOY_BUTTON_DPAD_UP,JOY_BUTTON_DPAD_DOWN]:
			_scroll.scroll_vertical += 36 if event.button_index == JOY_BUTTON_DPAD_DOWN else -36
		elif event.button_index == JOY_BUTTON_START:
			_complete(true)
		elif event.button_index == JOY_BUTTON_A:
			advance()
		else: return
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed and event.device != InputEvent.DEVICE_ID_EMULATION:
		advance()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.device != InputEvent.DEVICE_ID_EMULATION:
		if show_log and _scroll.get_rect().has_point(get_local_mouse_position()): return
		advance()
		get_viewport().set_input_as_handled()

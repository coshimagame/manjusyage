extends Node2D
## Stage-1 clear interlude; all dialogue is provisional and not approved canon.
## This scene is reached after result confirmation; stage 2 remains locked.
const LINES = [
	["クゥ", "境界を越えたわ。みんな、無事？"],
	["コルミィ", "うん！ でも、あの敵……何かを守っていたよね。"],
	["ジヨーザ", "記録を残そう。敵にも理由があるはずだ。"],
	["マフィオ", "こわかった。でも、ちゃんと覚えておく。"],
	["ムゥの整備記録", "帰るための機体だ。無茶をしたら、まず点検しろ。"],
	["クゥ", "次の境界の前に、整備室へ戻りましょう。"]
]
var line_index := 0
var visible_chars := 0.0
var history_open := false
var log_scroll := 0
const LOG_ROWS := 4
var seconds := 0.0
var font: Font
var departing := false
var dialogue_page := 0
const MAX_DIALOGUE_WIDTH := 550.0
const MAX_LOG_WIDTH := 545.0
# Optional approved portraits; missing files preserve the existing workshop silhouettes.
const PORTRAIT_PATHS = {
	"コルミィ": "res://art/active/portrait_cormii.png",
	"ジヨーザ": "res://art/active/portrait_jiyoza.png",
	"マフィオ": "res://art/active/portrait_mafio.png",
	"クゥ": "res://art/active/portrait_kuu.png",
	"ムゥの整備記録": "res://art/active/muu_worldlines/muu_present.png"
}
# Approved v2.2 Muu: shaved-head mechanic and pilot.
# Alternate-worldline portraits are selected only by explicit story events.
var portraits: Dictionary = {}
func _load_portraits() -> void:
	for speaker in PORTRAIT_PATHS:
		var path: String = PORTRAIT_PATHS[speaker]
		if ResourceLoader.exists(path, "Texture2D"):
			var loaded = ResourceLoader.load(path)
			if loaded is Texture2D:
				portraits[speaker] = loaded

func _ready() -> void:
	_load_portraits()
	font = SystemFont.new()
	(font as SystemFont).font_names = PackedStringArray(["Noto Sans CJK JP","Yu Gothic","Meiryo","sans-serif"])
	queue_redraw()
func _process(delta: float) -> void:
	if departing: return
	seconds += delta
	if not history_open:
		var pages := _dialogue_pages()
		visible_chars = minf(float(pages[dialogue_page].length()), visible_chars + delta * 22.0)
	queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
	if departing: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_depart()
		elif event.keycode == KEY_L:
			history_open = not history_open
			if history_open: log_scroll = maxi(0, _log_entry_count() - LOG_ROWS)
		elif history_open and event.keycode in [KEY_UP, KEY_W]:
			log_scroll = maxi(0, log_scroll - 1)
		elif history_open and event.keycode in [KEY_DOWN, KEY_S]:
			log_scroll = mini(maxi(0, _log_entry_count() - LOG_ROWS), log_scroll + 1)
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			_advance()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START: _depart()
		elif history_open and event.button_index == JOY_BUTTON_B:
			history_open = false
		elif event.button_index == JOY_BUTTON_Y:
			history_open = not history_open
			if history_open: log_scroll = maxi(0, _log_entry_count() - LOG_ROWS)
		elif history_open and event.button_index == JOY_BUTTON_DPAD_UP: log_scroll = maxi(0, log_scroll - 1)
		elif history_open and event.button_index == JOY_BUTTON_DPAD_DOWN: log_scroll = mini(maxi(0, _log_entry_count() - LOG_ROWS), log_scroll + 1)
		elif event.button_index == JOY_BUTTON_A: _advance()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
func _advance() -> void:
	if history_open:
		history_open = false
		return
	var pages := _dialogue_pages()
	if visible_chars < pages[dialogue_page].length():
		visible_chars = float(pages[dialogue_page].length())
	elif dialogue_page < pages.size() - 1:
		dialogue_page += 1
		visible_chars = 0
	elif line_index < LINES.size()-1:
		line_index += 1
		dialogue_page = 0
		visible_chars = 0
	else:
		_depart()
func _depart() -> void:
	if departing: return
	departing = true
	# Existing briefing unlock is stored on stage clear. No fake stage 2 launch.
	get_tree().change_scene_to_file.call_deferred("res://main.tscn")
# Width-aware Japanese wrapping: retain every character instead of truncating dialogue.
# Maximum lines are reserved inside the dialogue panel; longer speeches paginate.
const DIALOGUE_ROWS := 2
const DIALOGUE_ROW_HEIGHT := 20
func _wrap_text(value: String, width: float, size: int) -> Array[String]:
	var rows: Array[String] = []
	var row := ""
	for character in value:
		if character == "\n":
			rows.append(row)
			row = ""
			continue
		if font.get_string_size(row + character, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width and not row.is_empty():
			rows.append(row)
			row = character
		else:
			row += character
	rows.append(row)
	return rows

func _dialogue_pages() -> Array[String]:
	var rows := _wrap_text(LINES[line_index][1], MAX_DIALOGUE_WIDTH, 16)
	var pages: Array[String] = []
	for start in range(0, rows.size(), DIALOGUE_ROWS):
		var page := ""
		for row in range(start, mini(start + DIALOGUE_ROWS, rows.size())):
			if not page.is_empty(): page += "\n"
			page += rows[row]
		pages.append(page)
	return pages

func _log_entry_count() -> int:
	# The active line is not a completed memory until every page has been read.
	var pages := _dialogue_pages()
	var completed := dialogue_page == pages.size() - 1 and visible_chars >= float(pages[dialogue_page].length())
	return line_index + (1 if completed else 0)

func _fit_log_text(value: String, width: float, size: int) -> String:
	var result := ""
	for character in value:
		if font.get_string_size(result + character, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
			return result + "…"
		result += character
	return result
func _draw() -> void:
	draw_rect(Rect2(0,0,640,360),Color("#0a1025"))
	for i in range(60):
		draw_rect(Rect2(fposmod(i*91.0-seconds*9.0,640),float((i*43)%300),2,2),Color("#65748e"))
	draw_rect(Rect2(0,0,640,34),Color("#231b39"))
	draw_string(font,Vector2(20,23),"STAGE 01 / AFTERMATH",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("#fff1d9"))
	# Workshop silhouettes are generated procedurally; no approved portraits are replaced.
	draw_rect(Rect2(30,70,580,160),Color("#1a2637"))
	for i in range(3):
		var x = 140+i*170
		draw_line(Vector2(x,90),Vector2(x,204),Color("#445b69"),3)
		draw_colored_polygon(PackedVector2Array([Vector2(x-37,166),Vector2(x,141),Vector2(x+32,166),Vector2(x,186)]),[Color("#e7c75a"),Color("#6ca9ef"),Color("#e76e7c")][i])
	# Approved character PNGs appear only when explicitly provided.
	var speaker: String = LINES[line_index][0]
	if portraits.has(speaker):
		var portrait: Texture2D = portraits[speaker]
		var original := portrait.get_size()
		if original.x > 0 and original.y > 0:
			var scale_factor: float = minf(135.0 / original.x, 145.0 / original.y)
			var target := original * scale_factor
			draw_texture_rect(portrait, Rect2(Vector2(576, 226) - target, target), false)
	draw_rect(Rect2(18,236,604,105),Color("#151529"))
	draw_rect(Rect2(18,236,604,2),Color("#dc9e83"))
	if history_open:
		draw_string(font,Vector2(35,260),"LOG / TRANSCRIPT",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#ffdcaa"))
		for row in range(LOG_ROWS):
			var j := log_scroll + row
			if j >= _log_entry_count(): break
			var entry: String = LINES[j][0]+": "+LINES[j][1]
			draw_string(font,Vector2(35,281+row*13),_fit_log_text(entry,MAX_LOG_WIDTH,11),HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#d4e4dd"))
	else:
		draw_string(font,Vector2(35,264),LINES[line_index][0],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#ffdb9d"))
		var pages := _dialogue_pages()
		var shown := pages[dialogue_page].substr(0, int(visible_chars))
		var visible_rows := shown.split("\n")
		for row in range(visible_rows.size()):
			draw_string(font, Vector2(35, 295 + row * DIALOGUE_ROW_HEIGHT), visible_rows[row], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#edf2f5"))
		draw_string(font,Vector2(423,329),"%d/%d  P%d/%d" % [line_index+1,LINES.size(),dialogue_page+1,pages.size()],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#9ab4c9"))
	draw_string(font,Vector2(22,353),"ENTER/A: NEXT   L/Y: LOG   B: CLOSE   ESC/START: SKIP",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#aab5c6"))

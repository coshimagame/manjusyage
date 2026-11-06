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
var seconds := 0.0
var font: Font
var departing := false
func _ready() -> void:
	font = SystemFont.new()
	(font as SystemFont).font_names = PackedStringArray(["Noto Sans CJK JP","Yu Gothic","Meiryo","sans-serif"])
	queue_redraw()
func _process(delta: float) -> void:
	if departing: return
	seconds += delta
	if not history_open:
		visible_chars = minf(float(LINES[line_index][1].length()),visible_chars + delta * 22.0)
	queue_redraw()
func _unhandled_input(event: InputEvent) -> void:
	if departing: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_depart()
		elif event.keycode == KEY_L:
			history_open = not history_open
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			_advance()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START: _depart()
		elif event.button_index == JOY_BUTTON_A: _advance()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
func _advance() -> void:
	if history_open:
		history_open = false
		return
	if visible_chars < LINES[line_index][1].length():
		visible_chars = float(LINES[line_index][1].length())
	elif line_index < LINES.size()-1:
		line_index += 1
		visible_chars = 0
	else:
		_depart()
func _depart() -> void:
	if departing: return
	departing = true
	# Existing briefing unlock is stored on stage clear. No fake stage 2 launch.
	get_tree().change_scene_to_file.call_deferred("res://main.tscn")
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
	draw_rect(Rect2(18,236,604,105),Color("#151529"))
	draw_rect(Rect2(18,236,604,2),Color("#dc9e83"))
	if history_open:
		draw_string(font,Vector2(35,260),"LOG / TRANSCRIPT",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("#ffdcaa"))
		for j in range(LINES.size()):
			draw_string(font,Vector2(35,278+j*10),LINES[j][0]+": "+LINES[j][1],HORIZONTAL_ALIGNMENT_LEFT,560,11,Color("#d4e4dd"))
	else:
		draw_string(font,Vector2(35,264),LINES[line_index][0],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#ffdb9d"))
		draw_string(font,Vector2(35,299),LINES[line_index][1].substr(0,int(visible_chars)),HORIZONTAL_ALIGNMENT_LEFT,565,16,Color("#edf2f5"))
		draw_string(font,Vector2(430,329),"%d/%d" % [line_index+1,LINES.size()],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#9ab4c9"))
	draw_string(font,Vector2(22,353),"ENTER: NEXT   L: LOG   ESC: SKIP",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#aab5c6"))

extends Control
## Standalone, playable intermission prototype. All dialogue is provisional.
## Open res://intermission_preview.tscn directly in Godot 4.6.
const LINES = [
	["ムゥ", "おかえり。まずは機体を見せてくれ。"],
	["クゥ", "みんな、無事に戻ってきたのね。"],
	["コルミィ", "まだまだ飛べるよ！"],
	["ジヨーザ", "次は、もっと正確に飛びたい。"],
	["マフィオ", "ねえ、次は何が食べられる？"],
	["ムゥ", "焦らず、一つずつ確かめよう。"]
]
var line_index := 0
var visible_chars := 0.0
var log_open := false
var font: SystemFont

func _ready() -> void:
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Yu Gothic", "Meiryo", "Noto Sans CJK JP", "Noto Sans JP", "sans-serif"])
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	if not log_open and line_index < LINES.size():
		visible_chars = minf(float(LINES[line_index][1].length()), visible_chars + delta * 24.0)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.is_echo(): return
	if event.keycode == KEY_L:
		log_open = not log_open
	elif event.keycode == KEY_ESCAPE:
		if log_open: log_open = false
		else: _finish()
	elif event.keycode in [KEY_ENTER, KEY_SPACE]:
		if log_open: log_open = false
		else: _advance()
	get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_B:
			if log_open: log_open = false
			else: _finish()
		elif event.button_index == JOY_BUTTON_Y:
			log_open = not log_open
		elif event.button_index in [JOY_BUTTON_A, JOY_BUTTON_START]:
			if log_open: log_open = false
			else: _advance()
		get_viewport().set_input_as_handled()

func _advance() -> void:
	if visible_chars < LINES[line_index][1].length():
		visible_chars = float(LINES[line_index][1].length())
	elif line_index < LINES.size() - 1:
		line_index += 1
		visible_chars = 0.0
	else:
		_finish()

func _finish() -> void:
	# Preview returns to existing title; integration into stage progression is separate.
	get_tree().change_scene_to_file("res://main.tscn")

func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color("#091421"))
	for x in range(0, int(w), 32):
		draw_line(Vector2(x, 0), Vector2(x, h - 105), Color("#182e42"), 1.0)
	draw_rect(Rect2(36, 42, w - 72, h - 164), Color("#142d39"))
	draw_rect(Rect2(48, 55, w - 96, h - 190), Color("#21414a"))
	# Original pixel-workshop silhouette; no approved portraits are replaced.
	draw_rect(Rect2(w * 0.40, 115, 124, 13), Color("#7eafb1"))
	draw_rect(Rect2(w * 0.43, 93, 76, 24), Color("#d45e64"))
	draw_rect(Rect2(w * 0.48, 69, 26, 24), Color("#e6d5a6"))
	draw_rect(Rect2(18, h - 115, w - 36, 100), Color("#081019"))
	draw_rect(Rect2(18, h - 115, w - 36, 2), Color("#e88b9a"))
	if log_open:
		draw_string(font, Vector2(32, 32), "会話ログ / L または Y で閉じる", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f3dfcc"))
		for i in range(LINES.size()):
			draw_string(font, Vector2(32, 68 + i * 31), LINES[i][0] + "： " + LINES[i][1], HORIZONTAL_ALIGNMENT_LEFT, w - 64, 15, Color("#d4e9ef") if i <= line_index else Color("#637d87"))
		return
	draw_string(font, Vector2(32, h - 90), LINES[line_index][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ffd49a"))
	draw_string(font, Vector2(32, h - 55), LINES[line_index][1].substr(0, int(visible_chars)), HORIZONTAL_ALIGNMENT_LEFT, w - 64, 18, Color("#e9f5f3"))
	draw_string(font, Vector2(32, h - 23), "ENTER/A 次へ   L/Y ログ   ESC/B スキップ", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#90aab5"))

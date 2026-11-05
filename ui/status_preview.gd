extends Control
## Standalone, non-destructive visual prototype. Run res://ui/status_preview.tscn.
## Placeholder silhouettes are explicitly NOT approved character portraits.
const NAMES := ["コルミィ", "ジヨーザ", "マフィオ"]
const ROLES := ["瞬発火力 / 出力変動", "解析 / 着実な強化", "捕食 / 能力変換"]
const COLORS := [Color("#f17d8c"), Color("#7fc7ed"), Color("#f0c778")]
const SHIPS := ["res://art/active/ship_cormii.png", "res://art/active/ship_jiyoza.png", "res://art/active/ship_mafio.png"]
var selected := 0
var font: Font

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	font = ThemeDB.fallback_font
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_RIGHT, KEY_D]:
			selected = (selected + 1) % 3
			queue_redraw()
		elif event.keycode in [KEY_LEFT, KEY_A]:
			selected = (selected + 2) % 3
			queue_redraw()
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_DPAD_RIGHT:
			selected = (selected + 1) % 3
			queue_redraw()
		elif event.button_index == JOY_BUTTON_DPAD_LEFT:
			selected = (selected + 2) % 3
			queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(3):
			if Rect2(24 + i * 204, 90, 192, 218).has_point(event.position):
				selected = i
				queue_redraw()
				accept_event()
				return
	elif event is InputEventScreenTouch and event.pressed:
		for i in range(3):
			if Rect2(24 + i * 204, 90, 192, 218).has_point(event.position):
				selected = i
				queue_redraw()
				accept_event()
				return

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#0b1021"))
	for y in range(0, 360, 4):
		draw_line(Vector2(0, y), Vector2(640, y), Color("#25304a", 0.24))
	draw_string(font, Vector2(24, 34), "MANJUSHAGE  /  STATUS", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#f3e9d9"))
	draw_string(font, Vector2(24, 62), "機体情報  •  方向キー / タップで切替", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a6bdcf"))
	for i in range(3):
		var box := Rect2(24 + i * 204, 90, 192, 218)
		var accent: Color = COLORS[i]
		draw_rect(box, Color("#18243a") if selected == i else Color("#111a2b"))
		draw_rect(Rect2(box.position, Vector2(box.size.x, 3)), accent)
		draw_rect(box, accent if selected == i else Color("#3b5065"), false, 2 if selected == i else 1)
		draw_string(font, box.position + Vector2(12, 29), NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, accent)
		draw_string(font, box.position + Vector2(12, 49), ROLES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#d0dce4"))
		var center := box.position + Vector2(96, 111)
		# Do not invent approved character portraits: use existing in-game ship sprites.
		if ResourceLoader.exists(SHIPS[i]):
			var texture := load(SHIPS[i]) as Texture2D
			if texture != null:
				draw_texture_rect(texture, Rect2(center - Vector2(42, 27), Vector2(84, 54)), false)
			else:
				_draw_placeholder(center, accent)
		else:
			_draw_placeholder(center, accent)
		draw_string(font, box.position + Vector2(12, 179), "機体 / SHIP 0" + str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#dce5ee"))
		draw_string(font, box.position + Vector2(12, 200), "画像差替え対応", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a0b7c7"))
	draw_string(font, Vector2(24, 338), "試作UI  /  人物外観は未確定  /  本編への接続前", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#9aadc0"))

func _draw_placeholder(center: Vector2, accent: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-34, 0), center + Vector2(-14, -12),
		center + Vector2(12, -8), center + Vector2(35, 0),
		center + Vector2(12, 8), center + Vector2(-14, 12)
	]), accent.darkened(0.4))
	draw_line(center + Vector2(-27, 0), center + Vector2(25, 0), accent, 3)
	draw_rect(Rect2(center + Vector2(-5, -4), Vector2(10, 8)), Color("#e8f2f0"))

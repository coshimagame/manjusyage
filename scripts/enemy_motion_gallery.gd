extends Node2D
## 100-enemy runtime motion gallery. PROVISIONAL procedural previews, NOT approved sprite art.
## Open res://scenes/enemy_motion_gallery.tscn with F6. Left/Right switches H/V.
const Catalog = preload("res://scripts/enemy_100_catalog.gd")
const COLS := 10
const CELL := Vector2(64, 36)
var vertical_scroll := false
var elapsed := 0.0
var ids: PackedStringArray

func _ready() -> void:
	ids = Catalog.all_ids()
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT or event.keycode == KEY_RIGHT or event.keycode == KEY_SPACE:
			vertical_scroll = not vertical_scroll
			elapsed = 0.0
			queue_redraw()
			get_viewport().set_input_as_handled()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(640, 360)), Color("#0c1220"))
	if ids.size() != 100:
		return
	for i in range(ids.size()):
		var id := ids[i]
		var spec := Catalog.get_enemy(id)
		var origin := Vector2(float(i % COLS) * CELL.x, float(i / COLS) * CELL.y)
		var center := origin + CELL * 0.5
		var is_boss := spec["kind"] == "boss"
		var tint := Color("#ff9c72") if is_boss else Color("#6bdedb")
		draw_rect(Rect2(origin + Vector2.ONE, CELL - Vector2(2, 2)), Color("#1d2c41"), false, 1.0)
		# Motion is scaled and wrapped within each cell to avoid spilling into neighbors.
		var movement: Vector2 = Catalog.offset_at(id, fposmod(elapsed, 2.5), vertical_scroll) * 0.11
		movement.x = clampf(movement.x, -12.0, 12.0)
		movement.y = clampf(movement.y, -7.0, 7.0)
		var p := center + movement
		var size := 6.0 if is_boss else 3.5
		if vertical_scroll:
			draw_colored_polygon(PackedVector2Array([p + Vector2(0, -size), p + Vector2(size, size), p + Vector2(0, size * 0.4), p + Vector2(-size, size)]), tint)
		else:
			draw_colored_polygon(PackedVector2Array([p + Vector2(-size, -size), p + Vector2(size, 0), p + Vector2(-size, size), p + Vector2(-size * 0.4, 0)]), tint)
		# ID label is generated from the catalog, never implies final character art.
		draw_string(ThemeDB.fallback_font, origin + Vector2(4, 10), id, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#d7e4fa"))

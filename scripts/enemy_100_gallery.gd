extends Node2D
## Standalone QA gallery for procedural EN001..EN100; not part of main game flow.
const Art = preload("res://scripts/enemy_100_provisional.gd")
var vertical := false
var stage := 1
var elapsed := 0.0
var textures: Array[Texture2D] = []

func _ready() -> void:
	_rebuild()
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_SPACE:
		vertical = not vertical
	elif event.keycode == KEY_RIGHT:
		stage = mini(stage + 1, 8)
	elif event.keycode == KEY_LEFT:
		stage = maxi(stage - 1, 1)
	else:
		return
	_rebuild()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _rebuild() -> void:
	textures.clear()
	for slot in range(12):
		var enemy_id := (stage - 1) * 12 + slot + 1
		textures.append(Art.make_texture(enemy_id, vertical))

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#111622"))
	for slot in range(textures.size()):
		var enemy_id := (stage - 1) * 12 + slot + 1
		var col := slot % 6
		var row := int(slot / 6)
		var center := Vector2(65 + col * 100, 85 + row * 145)
		var wobble := Art.movement_at(enemy_id, vertical, elapsed, 6.0)
		var tex := textures[slot]
		draw_texture_rect(tex, Rect2(center + wobble - Vector2(32, 32), Vector2(64, 64)), false)
		draw_string(ThemeDB.fallback_font, center + Vector2(-32, 48), "EN%03d" % enemy_id, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 22), "PROVISIONAL ENEMY PREVIEW / STAGE %d / %s" % [stage, "VERTICAL" if vertical else "HORIZONTAL"], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 342), "LEFT/RIGHT: STAGE   SPACE: ORIENTATION   ART: NOT APPROVED", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ffce63"))

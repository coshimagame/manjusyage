extends Node2D
## Standalone draft sprite gallery; does not alter gameplay or approved sprites.
const IDS := ["EN301", "EN302", "EN303", "EN304", "EN305", "EN306", "EN307", "EN308", "EN309", "SB03", "MB03", "BB03"]
var vertical := false
var textures: Array[Texture2D] = []
func _ready() -> void:
	_reload()
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		vertical = not vertical
		_reload()
func _reload() -> void:
	textures.clear()
	for id in IDS:
		var path := "res://art/enemies/stage03_draft/%s_%s_draft.png" % [id, "v" if vertical else "h"]
		textures.append(load(path) as Texture2D if ResourceLoader.exists(path) else null)
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#0b1b1b"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 24), "STAGE 03 / GARDEN / %s" % ("VERTICAL" if vertical else "HORIZONTAL"), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	for i in range(IDS.size()):
		var center := Vector2(58 + (i % 6) * 105, 90 + int(i / 6) * 140)
		var texture := textures[i]
		if texture != null:
			var dimensions := texture.get_size()
			var factor: float = minf(76.0 / maxf(dimensions.x, 1.0), 75.0 / maxf(dimensions.y, 1.0))
			var size := dimensions * factor
			draw_texture_rect(texture, Rect2(center - size * 0.5, size), false)
		else:
			draw_string(ThemeDB.fallback_font, center - Vector2(28, 4), "MISSING", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ff7777"))
		draw_string(ThemeDB.fallback_font, center + Vector2(-25, 52), IDS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 342), "SPACE: H/V   DRAFT ART ONLY   NOT GAME INTEGRATED", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e4cf79"))

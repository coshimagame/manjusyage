extends Node2D
## Preview-only. Copy draft PNGs from the separate import ZIP to art/enemies/stage01_draft/.
## Never overwrites approved game sprites.
const IDS := ["EN001", "EN002", "EN003", "EN004", "EN005", "EN006", "EN007", "EN008", "EN009", "SB01", "MB01", "BB01"]
var vertical := false
var elapsed := 0.0
var textures: Array[Texture2D] = []

func _ready() -> void:
	_load_textures()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		vertical = not vertical
		_load_textures()

func _load_textures() -> void:
	textures.clear()
	for id in IDS:
		var orientation := "v" if vertical else "h"
		var path := "res://art/enemies/stage01_draft/%s_%s_draft.png" % [id, orientation]
		if ResourceLoader.exists(path):
			textures.append(load(path) as Texture2D)
		else:
			textures.append(null)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#111622"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 23), "STAGE 1 / DRAFT PNG / %s" % ("VERTICAL" if vertical else "HORIZONTAL"), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	for i in range(IDS.size()):
		var center := Vector2(58 + (i % 6) * 105, 94 + int(i / 6) * 140)
		draw_rect(Rect2(center - Vector2(44, 47), Vector2(88, 104)), Color("#26223d"), false, 1.0)
		var texture := textures[i]
		if texture != null:
			var original := texture.get_size()
			var scale_factor: float = minf(72.0 / maxf(original.x, 1.0), 65.0 / maxf(original.y, 1.0))
			var size := original * scale_factor
			var wobble := sin(elapsed * (1.2 + float(i % 3) * 0.4)) * 4.0
			draw_texture_rect(texture, Rect2(center - size / 2.0 + Vector2(0, wobble), size), false)
		else:
			draw_string(ThemeDB.fallback_font, center - Vector2(30, 5), "MISSING", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ff6666"))
		draw_string(ThemeDB.fallback_font, center + Vector2(-26, 52), IDS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 342), "SPACE: H/V  |  DRAFT ONLY  |  NOT IN GAME FLOW", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ffce63"))

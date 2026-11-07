extends RefCounted
class_name StageEnemyArt

# Optional assets. Missing images preserve existing procedural enemy rendering.
const SPRITE_ROOT := "res://art/stage_enemies/"
const ENEMY_IDS := [
	["E-101", "E-102", "E-103"],
	["E-201", "E-202", "E-203"],
	["E-301", "E-302", "E-303"],
	["E-401", "E-402", "E-403"],
	["E-501", "E-502", "E-503"],
	["E-601", "E-602", "E-603"],
	["E-701", "E-702", "E-703"],
	["E-801", "E-802", "E-803"],
]

# Direction-specific PNGs are separate illustrations, never rotated copies.
# Legacy enemy_sNN_VV.png remains supported for older art packs.
static func sprite_path(stage_number: int, enemy_variant: int, vertical_scroll: bool = false) -> String:
	if stage_number < 1 or stage_number > 8 or enemy_variant < 1 or enemy_variant > 3:
		return ""
	var direction := "vertical" if vertical_scroll else "horizontal"
	return "%senemy_s%02d_%02d_%s.png" % [SPRITE_ROOT, stage_number, enemy_variant, direction]

# Returns the actual imported asset path, or an empty string when a placeholder is needed.
# Used by asset QA so procedural fallback art is never mistaken for approved PNGs.
static func resolved_sprite_path(stage_number: int, enemy_variant: int, vertical_scroll: bool = false) -> String:
	var path := sprite_path(stage_number, enemy_variant, vertical_scroll)
	if path.is_empty():
		return ""
	if ResourceLoader.exists(path, "Texture2D"):
		return path
	var direction := "vertical" if vertical_scroll else "horizontal"
	var import_path := "%sstage%02d_enemy%02d_%s.png" % [SPRITE_ROOT, stage_number, enemy_variant, direction]
	if ResourceLoader.exists(import_path, "Texture2D"):
		return import_path
	if not vertical_scroll:
		var legacy_path := "%senemy_s%02d_%02d.png" % [SPRITE_ROOT, stage_number, enemy_variant]
		if ResourceLoader.exists(legacy_path, "Texture2D"):
			return legacy_path
	return ""

static func load_sprite(stage_number: int, enemy_variant: int, vertical_scroll: bool = false) -> Texture2D:
	var path := resolved_sprite_path(stage_number, enemy_variant, vertical_scroll)
	if path.is_empty():
		return null
	return ResourceLoader.load(path) as Texture2D

static func create_visual(stage_number: int, enemy_variant: int, vertical_scroll: bool = false) -> Sprite2D:
	var texture := load_sprite(stage_number, enemy_variant, vertical_scroll)
	if texture == null:
		texture = make_placeholder(stage_number, enemy_variant)
	if texture == null:
		return null
	var visual := Sprite2D.new()
	visual.texture = texture
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Runtime QA: identify whether the visible enemy uses an imported PNG or fallback art.
	# This metadata never changes an approved sprite or save-game data.
	var source_path := resolved_sprite_path(stage_number, enemy_variant, vertical_scroll)
	visual.set_meta("enemy_art_source", source_path)
	visual.set_meta("enemy_art_placeholder", source_path.is_empty())
	visual.set_meta("enemy_art_id", enemy_id(stage_number, enemy_variant))
	visual.set_meta("enemy_art_direction", "vertical" if vertical_scroll else "horizontal")
	# Vertical art is drawn top-down by the artist; do not rotate.
	visual.rotation_degrees = 0.0
	return visual

static func enemy_id(stage_number: int, enemy_variant: int) -> String:
	if stage_number < 1 or stage_number > 8 or enemy_variant < 1 or enemy_variant > 3:
		return ""
	return ENEMY_IDS[stage_number - 1][enemy_variant - 1]

# Distinct transparent fallback sprites allow stage previews before PNG import.
# Temporary 16x16 silhouettes, not approved character artwork.
static func make_placeholder(stage_number: int, enemy_variant: int) -> Texture2D:
	if stage_number < 1 or stage_number > 8 or enemy_variant < 1 or enemy_variant > 3:
		return null
	var palettes := [
		Color("d94465"), Color("42b5dc"), Color("84c978"), Color("a8a2fa"),
		Color("d59c61"), Color("e2e5c7"), Color("a779df"), Color("ed6f9e")
	]
	var primary: Color = palettes[stage_number - 1]
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in range(2, 14):
		for x in range(1, 15):
			var dx := abs(x - 7)
			var dy := abs(y - 7)
			var occupied := false
			match enemy_variant:
				1: occupied = (dx + dy < 9 and (dy < 4 or dx < 4))
				2: occupied = (dx < 6 and dy < 5 and (dx < 3 or dy < 3))
				3: occupied = (dx * dx + dy * dy < 43)
			if occupied:
				var edge := dx >= 5 or dy >= 5
				image.set_pixel(x, y, primary.darkened(0.42) if edge else primary)
	for x in range(6, 10):
		image.set_pixel(x, 7, Color("f8f4dc"))
		image.set_pixel(x, 8, Color("273045"))
	return ImageTexture.create_from_image(image)

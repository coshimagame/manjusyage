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

static func sprite_path(stage_number: int, enemy_variant: int) -> String:
	if stage_number < 1 or stage_number > 8 or enemy_variant < 1 or enemy_variant > 3:
		return ""
	return "%senemy_s%02d_%02d.png" % [SPRITE_ROOT, stage_number, enemy_variant]

static func load_sprite(stage_number: int, enemy_variant: int) -> Texture2D:
	var path := sprite_path(stage_number, enemy_variant)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

static func create_visual(stage_number: int, enemy_variant: int, vertical_scroll: bool = false) -> Sprite2D:
	var texture := load_sprite(stage_number, enemy_variant)
	if texture == null:
		return null
	var visual := Sprite2D.new()
	visual.texture = texture
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Source sprites face left/right for horizontal play; turn for vertical play.
	visual.rotation_degrees = 90.0 if vertical_scroll else 0.0
	return visual

static func enemy_id(stage_number: int, enemy_variant: int) -> String:
	if stage_number < 1 or stage_number > 8 or enemy_variant < 1 or enemy_variant > 3:
		return ""
	return ENEMY_IDS[stage_number - 1][enemy_variant - 1]

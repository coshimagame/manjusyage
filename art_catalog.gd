extends RefCounted
# Optional artwork. New per-character/enemy/stage paths take priority.
# Legacy art/active/*.png paths remain supported for old projects.
# No image = existing procedural drawing fallback.
const ROOT = "res://art/active/"
const SLOTS = [
	"title_logo", "title_backdrop",
	"ship_cormii", "ship_jiyoza", "ship_mafio",
	"portrait_cormii", "portrait_jiyoza", "portrait_mafio",
	"enemy_lance", "enemy_bloom",
	"item_hp", "item_energy", "item_omikuji", "item_analysis",
	"bio_backdrop", "boss_body", "bullet_player", "bullet_enemy",
	"fx_petal", "fx_spark", "bullet_needle", "bullet_eye", "bullet_ring",
	"v09_cosmos", "v09_ship_atlas", "v09_enemy_0", "v09_enemy_1",
	"v09_enemy_2", "v09_enemy_3", "stage_concept_board",
	"title_logo_extended", "launch_button", "chat_ui_atlas",
	"character_hub_ui", "character_system_ui"
]
const ORGANIZED_PATHS = {
	"title_logo": "res://art/ui/logos/title_logo.png",
	"title_backdrop": "res://art/backgrounds/title/backdrop.png",
	"ship_cormii": "res://art/characters/cormii/ship.png",
	"ship_jiyoza": "res://art/characters/jiyoza/ship.png",
	"ship_mafio": "res://art/characters/mafio/ship.png",
	"portrait_cormii": "res://art/characters/cormii/portrait.png",
	"portrait_jiyoza": "res://art/characters/jiyoza/portrait.png",
	"portrait_mafio": "res://art/characters/mafio/portrait.png",
	"enemy_lance": "res://art/enemies/lance/sprite.png",
	"enemy_bloom": "res://art/enemies/bloom/sprite.png",
	"bio_backdrop": "res://art/backgrounds/stage_01/backdrop.png",
	"item_hp": "res://art/items/common/hp/icon.png",
	"item_energy": "res://art/items/common/energy/icon.png",
	"item_omikuji": "res://art/items/characters/cormii/omikuji/icon.png",
	"item_analysis": "res://art/items/characters/jiyoza/analysis/icon.png",
	"boss_body": "res://art/enemies/boss/body.png",
	"bullet_player": "res://art/bullets/player.png",
	"bullet_enemy": "res://art/bullets/enemy_petal.png",
	"fx_petal": "res://art/effects/petal.png",
	"fx_spark": "res://art/effects/spark.png",
	"bullet_needle": "res://art/bullets/needle.png",
	"bullet_eye": "res://art/bullets/eye.png",
	"bullet_ring": "res://art/bullets/ring.png",
	"v09_cosmos": "res://art/v09/cosmos.png",
	"v09_ship_atlas": "res://art/v09/ship-atlas.png",
	"v09_enemy_0": "res://art/v09/enemy-0.png",
	"v09_enemy_1": "res://art/v09/enemy-1.png",
	"v09_enemy_2": "res://art/v09/enemy-2.png",
	"v09_enemy_3": "res://art/v09/enemy-3.png",
	"stage_concept_board": "res://art/concept/eight_stage_retro_pixel_concepts_20261106.png",
	"title_logo_extended": "res://art/ui/title_logo_extended_v01.png",
	"launch_button": "res://art/ui/launch_button_v01.png",
	"chat_ui_atlas": "res://art/ui/chat_ui_atlas_20261106.png",
	"character_hub_ui": "res://art/ui/character_hub_ui_20261106.png",
	"character_system_ui": "res://art/ui/character_system_ui_20261106.png"
}
const COPIED_ORIGINAL_PATHS = {
	"title_logo": "res://art/backgrounds/title/title_logo.png",
	"ship_cormii": "res://art/characters/cormii/ship_cormii.png",
	"ship_jiyoza": "res://art/characters/jiyoza/ship_jiyoza.png",
	"ship_mafio": "res://art/characters/mafio/ship_mafio.png"
}
const PREVIOUS_ITEM_PATHS = {
	"item_hp": "res://art/items/hp/icon.png",
	"item_energy": "res://art/items/energy/icon.png",
	"item_omikuji": "res://art/items/omikuji/icon.png",
	"item_analysis": "res://art/items/analysis/icon.png"
}
var images: Dictionary = {}

func reload():
	images.clear()
	for key in SLOTS:
		var candidates: Array[String] = []
		if ORGANIZED_PATHS.has(key):
			candidates.append(ORGANIZED_PATHS[key])
		if COPIED_ORIGINAL_PATHS.has(key):
			candidates.append(COPIED_ORIGINAL_PATHS[key])
		if PREVIOUS_ITEM_PATHS.has(key):
			candidates.append(PREVIOUS_ITEM_PATHS[key])
		candidates.append(ROOT + key + ".png")
		for file_path in candidates:
			if not ResourceLoader.exists(file_path, "Texture2D"):
				continue
			var resource = ResourceLoader.load(file_path)
			if resource is Texture2D:
				images[key] = resource
				break

func texture(key: String) -> Texture2D:
	return images.get(key, null) as Texture2D

# --- Reference ships, ported from branch playtest/stage1-v09-20261119 ---
# The v0.9 per-character ships live as large sheets under art/active/ships/;
# reference_ship() returns the cropped AtlasTexture for a character and
# view. Sheets load as images (not import-cache resources), matching the
# rest of this project. A design-variant PNG (user sample, 2026-11-21),
# ships/<name>_design_v01[_v].png, wins over the sheet when present, so the
# adopted design can be swapped or removed without touching code.
const SHIP_NAMES = ["cormii", "jiyoza", "mafio"]
const MAFIO_GOLD_BLACK := "res://art/active/ships/mafio_gold_black_v02.png"
const MAFIO_GOLD_BLACK_REGION := Rect2(151,135,1472,615)
const REFERENCE_SHIPS = [
	"cormii_reference_v01.png",
	"jiyoza_reference_v01.png",
	"mafio_reference_v01.png",
]
const SHIP_REGIONS = [
	Rect2(218,100,1337,690),
	Rect2(179,100,1416,693),
	Rect2(211,110,1348,660),
]
const VERTICAL_SHIPS = [
	"cormii_muu_v02_v.png",
	"jiyoza_muu_v02_v.png",
	"mafio_gold_black_v02.png",
]
const VERTICAL_REGIONS = [
	Rect2(184,108,1399,670),
	Rect2(256,72,1522,638),
	MAFIO_GOLD_BLACK_REGION,
]
const HORIZONTAL_SHIPS = [
	"cormii_muu_v02_h.png",
	"jiyoza_muu_v02_h.png",
	"mafio_gold_black_v03_h.png",
]
const HORIZONTAL_REGIONS = [
	Rect2(263,124,1499,535),
	Rect2(138,201,1720,424),
	Rect2(262,107,1491,573),
]
static var _ship_sheet_cache: Dictionary = {}

static func _sheet_texture(path: String) -> Texture2D:
	if _ship_sheet_cache.has(path):
		return _ship_sheet_cache[path]
	var tex: Texture2D = null
	# Resource loader first: exported builds only carry the remapped
	# imported texture, never the raw PNG bytes.
	if ResourceLoader.exists(path, "Texture2D"):
		var res = ResourceLoader.load(path, "Texture2D")
		if res is Texture2D:
			tex = res
	if tex == null and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		if image and not image.is_empty():
			tex = ImageTexture.create_from_image(image)
	_ship_sheet_cache[path] = tex
	return tex

static func reference_ship(character: int, vertical_view := false) -> Texture2D:
	var index := clampi(character, 0, REFERENCE_SHIPS.size() - 1)
	var directory := ROOT + "ships/"
	var design_path: String = directory + SHIP_NAMES[index] + "_design_v01" + ("_v" if vertical_view else "") + ".png"
	var design := _sheet_texture(design_path)
	if design:
		return design
	var names := VERTICAL_SHIPS if vertical_view else HORIZONTAL_SHIPS
	var regions := VERTICAL_REGIONS if vertical_view else HORIZONTAL_REGIONS
	var region: Rect2 = regions[index]
	var sheet := _sheet_texture(directory + names[index])
	if sheet == null and index == 2:
		sheet = _sheet_texture(MAFIO_GOLD_BLACK)
		region = MAFIO_GOLD_BLACK_REGION
	if sheet == null:
		sheet = _sheet_texture(directory + REFERENCE_SHIPS[index])
		region = SHIP_REGIONS[index]
	if sheet == null:
		return null
	var ship := AtlasTexture.new()
	ship.atlas = sheet
	ship.region = region
	ship.filter_clip = true
	return ship

extends RefCounted
# Optional artwork. New per-character/enemy/stage paths take priority.
# Legacy art/active/*.png paths remain supported for old projects.
# No image = existing procedural drawing fallback.
const ROOT = "res://art/active/"
const SLOTS = [
	"title_logo", "title_backdrop",
	"ship_cormii", "ship_jiyoza", "ship_mafio",
	"enemy_lance", "enemy_bloom",
	"item_hp", "item_energy", "item_omikuji", "item_analysis",
	"bio_backdrop", "boss_body"
]
const ORGANIZED_PATHS = {
	"title_backdrop": "res://art/backgrounds/title/backdrop.png",
	"ship_cormii": "res://art/characters/cormii/ship.png",
	"ship_jiyoza": "res://art/characters/jiyoza/ship.png",
	"ship_mafio": "res://art/characters/mafio/ship.png",
	"enemy_lance": "res://art/enemies/lance/sprite.png",
	"enemy_bloom": "res://art/enemies/bloom/sprite.png",
	"bio_backdrop": "res://art/backgrounds/stage_01/backdrop.png",
	"item_hp": "res://art/items/hp/icon.png",
	"item_energy": "res://art/items/energy/icon.png",
	"item_omikuji": "res://art/items/omikuji/icon.png",
	"item_analysis": "res://art/items/analysis/icon.png",
	"boss_body": "res://art/enemies/boss/body.png"
}
var images: Dictionary = {}

func reload():
	images.clear()
	for key in SLOTS:
		var candidates: Array[String] = []
		if ORGANIZED_PATHS.has(key):
			candidates.append(ORGANIZED_PATHS[key])
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

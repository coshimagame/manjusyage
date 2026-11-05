extends RefCounted
# Optional PNG artwork. Keep each slot independent so art experiments never
# break gameplay when a file is missing. Textures load at game startup.
const ROOT = "res://art/active/"
const SLOTS = [
	"title_logo", "title_backdrop", "button_sortie",
	"portrait_cormii", "portrait_jiyoza", "portrait_mafio",
	"ship_cormii", "ship_jiyoza", "ship_mafio",
	"enemy_lance", "enemy_bloom",
	"item_hp", "item_energy", "item_omikuji", "item_analysis",
	"bio_backdrop", "boss_body"
]
var images: Dictionary = {}

func reload():
	images.clear()
	for key in SLOTS:
		var file_path: String = ROOT + key + ".png"
		if not ResourceLoader.exists(file_path, "Texture2D"):
			continue
		var resource = ResourceLoader.load(file_path)
		if resource is Texture2D:
			images[key] = resource

func texture(key: String) -> Texture2D:
	return images.get(key, null) as Texture2D

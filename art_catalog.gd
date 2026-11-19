extends RefCounted
# Optional PNG artwork. Keep each slot independent so art experiments never
# break gameplay when a file is missing. Textures load at game startup.
const ROOT = "res://art/active/"
const MAFIO_GOLD_BLACK := "res://art/active/ships/mafio_gold_black_v02.png"
const MAFIO_GOLD_BLACK_REGION := Rect2(151,135,1472,615)
const REFERENCE_SHIPS := [
	"cormii_reference_v01.png",
	"jiyoza_reference_v01.png",
	"mafio_reference_v01.png",
]
const SHIP_REGIONS := [
	Rect2(218,100,1337,690),
	Rect2(179,100,1416,693),
	Rect2(211,110,1348,660),
]
const SLOTS = [
	"title_logo", "title_backdrop",
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

static func reference_ship(character: int) -> Texture2D:
	var index := clampi(character,0,REFERENCE_SHIPS.size()-1)
	var path: String = ROOT+"ships/"+REFERENCE_SHIPS[index]
	var region: Rect2 = SHIP_REGIONS[index]
	if index==2 and ResourceLoader.exists(MAFIO_GOLD_BLACK,"Texture2D"):
		path=MAFIO_GOLD_BLACK
		region=MAFIO_GOLD_BLACK_REGION
	if not ResourceLoader.exists(path,"Texture2D"):
		return null
	var ship := AtlasTexture.new()
	ship.atlas=load(path)
	ship.region=region
	ship.filter_clip=true
	return ship

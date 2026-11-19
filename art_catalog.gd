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
const VERTICAL_SHIPS := [
	"cormii_muu_v02_v.png",
	"jiyoza_muu_v02_v.png",
	"mafio_gold_black_v02.png",
]
const VERTICAL_REGIONS := [
	Rect2(184,108,1399,670),
	Rect2(256,72,1522,638),
	MAFIO_GOLD_BLACK_REGION,
]
const HORIZONTAL_SHIPS := [
	"cormii_muu_v02_h.png",
	"jiyoza_muu_v02_h.png",
	"mafio_gold_black_v03_h.png",
]
const HORIZONTAL_REGIONS := [
	Rect2(263,124,1499,535),
	Rect2(138,201,1720,424),
	Rect2(262,107,1491,573),
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

static func reference_ship(character: int, vertical_view := false) -> Texture2D:
	var index := clampi(character,0,REFERENCE_SHIPS.size()-1)
	var directory := ROOT+"ships/"
	var names := VERTICAL_SHIPS if vertical_view else HORIZONTAL_SHIPS
	var regions := VERTICAL_REGIONS if vertical_view else HORIZONTAL_REGIONS
	var path: String = directory+names[index]
	var region: Rect2 = regions[index]
	if not ResourceLoader.exists(path,"Texture2D") and index==2:
		path=MAFIO_GOLD_BLACK
		region=MAFIO_GOLD_BLACK_REGION
	if not ResourceLoader.exists(path,"Texture2D"):
		path=directory+REFERENCE_SHIPS[index]
		region=SHIP_REGIONS[index]
	if not ResourceLoader.exists(path,"Texture2D"):
		return null
	var ship := AtlasTexture.new()
	ship.atlas=load(path)
	ship.region=region
	ship.filter_clip=true
	return ship

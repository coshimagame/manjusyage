extends RefCounted
# Optional PNG artwork. Keep each slot independent so art experiments never
# break gameplay when a file is missing. Textures load at game startup.
const ROOT = "res://art/active/"
const SLOTS = [
	"title_logo", "title_backdrop",
	"ship_cormii", "ship_jiyoza", "ship_mafio",
	"enemy_lance", "enemy_bloom",
	"item_hp", "item_energy", "item_omikuji", "item_analysis",
	"bio_backdrop", "boss_body"
]
var images: Dictionary = {}
var generated: Dictionary = {}

func reload():
	images.clear()
	generated.clear()
	for key in SLOTS:
		var file_path: String = ROOT + key + ".png"
		if not ResourceLoader.exists(file_path, "Texture2D"):
			continue
		var resource = ResourceLoader.load(file_path)
		if resource is Texture2D:
			images[key] = resource

func texture(key: String) -> Texture2D:
	if images.has(key):
		return images[key] as Texture2D
	if generated.has(key):
		return generated[key] as Texture2D
	if key in ["item_omikuji", "item_analysis", "item_hp", "item_energy", "title_backdrop", "bio_backdrop"]:
		var tex := _procedural(key)
		generated[key] = tex
		return tex
	return null

func _procedural(key: String) -> Texture2D:
	var backdrop := key.ends_with("backdrop")
	var w := 320 if backdrop else 32
	var h := 180 if backdrop else 32
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	if backdrop:
		for y in range(h):
			var sky := Color("#10132e").lerp(Color("#522342"), float(y) / float(h))
			for x in range(w):
				img.set_pixel(x, y, sky)
		for i in range(36):
			var cx := (i * 83 + 19) % w
			var cy := 90 + (i * 41) % 85
			for j in range(6):
				var angle := float(j) * TAU / 6.0
				var px := cx + roundi(cos(angle) * 7)
				var py := cy + roundi(sin(angle) * 5)
				if px >= 0 and px < w and py >= 0 and py < h:
					img.set_pixel(px, py, Color("#ff668a"))
			for stem in range(1, 12):
				if cy + stem < h:
					img.set_pixel(cx, cy + stem, Color("#6b4865"))
	else:
		var tint := Color("#ff6b92")
		match key:
			"item_analysis": tint = Color("#65cfff")
			"item_hp": tint = Color("#6af5a2")
			"item_energy": tint = Color("#8c9cff")
		for y in range(4, 28):
			for x in range(4, 28):
				var dx := x - 16
				var dy := y - 16
				if dx * dx + dy * dy < 130:
					img.set_pixel(x, y, tint.darkened(0.5))
				if dx * dx + dy * dy < 60:
					img.set_pixel(x, y, tint)
		for i in range(8, 24):
			if key == "item_hp":
				for j in range(13, 20):
					img.set_pixel(i, j, Color.WHITE)
					img.set_pixel(j, i, Color.WHITE)
			elif key == "item_analysis":
				img.set_pixel(i, 16, Color.WHITE)
				img.set_pixel(16, i, Color.WHITE)
			elif key == "item_energy":
				img.set_pixel(16 + roundi(sin(float(i) * 0.7) * 4), i, Color.WHITE)
			else:
				img.set_pixel(i, 16 + roundi(sin(float(i) * 0.9) * 4), Color("#fff0c9"))
	return ImageTexture.create_from_image(img)

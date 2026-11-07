extends RefCounted
## Provisional pixel silhouettes for EN001..EN100. NOT approved character art.
## Standalone runtime fallback: never overwrites imported PNGs.
## Call make_texture(id, vertical) to get a usable transparent Sprite2D texture.
## Use only when an approved asset for the same ID/orientation is missing.

const COUNT := 100
const SIZE := 32
const COLORS := [
	Color("#c94756"), Color("#3c9ab4"), Color("#609b60"), Color("#a9a4d9"),
	Color("#a48b65"), Color("#d0e6e8"), Color("#b989d0"), Color("#c96e96")
]

static func stage_for(enemy_id: int) -> int:
	if enemy_id < 1 or enemy_id > COUNT:
		return 0
	return mini(8, int((enemy_id - 1) / 12) + 1)

static func role_for(enemy_id: int) -> String:
	if enemy_id < 1 or enemy_id > COUNT:
		return "invalid"
	if enemy_id > 96:
		return "special_proposal"
	var slot := (enemy_id - 1) % 12
	if slot == 9:
		return "small_boss"
	if slot == 10:
		return "mid_boss"
	if slot == 11:
		return "large_boss"
	return "normal"

static func source_path(enemy_id: int, vertical: bool) -> String:
	var direction := "v" if vertical else "h"
	return "res://art/enemies/en%03d_%s.png" % [enemy_id, direction]

static func make_texture(enemy_id: int, vertical: bool) -> ImageTexture:
	if enemy_id < 1 or enemy_id > COUNT:
		return null
	var image := make_image(enemy_id, vertical)
	return ImageTexture.create_from_image(image)

static func make_image(enemy_id: int, vertical: bool) -> Image:
	if enemy_id < 1 or enemy_id > COUNT:
		return null
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var stage := stage_for(enemy_id)
	var role := role_for(enemy_id)
	var seed := enemy_id * 7919 + (23 if vertical else 0)
	var tint: Color = COLORS[stage - 1]
	var edge := tint.darkened(0.45)
	var light := tint.lightened(0.42)
	var boss := role != "normal" and role != "special_proposal"
	var radius := 12 if boss else 9
	# Deliberately distinct frontal and side profiles; not a rotated texture.
	for y in range(SIZE):
		for x in range(SIZE):
			var dx := abs(x - 15)
			var dy := abs(y - 15)
			var wing := (dx * 2 + dy if vertical else dx + dy * 2)
			var shape := wing < radius * 2
			var notch := ((x * 13 + y * 7 + seed) % 19) < 3
			var rib := ((x if vertical else y) + enemy_id) % 5 == 0
			if shape and (not notch or dx + dy < 7):
				var outline := wing >= radius * 2 - 3
				image.set_pixel(x, y, edge if outline else (light if rib else tint))
	# A directional core and exhaust distinguish the two scroll orientations.
	for i in range(4):
		for j in range(4):
			var cx := 14 + i
			var cy := 14 + j
			image.set_pixel(cx, cy, Color("#fff0ba"))
	for i in range(5):
		var offset := (i + enemy_id) % 3
		if vertical:
			image.set_pixel(13 + i, 25 + offset, light)
		else:
			image.set_pixel(25 + offset, 13 + i, light)
	return image

static func movement_at(enemy_id: int, vertical: bool, elapsed: float, speed: float = 60.0) -> Vector2:
	# Local displacement in pixels. Caller owns collision and actual spawn position.
	var pattern := (enemy_id - 1) % 9
	var forward := Vector2(0, speed * elapsed) if vertical else Vector2(-speed * elapsed, 0)
	var lateral := Vector2(1, 0) if vertical else Vector2(0, 1)
	if pattern == 0:
		return forward
	if pattern == 1:
		return forward + lateral * sin(elapsed * 3.0) * 22.0
	if pattern == 2:
		return forward + lateral * sin(elapsed * 5.0) * 36.0
	if pattern == 3:
		return forward + lateral * cos(elapsed * 2.0) * 18.0
	if pattern == 4:
		return forward + lateral * sin(elapsed * 2.0) * 50.0
	if pattern == 5:
		return forward * 0.7 + lateral * sin(elapsed * 4.0) * 16.0
	if pattern == 6:
		return forward + lateral * (1.0 if int(elapsed * 2.0) % 2 == 0 else -1.0) * 20.0
	if pattern == 7:
		return forward * 1.25
	return forward * 0.85 + lateral * cos(elapsed * 6.0) * 12.0

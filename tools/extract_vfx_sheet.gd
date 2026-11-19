extends SceneTree

# Converts the retained ImageGen concept sheet into small, replaceable RGBA
# gameplay sprites.  This is intentionally a presentation-only build step:
# it neither reads nor changes combat data, collision radii, or pickup values.
const SOURCE := "res://art/originals/vfx_generated/vfx_p0_sheet_source_v01.png"
const TARGETING_SOURCE := "res://art/originals/vfx_generated/vfx_p0_targeting_source_v01.png"
const OUTPUTS := [
	{"id":"I01","path":"res://art/active/items/item_hp_p0.png","rect":Rect2i(80,70,390,350),"size":Vector2i(64,64)},
	{"id":"I02","path":"res://art/active/items/item_energy_p0.png","rect":Rect2i(570,70,400,350),"size":Vector2i(64,64)},
	{"id":"B01","path":"res://art/active/vfx/bullet_petal_p0.png","rect":Rect2i(1050,70,390,350),"size":Vector2i(64,64)},
	{"id":"B02","path":"res://art/active/vfx/bullet_needle_p0.png","rect":Rect2i(50,560,440,370),"size":Vector2i(80,48)},
	{"id":"V01","path":"res://art/active/vfx/defeat_petals_p0.png","rect":Rect2i(515,530,450,400),"size":Vector2i(72,64)},
	{"id":"V15","path":"res://art/active/vfx/pickup_pillar_p0.png","rect":Rect2i(1120,510,380,450),"size":Vector2i(48,72)}
]
const TARGETING_OUTPUTS := [
	{"id":"B05","path":"res://art/active/vfx/bullet_flower_ring_p0.png","rect":Rect2i(210,170,600,600),"size":Vector2i(64,64)},
	{"id":"B10","path":"res://art/active/vfx/bullet_target_eye_p0.png","rect":Rect2i(970,150,570,620),"size":Vector2i(64,64)}
]

func _initialize() -> void:
	var source := Image.load_from_file(SOURCE)
	if source == null or source.is_empty():
		push_error("Missing P0 VFX source sheet: " + SOURCE)
		quit(1)
		return
	var targeting_source := Image.load_from_file(TARGETING_SOURCE)
	if targeting_source == null or targeting_source.is_empty():
		push_error("Missing P0 targeting source sheet: " + TARGETING_SOURCE)
		quit(1)
		return
	if not _extract_outputs(source, OUTPUTS) or not _extract_outputs(targeting_source, TARGETING_OUTPUTS) or not _make_hit_flash():
		quit(1)
		return
	print("VFX sheet extraction PASS: ", OUTPUTS.size() + TARGETING_OUTPUTS.size() + 1, " transparent gameplay assets")
	quit()

func _extract_outputs(source: Image, outputs: Array) -> bool:
	for output in outputs:
		if not Rect2i(Vector2i.ZERO,source.get_size()).encloses(output.rect):
			push_error("Crop outside source sheet: " + str(output.id))
			return false
		var image := Image.create(output.rect.size.x, output.rect.size.y, false, Image.FORMAT_RGBA8)
		image.blit_rect(source, output.rect, Vector2i.ZERO)
		_remove_dark_presentation_backdrop(image)
		image.resize(output.size.x, output.size.y, Image.INTERPOLATE_NEAREST)
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output.path).get_base_dir())
		var error := image.save_png(output.path)
		if error != OK:
			push_error("Could not save " + output.path + ": " + error_string(error))
			return false
		print("VFX EXTRACTED ", output.id, " -> ", output.path)
	return true

func _make_hit_flash() -> bool:
	# V02 is a deliberately geometric 0.12-second hit cue in the GitHub rough:
	# retaining it as a tiny procedural source avoids a muddy AI-rendered glow.
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for axis in range(3, 46):
		for width in range(-1, 2):
			image.set_pixel(axis, 24 + width, Color("fff2a9"))
			image.set_pixel(24 + width, axis, Color("fff2a9"))
	for axis in range(10, 39):
		image.set_pixel(axis, 24, Color.WHITE)
		image.set_pixel(24, axis, Color.WHITE)
	image.set_pixel(24, 24, Color.WHITE)
	var path := "res://art/active/vfx/hit_flash_p0.png"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path).get_base_dir())
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save " + path + ": " + error_string(error))
		return false
	print("VFX EXTRACTED V02 -> ", path)
	return true

func _remove_dark_presentation_backdrop(image: Image) -> void:
	# The source is a showcase render on a near-black gradient, while the game
	# needs per-pixel transparency. Bright material and its soft coloured glow
	# are retained; dark unlit backdrop pixels become alpha 0. The threshold is
	# deliberately conservative so the medical cross and pale projectile cores
	# remain crisp after nearest-neighbour reduction.
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			var maximum := maxf(pixel.r, maxf(pixel.g, pixel.b))
			var minimum := minf(pixel.r, minf(pixel.g, pixel.b))
			var saturation := maximum - minimum
			var alpha := 0.0
			if maximum > 0.31:
				alpha = clampf((maximum - 0.27) / 0.36, 0.0, 1.0)
				# Retain saturated coloured rim pixels a little more strongly than
				# neutral ambient haze, without turning the old black board into a box.
				if saturation > 0.42:
					alpha = maxf(alpha, clampf((maximum - 0.25) / 0.30, 0.0, 1.0))
			pixel.a = alpha
			image.set_pixel(x, y, pixel)

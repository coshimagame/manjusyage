extends RefCounted

const SMALL = preload("res://art/fonts/PixelMplus10-Regular.ttf")
const STANDARD = preload("res://art/fonts/PixelMplus12-Regular.ttf")

static func native_size(requested: int) -> int:
	if requested <= 10:
		return 10
	if requested <= 17:
		return 12
	if requested <= 21:
		return 20
	if requested <= 27:
		return 24
	return maxi(24, roundi(requested / 12.0) * 12)

static func font_at(size: int) -> Font:
	return SMALL if size in [10, 20] else STANDARD

static func draw(canvas: CanvasItem, font_size: int, pos: Vector2, message: String, color: Color) -> void:
	var size := native_size(font_size)
	canvas.draw_string(font_at(size), pos.round(), message, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

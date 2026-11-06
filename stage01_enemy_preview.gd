extends Node2D
## Canon-aligned STAGE 01 enemy silhouette preview. All three are proposals (ENEMIES.md).
## Safe isolated scene; does not replace the existing gameplay enemies or PNGs.
## Intended 640x360 viewport. Fallback vector artwork, NOT approved final sprites.
const ENEMY_IDS := ["E-101", "E-102", "E-103"]
const ENEMY_NAMES := ["脈動虫", "縫合蜂", "器官砲台"]
const INK := Color("#160e20")
const TISSUE := Color("#b73b59")
const LIGHT := Color("#ff9d88")
const VEIN := Color("#682647")
const GOLD := Color("#f0b86c")

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#0b1021"))
	draw_string(ThemeDB.fallback_font, Vector2(22, 32), "STAGE 01 / RED ECHO / PROVISIONAL ENEMIES", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#f2d8cb"))
	for index in range(3):
		var center := Vector2(110 + 210 * index, 165)
		draw_rect(Rect2(center.x - 91, 65, 182, 237), Color("#1c172b"))
		draw_rect(Rect2(center.x - 91, 65, 182, 2), GOLD)
		match index:
			0: _pulse_worm(center)
			1: _suture_wasp(center)
			2: _organ_turret(center)
		draw_string(ThemeDB.fallback_font, center + Vector2(-62, 88), ENEMY_IDS[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, GOLD)
		draw_string(ThemeDB.fallback_font, center + Vector2(-62, 110), ENEMY_NAMES[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(20, 332), "DRAFT / Not approved sprites / Existing gameplay preserved", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c4b3c7"))

func _pulse_worm(c: Vector2) -> void:
	# Segmented living immune creature; curved body rather than a generic aircraft.
	for i in range(5):
		var p := c + Vector2((i - 2) * 20, sin(float(i) * 0.9) * 17)
		draw_circle(p, 20 - abs(i - 2) * 2, INK)
		draw_circle(p, 16 - abs(i - 2) * 2, TISSUE)
		draw_arc(p, 11, -0.8, 1.6, 12, LIGHT, 3)
	draw_circle(c + Vector2(48, -13), 6, GOLD)
	draw_line(c + Vector2(52, -9), c + Vector2(67, -2), VEIN, 3)

func _suture_wasp(c: Vector2) -> void:
	# Surgical repair insect: needle, membrane wings, suturing clamps.
	var wing_l := PackedVector2Array([c + Vector2(-8, -10), c + Vector2(-64, -55), c + Vector2(-47, 2)])
	var wing_r := PackedVector2Array([c + Vector2(8, -10), c + Vector2(64, -55), c + Vector2(47, 2)])
	draw_colored_polygon(wing_l, Color("#a96987"))
	draw_colored_polygon(wing_r, Color("#a96987"))
	draw_circle(c, 24, INK)
	draw_circle(c, 19, TISSUE)
	draw_circle(c + Vector2(0, -5), 8, LIGHT)
	draw_line(c + Vector2(0, 18), c + Vector2(0, 70), GOLD, 5)
	draw_line(c + Vector2(-17, 6), c + Vector2(-38, 25), VEIN, 5)
	draw_line(c + Vector2(17, 6), c + Vector2(38, 25), VEIN, 5)

func _organ_turret(c: Vector2) -> void:
	# Stationary heart-world organ: anchored tissue and a pulsing muzzle.
	for side in [-1, 1]:
		var offset := float(side)
		draw_line(c + Vector2(offset * 15, 10), c + Vector2(offset * 58, 63), VEIN, 10)
		draw_line(c + Vector2(offset * 35, 40), c + Vector2(offset * 71, 37), TISSUE, 6)
	draw_circle(c, 39, INK)
	draw_circle(c, 34, VEIN)
	draw_circle(c, 25, TISSUE)
	draw_circle(c, 15, LIGHT)
	draw_circle(c, 7, Color("#fff2cc"))
	draw_arc(c, 31, 0.3, 2.7, 24, GOLD, 3)

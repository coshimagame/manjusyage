extends RefCounted
## Stage 1 reusable enemy-bullet pattern generator.
## Gameplay data only: never changes approved sprite art or collision shapes.
## All coordinates use the existing 640x360 gameplay space.
## Each bullet record has pos (Vector2), vel (Vector2), kind (String).
## Caller owns lifetime, damage, collisions, rendering and difficulty scaling.

const DEFAULT_SPEED := 115.0
const MAX_BULLETS := 96

static func aimed(origin: Vector2, target: Vector2, speed: float = DEFAULT_SPEED) -> Array[Dictionary]:
	var direction := (target - origin).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.LEFT
	return [{"pos": origin, "vel": direction * maxf(speed, 1.0), "kind": "petal"}]

static func fan(origin: Vector2, target: Vector2, count: int = 7, spread_degrees: float = 72.0, speed: float = DEFAULT_SPEED) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var n := clampi(count, 1, MAX_BULLETS)
	var base := (target - origin).angle() if target != origin else PI
	for i in range(n):
		var t := 0.5 if n == 1 else float(i) / float(n - 1)
		var angle := base + deg_to_rad(spread_degrees) * (t - 0.5)
		result.append({"pos": origin, "vel": Vector2.RIGHT.rotated(angle) * maxf(speed, 1.0), "kind": "petal"})
	return result

static func ring_with_gap(origin: Vector2, count: int = 18, gap_angle: float = PI, gap_width: float = 0.55, speed: float = 90.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var n := clampi(count, 3, MAX_BULLETS)
	for i in range(n):
		var angle := TAU * float(i) / float(n)
		var distance := absf(wrapf(angle - gap_angle, -PI, PI))
		if distance < maxf(gap_width, 0.0) * 0.5:
			continue
		result.append({"pos": origin, "vel": Vector2.RIGHT.rotated(angle) * maxf(speed, 1.0), "kind": "ring"})
	return result

static func spiral(origin: Vector2, phase: float, arms: int = 3, speed: float = 95.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(clampi(arms, 1, 12)):
		var angle := phase + TAU * float(i) / float(clampi(arms, 1, 12))
		result.append({"pos": origin, "vel": Vector2.RIGHT.rotated(angle) * maxf(speed, 1.0), "kind": "spiral"})
	return result

static func crossing_waves(left_origin: Vector2, right_origin: Vector2, phase: float, speed: float = 105.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(5):
		var offset := float(i - 2) * 0.11 + sin(phase) * 0.12
		result.append({"pos": left_origin, "vel": Vector2.RIGHT.rotated(offset) * maxf(speed, 1.0), "kind": "wave"})
		result.append({"pos": right_origin, "vel": Vector2.LEFT.rotated(-offset) * maxf(speed, 1.0), "kind": "wave"})
	return result

static func bloom(origin: Vector2, phase: float, petals: int = 8, speed: float = 100.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var n := clampi(petals, 3, 24)
	for i in range(n):
		var angle := phase + TAU * float(i) / float(n)
		var offset := Vector2.RIGHT.rotated(angle) * 6.0
		result.append({"pos": origin + offset, "vel": Vector2.RIGHT.rotated(angle) * maxf(speed, 1.0), "kind": "bloom"})
	return result

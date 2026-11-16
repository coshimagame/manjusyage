extends RefCounted
## 第1面用の敵弾パターン。生成する辞書は game.gd の shots と同じ
## {pos: Vector2, vel: Vector2, r: int} 形式。ゲーム本編への接続は別PR。
## 見た目・当たり判定の既存仕様を変更しない純粋な生成関数。

const MAX_BULLETS := 32

static func aimed(origin: Vector2, target: Vector2, speed: float = 90.0) -> Array[Dictionary]:
	var direction := (target - origin).normalized()
	if direction.length_squared() < 0.01:
		direction = Vector2.LEFT
	return [{"pos": origin, "vel": direction * maxf(1.0, speed), "r": 3}]

static func fan(origin: Vector2, direction: float, count: int = 5, spread: float = 0.8, speed: float = 86.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var n := clampi(count, 1, MAX_BULLETS)
	for i in range(n):
		var t := 0.0 if n == 1 else float(i) / float(n - 1) - 0.5
		result.append({"pos": origin, "vel": Vector2.from_angle(direction + t * spread) * maxf(speed, 1.0), "r": 3})
	return result

static func ring_gap(origin: Vector2, gap_direction: float, count: int = 12, speed: float = 75.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var n := clampi(count, 4, MAX_BULLETS)
	for i in range(n):
		var angle := TAU * float(i) / float(n)
		if absf(wrapf(angle - gap_direction, -PI, PI)) < TAU / float(n) * 1.6:
			continue
		result.append({"pos": origin, "vel": Vector2.from_angle(angle) * maxf(speed, 1.0), "r": 3})
	return result

static func spiral(origin: Vector2, phase: float, arms: int = 3, speed: float = 82.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(clampi(arms, 1, 8)):
		result.append({"pos": origin, "vel": Vector2.from_angle(phase + TAU * float(i) / float(clampi(arms, 1, 8))) * maxf(speed, 1.0), "r": 3})
	return result

static func crossing(origin: Vector2, phase: float, speed: float = 85.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for offset in [-0.38, -0.19, 0.19, 0.38]:
		result.append({"pos": origin, "vel": Vector2.from_angle(PI + sin(phase) * 0.12 + offset) * maxf(speed, 1.0), "r": 3})
	return result

static func bloom(origin: Vector2, phase: float, speed: float = 78.0) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for ring in range(2):
		for i in range(6):
			var angle := phase + TAU * float(i) / 6.0 + float(ring) * PI / 6.0
			result.append({"pos": origin, "vel": Vector2.from_angle(angle) * maxf(speed + ring * 16.0, 1.0), "r": 3})
	return result

extends Node2D
## Erii/Marii standalone boss prototype. Run res://erii_marii_test.tscn in Godot.
## Provisional geometric ship graphics; never replaces approved pilot artwork.
const W := 640
const H := 360
var player := Vector2(110, 180)
var player_hp := 5
var elapsed := 0.0
var cooldown := 0.0
var shot_clock := 0.0
var enemy_bullets: Array[Dictionary] = []
var friendly_bullets: Array[Vector2] = []
var erii_hp := 90.0
var marii_hp := 90.0
var combined_hp := 110.0
var phase := 0
var cleared := false
var lost := false
var invulnerable := 0.0

func _ready() -> void:
	queue_redraw()

func _process(dt: float) -> void:
	if cleared or lost:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()
		queue_redraw()
		return
	elapsed += dt
	invulnerable = maxf(0.0, invulnerable - dt)
	var movement := Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A): movement.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): movement.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W): movement.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S): movement.y += 1
	player = (player + movement.normalized() * 175 * dt).clamp(Vector2(18, 48), Vector2(420, 332))
	shot_clock -= dt
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_Z)) and shot_clock <= 0:
		shot_clock = 0.12
		friendly_bullets.append(player + Vector2(16, 0))
	for i in range(friendly_bullets.size() - 1, -1, -1):
		friendly_bullets[i].x += 380 * dt
		var b := friendly_bullets[i]
		var hit := false
		if phase < 2:
			if erii_hp > 0 and b.distance_to(_ship_pos(0)) < 26:
				erii_hp -= 1
				hit = true
			elif marii_hp > 0 and b.distance_to(_ship_pos(1)) < 26:
				marii_hp -= 1
				hit = true
		elif b.distance_to(Vector2(490, 180)) < 42:
			combined_hp -= 1
			hit = true
		if hit or b.x > W:
			friendly_bullets.remove_at(i)
	if phase == 0 and (erii_hp < 55 or marii_hp < 55 or elapsed > 20):
		phase = 1
	if phase == 1 and (erii_hp <= 0 or marii_hp <= 0):
		phase = 2
		enemy_bullets.clear()
	if phase == 2 and combined_hp <= 0:
		cleared = true
	cooldown -= dt
	if cooldown <= 0 and not cleared:
		cooldown = 1.15 if phase == 0 else (0.82 if phase == 1 else 0.65)
		_emit_attack()
	for i in range(enemy_bullets.size() - 1, -1, -1):
		var b: Dictionary = enemy_bullets[i]
		b.pos += b.vel * dt
		enemy_bullets[i] = b
		if b.pos.distance_to(player) < 10 and invulnerable <= 0:
			player_hp -= 1
			invulnerable = 1.25
			enemy_bullets.remove_at(i)
			if player_hp <= 0: lost = true
		elif b.pos.x < -15 or b.pos.x > W + 15 or b.pos.y < 30 or b.pos.y > H + 15:
			enemy_bullets.remove_at(i)
	queue_redraw()

func _ship_pos(which: int) -> Vector2:
	return Vector2(493 + sin(elapsed * 0.8 + which) * 15, (111 if which == 0 else 247) + sin(elapsed * 1.4 + which * 2) * 30)

func _bullet(origin: Vector2, velocity: Vector2, tint: Color) -> void:
	if enemy_bullets.size() < 180:
		enemy_bullets.append({"pos": origin, "vel": velocity, "color": tint})

func _emit_attack() -> void:
	if phase == 2:
		var center := Vector2(490, 180)
		for i in range(18):
			var angle := elapsed * 0.7 + float(i) * TAU / 18
			_bullet(center, Vector2.from_angle(angle) * 105, Color("#ffa0df") if i % 2 else Color("#8ddaff"))
		return
	for which in range(2):
		if (which == 0 and erii_hp <= 0) or (which == 1 and marii_hp <= 0):
			continue
		var origin := _ship_pos(which)
		var tint := Color("#76caff") if which == 0 else Color("#ff6aa4")
		var aim := (player - origin).angle()
		var spread := 5 if phase == 0 else 7
		for j in range(spread):
			var angle := aim + (j - (spread - 1) * 0.5) * (0.17 if which == 0 else 0.24)
			_bullet(origin, Vector2.from_angle(angle) * (95 if which == 0 else 125), tint)
		if phase == 1:
			for j in range(5):
				_bullet(origin, Vector2(-90, (j - 2) * 35), tint)

func _ship(pos: Vector2, tint: Color, flip: bool = false) -> void:
	var outline := PackedVector2Array([
		pos + Vector2(-30, 0), pos + Vector2(-8, -10),
		pos + Vector2(6, -26), pos + Vector2(14, -8),
		pos + Vector2(30, 0), pos + Vector2(14, 8),
		pos + Vector2(6, 26), pos + Vector2(-8, 10)])
	draw_colored_polygon(outline, Color("#18213e"))
	draw_polyline(outline, tint, 3, true)
	draw_circle(pos + Vector2(5, 0), 7, Color("#fdf0c5"))
	draw_line(pos + Vector2(-19, -5), pos + Vector2(-19, 5), tint.lightened(0.4), 3)
	if flip:
		draw_arc(pos, 35, -PI * 0.4, PI * 0.4, 12, tint, 2)

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#090f25"))
	for i in range(65):
		var x := fposmod(i * 113.0 - elapsed * (10 + i % 3 * 10), W)
		draw_rect(Rect2(x, 36 + (i * 47) % 300, 2, 2), Color("#5a5b87"))
	draw_rect(Rect2(0, 0, W, 34), Color("#19172d"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 22), "ERII & MARII  |  BOSS PROTOTYPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 351), "ARROWS / WASD: MOVE    Z / SPACE: FIRE    R: RESTART", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c3bedc"))
	if phase < 2:
		if erii_hp > 0: _ship(_ship_pos(0), Color("#69bbff"), true)
		if marii_hp > 0: _ship(_ship_pos(1), Color("#ff619e"))
		draw_rect(Rect2(405, 38, maxf(0, erii_hp) * 2, 4), Color("#69bbff"))
		draw_rect(Rect2(405, 46, maxf(0, marii_hp) * 2, 4), Color("#ff619e"))
	else:
		_ship(Vector2(490, 158), Color("#69bbff"), true)
		_ship(Vector2(490, 202), Color("#ff619e"))
		draw_circle(Vector2(490, 180), 13, Color("#ffe2fa"))
		draw_rect(Rect2(405, 38, maxf(0, combined_hp) * 1.6, 6), Color("#f2a1ff"))
	for b in enemy_bullets:
		draw_circle(b.pos, 4, b.color)
	for b in friendly_bullets:
		draw_rect(Rect2(b.x, b.y - 2, 10, 4), Color("#fff2c1"))
	if invulnerable <= 0 or int(elapsed * 15) % 2 == 0:
		_ship(player, Color("#ffe7a4"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 54), "HP: %d   PHASE: %d" % [player_hp, phase + 1], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	if cleared or lost:
		draw_rect(Rect2(140, 135, 360, 90), Color("#18172e"))
		draw_string(ThemeDB.fallback_font, Vector2(196, 178), "BOSS CLEAR!" if cleared else "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#fff0d5"))
		draw_string(ThemeDB.fallback_font, Vector2(250, 205), "PRESS R", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

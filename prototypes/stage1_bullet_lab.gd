extends Node2D
## Experimental stage-1 bullet-pattern playground. All art is procedural and provisional.
## Run scene directly. No save, approved sprites, or existing gameplay is modified.
const WIDTH := 640.0
const HEIGHT := 360.0
const PATTERNS := ["PETAL FAN", "SPIRAL", "AIMED BURST", "RING", "CROSSWAVE", "BLOOM"]
const SHOT_COLOR := Color(1.0, 0.42, 0.38)
var player := Vector2(110, 180)
var shots: Array[Dictionary] = []
var elapsed := 0.0
var next_fire := 0.0
var phase := 0
var health := 5
var invulnerable := 0.0
var score := 0
var running := true

func _ready() -> void:
	set_process(true)
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_restart()
		elif event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]:
			phase = event.keycode - KEY_1
			shots.clear()
			next_fire = 0.0
		elif event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://main.tscn")
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START:
			_restart()

func _restart() -> void:
	player = Vector2(110, 180)
	shots.clear()
	elapsed = 0.0
	next_fire = 0.0
	phase = 0
	health = 5
	invulnerable = 0.0
	score = 0
	running = true

func _physics_process(delta: float) -> void:
	if not running:
		queue_redraw()
		return
	elapsed += delta
	invulnerable = maxf(0.0, invulnerable - delta)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0
	if Input.is_key_pressed(KEY_W): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S): direction.y += 1.0
	if direction.length_squared() > 1.0: direction = direction.normalized()
	player += direction * 165.0 * delta
	player = player.clamp(Vector2(12, 20), Vector2(628, 338))
	if elapsed >= next_fire:
		_emit_pattern()
		next_fire = elapsed + 1.15
	if elapsed > float(phase + 1) * 12.0 and phase < PATTERNS.size() - 1:
		phase += 1
		shots.clear()
	for i in range(shots.size() - 1, -1, -1):
		var shot := shots[i]
		shot["pos"] = shot["pos"] + shot["velocity"] * delta
		if shot["pos"].x < -25 or shot["pos"].x > 665 or shot["pos"].y < -25 or shot["pos"].y > 385:
			shots.remove_at(i)
			continue
		if invulnerable <= 0.0 and shot["pos"].distance_squared_to(player) < 72.25:
			health -= 1
			invulnerable = 1.2
			shots.remove_at(i)
			if health <= 0: running = false
	score += int(delta * 100.0)
	queue_redraw()

func _add_bullet(origin: Vector2, angle: float, speed: float, radius: float = 3.0) -> void:
	shots.append({"pos": origin, "velocity": Vector2.from_angle(angle) * speed, "radius": radius})
	# Bound work and draw cost for web/mobile testing.
	if shots.size() > 240:
		shots.remove_at(0)

func _emit_pattern() -> void:
	var origin := Vector2(542, 180 + sin(elapsed * 0.8) * 75.0)
	var aim := (player - origin).angle()
	match phase:
		0: # Petal fan: clearly spaced lanes.
			for i in range(9):
				_add_bullet(origin, PI + (float(i) - 4.0) * 0.16, 105.0)
		1: # Alternating spiral arms.
			for i in range(12):
				_add_bullet(origin, elapsed * 0.75 + float(i) * TAU / 12.0, 82.0)
		2: # Aimed burst with a visible safe side.
			for i in range(5):
				_add_bullet(origin, aim + (float(i) - 2.0) * 0.14, 128.0)
		3: # Ring with an open sector, not an unavoidable full circle.
			for i in range(18):
				if i >= 7 and i <= 10: continue
				_add_bullet(origin, float(i) * TAU / 18.0, 87.0)
		4: # Crosswave, each group has a gap.
			for i in range(8):
				if i == 3 or i == 4: continue
				_add_bullet(origin, PI + (float(i) - 3.5) * 0.22, 115.0)
		5: # Bloom: two offset fans with a navigable gap.
			for i in range(8):
				if i == 3 or i == 4: continue
				_add_bullet(origin, PI + (float(i) - 3.5) * 0.18, 100.0)
				_add_bullet(origin, PI + (float(i) - 3.5) * 0.18 + 0.06, 70.0)

func _draw() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("090e22"))
	for layer in range(3):
		for i in range(36):
			var x := fposmod(float(i * 113 + layer * 67) - elapsed * (7.0 + layer * 11.0), WIDTH)
			var y := fposmod(float(i * 71 + layer * 41), HEIGHT)
			draw_rect(Rect2(x, y, 1 + layer / 2, 1 + layer / 2), Color(0.5, 0.7, 0.9, 0.3 + layer * 0.18))
	# Provisional enemy silhouette; never substitute for an approved boss sprite.
	var enemy := Vector2(542, 180 + sin(elapsed * 0.8) * 75.0)
	draw_colored_polygon(PackedVector2Array([enemy + Vector2(-20, 0), enemy + Vector2(0, -16), enemy + Vector2(22, 0), enemy + Vector2(0, 16)]), Color("714257"))
	draw_circle(enemy, 5.0, Color("ffc9b1"))
	for shot in shots:
		var pos: Vector2 = shot["pos"]
		var radius: float = shot["radius"]
		draw_circle(pos, radius + 2.0, Color(1.0, 0.2, 0.35, 0.20))
		draw_circle(pos, radius, SHOT_COLOR)
		draw_circle(pos, 1.0, Color("fff3d2"))
	if invulnerable <= 0.0 or int(elapsed * 12.0) % 2 == 0:
		draw_colored_polygon(PackedVector2Array([player + Vector2(12, 0), player + Vector2(-9, -7), player + Vector2(-5, 0), player + Vector2(-9, 7)]), Color("9fe7ed"))
		draw_circle(player, 2.0, Color("fff6cb"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 22), "STAGE 1 / BULLET LAB - PROVISIONAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f0e9dc"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 43), "PATTERN %d/6: %s" % [phase + 1, PATTERNS[phase]], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffb9ad"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 62), "HP %d   SCORE %d   BULLETS %d" % [health, score, shots.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("a8e4ef"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 347), "ARROWS/WASD MOVE   1-6 PATTERN   R RESTART   ESC TITLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("c5d2e3"))
	if not running:
		draw_rect(Rect2(145, 134, 350, 82), Color("10182d"))
		draw_string(ThemeDB.fallback_font, Vector2(222, 168), "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("ffacb1"))
		draw_string(ThemeDB.fallback_font, Vector2(205, 194), "PRESS R TO RETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f3e5cb"))

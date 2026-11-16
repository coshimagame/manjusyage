extends Node2D
## Independent Stage 1 enemy-wave combat lab. Provisional visuals; does not replace approved PNGs.
## Run res://prototypes/stage1_enemy_wave_lab.tscn as the current scene.
const W := 640.0
const H := 360.0
const PLAYER_SPEED := 190.0
const SHOT_SPEED := 360.0
const MAX_BULLETS := 180
var player := Vector2(320, 300)
var hp := 5
var score := 0
var clock := 0.0
var spawn_clock := 0.0
var shoot_clock := 0.0
var invulnerable := 0.0
var enemy_id := 0
var enemies: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var shots: Array[Vector2] = []
var touch_target := Vector2.ZERO
var touch_active := false
var finished := false

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if finished:
		queue_redraw()
		return
	var dt: float = minf(delta, 0.05)
	clock += dt
	invulnerable = maxf(0.0, invulnerable - dt)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if touch_active:
		var offset := touch_target - player
		direction = offset.normalized() if offset.length() > 4.0 else Vector2.ZERO
	player += direction * PLAYER_SPEED * dt
	player = player.clamp(Vector2(15, 30), Vector2(W - 15, H - 15))
	shoot_clock -= dt
	if shoot_clock <= 0.0:
		shoot_clock = 0.14
		shots.append(player + Vector2(0, -13))
	for i in range(shots.size() - 1, -1, -1):
		shots[i].y -= SHOT_SPEED * dt
		if shots[i].y < -12:
			shots.remove_at(i)
	spawn_clock -= dt
	if spawn_clock <= 0.0:
		spawn_clock = 1.25
		_spawn_enemy()
	for i in range(enemies.size() - 1, -1, -1):
		var e: Dictionary = enemies[i]
		e["age"] = float(e["age"]) + dt
		var age: float = e["age"]
		var pos: Vector2 = e["pos"]
		match int(e["kind"]):
			0:
				pos += Vector2(sin(age * 3.0) * 35.0, 46.0) * dt
			1:
				pos += Vector2(cos(age * 2.0) * 65.0, 30.0) * dt
			_:
				pos += Vector2(sin(age * 1.5) * 15.0, 22.0) * dt
		e["pos"] = pos
		e["fire"] = float(e["fire"]) - dt
		if float(e["fire"]) <= 0.0:
			e["fire"] = 1.2 if int(e["kind"]) != 2 else 0.8
			_fire_pattern(pos, int(e["kind"]), age)
		var killed := false
		for j in range(shots.size() - 1, -1, -1):
			if pos.distance_squared_to(shots[j]) < 225.0:
				shots.remove_at(j)
				e["hp"] = int(e["hp"]) - 1
				if int(e["hp"]) <= 0:
					killed = true
					break
		if killed or pos.y > H + 20.0:
			if killed:
				score += 100 * (int(e["kind"]) + 1)
			enemies.remove_at(i)
		else:
			enemies[i] = e
	for i in range(bullets.size() - 1, -1, -1):
		var bullet: Dictionary = bullets[i]
		var velocity: Vector2 = bullet["velocity"]
		var pos: Vector2 = bullet["pos"]
		pos += velocity * dt
		bullet["pos"] = pos
		if pos.x < -15 or pos.x > W + 15 or pos.y > H + 15 or pos.y < -15:
			bullets.remove_at(i)
			continue
		if invulnerable <= 0.0 and pos.distance_squared_to(player) < 85.0:
			hp -= 1
			invulnerable = 1.0
			bullets.remove_at(i)
			if hp <= 0:
				finished = true
		else:
			bullets[i] = bullet
	queue_redraw()

func _spawn_enemy() -> void:
	var kind := enemy_id % 3
	var x := 80.0 + float((enemy_id * 137) % 480)
	enemies.append({"pos": Vector2(x, -12), "kind": kind, "hp": 2 + kind * 2, "fire": 0.7, "age": 0.0})
	enemy_id += 1

func _fire_pattern(origin: Vector2, kind: int, age: float) -> void:
	if bullets.size() >= MAX_BULLETS:
		return
	match kind:
		0: # aimed three-way petal spread
			var angle := (player - origin).angle()
			for offset in [-0.25, 0.0, 0.25]:
				_add_bullet(origin, Vector2.RIGHT.rotated(angle + offset) * 98.0, 0)
		1: # rotating fan, six projectiles
			for i in range(6):
				var angle := age * 1.8 + float(i) * TAU / 6.0
				_add_bullet(origin, Vector2.RIGHT.rotated(angle) * 75.0, 1)
		2: # falling lattice, alternate safe gaps
			var gap := (enemy_id / 3) % 5
			for i in range(7):
				if i == gap or i == gap + 1:
					continue
				_add_bullet(Vector2(55 + i * 88, origin.y), Vector2(0, 82), 2)

func _add_bullet(origin: Vector2, velocity: Vector2, kind: int) -> void:
	if bullets.size() < MAX_BULLETS:
		bullets.append({"pos": origin, "velocity": velocity, "kind": kind})

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_active = event.pressed
		if touch_active:
			touch_target = event.position * Vector2(W / get_viewport_rect().size.x, H / get_viewport_rect().size.y)
	elif event is InputEventScreenDrag:
		touch_active = true
		touch_target = event.position * Vector2(W / get_viewport_rect().size.x, H / get_viewport_rect().size.y)
	elif event.is_action_pressed("ui_accept") and finished:
		get_tree().reload_current_scene()

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#091327"))
	for i in range(30):
		var y := fposmod(float(i * 47) + clock * (8.0 + i % 3 * 7), H)
		draw_circle(Vector2(float((i * 109) % 640), y), 1.0, Color("#344d74"))
	for e in enemies:
		var pos: Vector2 = e["pos"]
		var kind: int = e["kind"]
		var colors := [Color("#e95367"), Color("#b98ae8"), Color("#71d6d0")]
		draw_colored_polygon(PackedVector2Array([pos + Vector2(0,-13), pos + Vector2(13,0), pos + Vector2(0,13), pos + Vector2(-13,0)]), colors[kind])
		draw_circle(pos, 4, Color("#fff1c2"))
	for bullet in bullets:
		var pos: Vector2 = bullet["pos"]
		match int(bullet["kind"]):
			0:
				draw_colored_polygon(PackedVector2Array([pos + Vector2(0,-6), pos + Vector2(4,0), pos + Vector2(0,6), pos + Vector2(-4,0)]), Color("#ff7789"))
			1:
				draw_arc(pos, 5, 0, TAU, 10, Color("#e0a9ff"), 2)
			_:
				draw_circle(pos, 4, Color("#ffd36b"))
	for shot in shots:
		draw_line(shot, shot + Vector2(0, 10), Color("#8ff6ff"), 2)
	if invulnerable <= 0.0 or int(clock * 12) % 2 == 0:
		draw_colored_polygon(PackedVector2Array([player + Vector2(0,-13), player + Vector2(9,9), player, player + Vector2(-9,9)]), Color("#d8f4ff"))
		draw_circle(player, 2, Color("#ffdc75"))
	draw_rect(Rect2(0, 0, W, 23), Color("#101d34"))
	draw_string(ThemeDB.fallback_font, Vector2(10, 17), "STAGE 1  ENEMY WAVE LAB", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(400, 17), "HP %d   SCORE %d" % [hp, score], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	if finished:
		draw_rect(Rect2(165, 137, 310, 74), Color("#111c30"))
		draw_string(ThemeDB.fallback_font, Vector2(250, 170), "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#ff8b98"))
		draw_string(ThemeDB.fallback_font, Vector2(240, 192), "ENTER: RETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

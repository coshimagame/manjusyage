extends Node2D
## Isolated stage-2 combat prototype. NOT wired to the campaign or canon.
## Run res://prototypes/stage2_combat.tscn directly in Godot 4.6.
const SIZE := Vector2(640, 360)
var ship := Vector2(96, 180)
var hp := 4
var invulnerability := 0.0
var elapsed := 0.0
var fire_cooldown := 0.0
var spawn_cooldown := 0.0
var bullets: Array[Vector2] = []
var foes: Array[Vector2] = []
var boss_hp := 24
var boss_active := false
var boss_fire_cooldown := 1.0
var enemy_shots: Array[Vector2] = []
var finished := false
var won := false
var paused := false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _process(delta: float) -> void:
	if finished or paused:
		queue_redraw()
		return
	elapsed += delta
	invulnerability = maxf(0.0, invulnerability - delta)
	var axis := Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A): axis.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): axis.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W): axis.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S): axis.y += 1
	if axis == Vector2.ZERO:
		axis = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# First connected controller can steer this single-ship prototype.
	# Deadzone prevents drifting sticks from moving the ship.
	if axis == Vector2.ZERO and not Input.get_connected_joypads().is_empty():
		var device: int = Input.get_connected_joypads()[0]
		var stick := Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
		if stick.length() > 0.22:
			axis = stick
	ship += axis.limit_length(1.0) * 175.0 * delta
	ship = ship.clamp(Vector2(12, 12), SIZE - Vector2(12, 12))
	fire_cooldown -= delta
	var pad_fire := false
	if not Input.get_connected_joypads().is_empty():
		var device: int = Input.get_connected_joypads()[0]
		pad_fire = Input.is_joy_button_pressed(device, JOY_BUTTON_A) or Input.is_joy_button_pressed(device, JOY_BUTTON_X)
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_accept") or pad_fire) and fire_cooldown <= 0:
		bullets.append(ship + Vector2(12, 0))
		fire_cooldown = 0.16
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i] = bullets[i] + Vector2(320.0 * delta, 0)
		if bullets[i].x > SIZE.x: bullets.remove_at(i)
	if not boss_active and elapsed >= 25.0:
		boss_active = true
		foes.clear()
		boss_fire_cooldown = 1.0
	if not boss_active:
		spawn_cooldown -= delta
		if spawn_cooldown <= 0:
			foes.append(Vector2(650, randf_range(25, 335)))
			spawn_cooldown = 0.85
	for i in range(foes.size() - 1, -1, -1):
		foes[i] = foes[i] - Vector2(105.0 * delta, 0)
		if foes[i].x < -20:
			foes.remove_at(i)
			continue
		if foes[i].distance_to(ship) < 15:
			foes.remove_at(i)
			if invulnerability <= 0.0:
				hp -= 1
				invulnerability = 1.0
				if hp <= 0: finished = true
			continue
		for j in range(bullets.size() - 1, -1, -1):
			if foes[i].distance_to(bullets[j]) < 13:
				bullets.remove_at(j)
				foes.remove_at(i)
				break
	if boss_active:
		var boss_pos := Vector2(550, 180 + sin(elapsed * 1.8) * 90)
		boss_fire_cooldown -= delta
		if boss_fire_cooldown <= 0.0:
			enemy_shots.append(boss_pos + Vector2(-30, 0))
			boss_fire_cooldown = 0.75
		for i in range(enemy_shots.size() - 1, -1, -1):
			enemy_shots[i] += Vector2(-180.0 * delta, 0)
			if enemy_shots[i].x < -10.0:
				enemy_shots.remove_at(i)
				continue
			if enemy_shots[i].distance_to(ship) < 12.0:
				enemy_shots.remove_at(i)
				if invulnerability <= 0.0:
					hp -= 1
					invulnerability = 1.0
					if hp <= 0: finished = true
		for j in range(bullets.size() - 1, -1, -1):
			if bullets[j].distance_to(boss_pos) < 30:
				bullets.remove_at(j)
				boss_hp -= 1
				if boss_hp <= 0:
					finished = true
					won = true
		if not finished and ship.distance_to(boss_pos) < 36 and invulnerability <= 0.0:
			hp -= 1
			invulnerability = 1.0
			if hp <= 0: finished = true
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P or event.keycode == KEY_ESCAPE:
			if not finished:
				paused = not paused
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R and finished:
			get_tree().reload_current_scene()
			get_viewport().set_input_as_handled()
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START and not finished:
			paused = not paused
			get_viewport().set_input_as_handled()
		elif event.button_index == JOY_BUTTON_B and finished:
			get_tree().reload_current_scene()
			get_viewport().set_input_as_handled()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#071329"))
	for i in range(24):
		var x := fposmod(float(i * 89) - elapsed * 24.0, 640.0)
		draw_circle(Vector2(x, float((i * 53) % 360)), 1.0, Color("#4b7591"))
	if invulnerability <= 0.0 or int(elapsed * 12.0) % 2 == 0:
		draw_colored_polygon(PackedVector2Array([ship + Vector2(14, 0), ship + Vector2(-11, -9), ship + Vector2(-6, 0), ship + Vector2(-11, 9)]), Color("#f04f5e"))
	for p in bullets: draw_rect(Rect2(p - Vector2(2, 1), Vector2(9, 3)), Color("#b7faff"))
	for p in enemy_shots:
		draw_circle(p, 4.0, Color("#ffb36c"))
	for p in foes:
		draw_circle(p, 11, Color("#a43c71"))
		draw_circle(p, 5, Color("#f6b2ca"))
	if boss_active and not won:
		var center := Vector2(550, 180 + sin(elapsed * 1.8) * 90)
		draw_circle(center, 29, Color("#8b244d"))
		draw_circle(center, 17, Color("#f16487"))
		draw_circle(center, 8, Color("#fff0c6"))
		draw_rect(Rect2(Vector2(425, 10), Vector2(float(boss_hp) / 24.0 * 195.0, 5)), Color("#f16487"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 20), "STAGE 02 / PROTOTYPE - HP %d" % hp, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 342), "MOVE: WASD / ARROWS / PAD LEFT STICK    FIRE: SPACE / PAD A,X", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#b7d5e5"))
	if paused and not finished:
		draw_rect(Rect2(160, 140, 320, 78), Color("#09111e"))
		draw_string(ThemeDB.fallback_font, Vector2(205, 175), "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(185, 201), "P / ESC / START: RESUME", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	if finished:
		draw_rect(Rect2(150, 130, 340, 100), Color("#09111e"))
		draw_string(ThemeDB.fallback_font, Vector2(185, 175), "CLEAR" if won else "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(185, 208), "R / PAD B: RETRY (NO SAVE)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

extends Node2D
# Stage 2 standalone playable prototype. Not wired into the stage-one flow.
# All visuals are temporary procedural shapes; no approved art is replaced.
const SIZE := Vector2(640, 360)
var ship := Vector2(90, 180)
var shots: Array[Vector2] = []
var foes: Array[Dictionary] = []
var elapsed := 0.0
var spawn_timer := 0.0
var hp := 5
var boss_hp := 20
var boss_active := false
var finished := false
var won := false
var fire_cooldown := 0.0
var hit_grace := 0.0
const HIT_GRACE_SECONDS := 1.25
# Touch: left half steers relative to the initial finger position; right half fires.
var touch_anchors: Dictionary = {}
var touch_positions: Dictionary = {}

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_anchors[event.index] = event.position
			touch_positions[event.index] = event.position
		else:
			touch_anchors.erase(event.index)
			touch_positions.erase(event.index)
	elif event is InputEventScreenDrag and touch_anchors.has(event.index):
		touch_positions[event.index] = event.position

func touch_movement() -> Vector2:
	var direction := Vector2.ZERO
	for finger in touch_positions:
		var anchor: Vector2 = touch_anchors[finger]
		if anchor.x < SIZE.x * 0.5:
			direction += ((touch_positions[finger] as Vector2) - anchor) / 45.0
	return direction.limit_length(1.0)

func touch_firing() -> bool:
	for finger in touch_positions:
		if (touch_anchors[finger] as Vector2).x >= SIZE.x * 0.5:
			return true
	return false

func _process(delta: float) -> void:
	if finished:
		queue_redraw()
		return
	elapsed += delta
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	hit_grace = maxf(0.0, hit_grace - delta)
	var movement := (Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") + touch_movement()).limit_length(1.0)
	ship = (ship + movement * delta * 180.0).clamp(Vector2(14, 18), SIZE - Vector2(14, 18))
	var firing := Input.is_key_pressed(KEY_SPACE) or touch_firing()
	for pad in Input.get_connected_joypads():
		firing = firing or Input.is_joy_button_pressed(pad, JOY_BUTTON_A)
	if firing and fire_cooldown <= 0.0:
		shots.append(ship + Vector2(14, 0))
		fire_cooldown = 0.16
	for i in range(shots.size() - 1, -1, -1):
		shots[i].x += 340.0 * delta
		if shots[i].x > SIZE.x:
			shots.remove_at(i)
	spawn_timer -= delta
	if elapsed < 24.0 and spawn_timer <= 0.0:
		spawn_timer = 1.3
		foes.append({"pos": Vector2(660, randf_range(35, 325)), "hp": 2})
	if elapsed >= 24.0 and not boss_active:
		boss_active = true
		foes.clear()
	for i in range(foes.size() - 1, -1, -1):
		var foe: Dictionary = foes[i]
		foe["pos"] = foe["pos"] + Vector2(-75.0 * delta, 0)
		if (foe["pos"] as Vector2).distance_to(ship) < 20.0:
			apply_ship_hit()
			foes.remove_at(i)
		elif (foe["pos"] as Vector2).x < -20:
			foes.remove_at(i)
	if boss_active:
		var boss_pos := Vector2(525, 180 + sin(elapsed * 1.8) * 70)
		if ship.distance_to(boss_pos) < 38.0:
			apply_ship_hit()
		for i in range(shots.size() - 1, -1, -1):
			if shots[i].distance_to(boss_pos) < 39.0:
				shots.remove_at(i)
				boss_hp -= 1
		if boss_hp <= 0:
			finished = true
			won = true
	else:
		for i in range(shots.size() - 1, -1, -1):
			var hit := false
			for j in range(foes.size() - 1, -1, -1):
				if shots[i].distance_to(foes[j]["pos"]) < 17.0:
					foes[j]["hp"] -= 1
					if foes[j]["hp"] <= 0:
						foes.remove_at(j)
				hit = true
					break
			if hit:
				shots.remove_at(i)
	if hp <= 0:
		finished = true
	queue_redraw()

func apply_ship_hit() -> void:
	if hit_grace > 0.0 or finished:
		return
	hp -= 1
	hit_grace = HIT_GRACE_SECONDS

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R and finished:
		get_tree().reload_current_scene()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#091527"))
	for i in range(18):
		var x := fposmod(float(i * 83) - elapsed * 24.0, 640.0)
		draw_circle(Vector2(x, float((i * 59) % 340) + 10), 1.0, Color("#547e9c"))
	if hit_grace <= 0.0 or int(elapsed * 12.0) % 2 == 0:
		draw_circle(ship, 9, Color("#e9d9b7"))
	if hit_grace <= 0.0 or int(elapsed * 12.0) % 2 == 0:
		draw_colored_polygon(PackedVector2Array([ship + Vector2(16, 0), ship + Vector2(-9, -10), ship + Vector2(-9, 10)]), Color("#67dff0"))
	for shot in shots:
		draw_rect(Rect2(shot - Vector2(1, 2), Vector2(11, 4)), Color("#ffe6a6"))
	for foe in foes:
		draw_circle(foe["pos"], 12, Color("#aa5478"))
		draw_circle(foe["pos"], 5, Color("#f1a7b5"))
	if boss_active and not won:
		var p := Vector2(525, 180 + sin(elapsed * 1.8) * 70)
		draw_circle(p, 36, Color("#8c304d"))
		draw_circle(p, 18, Color("#e6a5b0"))
		draw_rect(Rect2(430, 14, 180.0 * maxf(0.0, boss_hp / 20.0), 6), Color("#f05b83"))
	draw_string(ThemeDB.fallback_font, Vector2(15, 23), "STAGE 2 PROTOTYPE / HP " + str(hp), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
	# Low-opacity guidance, not part of the approved game art.
	draw_string(ThemeDB.fallback_font, Vector2(16, 344), "LEFT: MOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#7891a6"))
	draw_string(ThemeDB.fallback_font, Vector2(524, 344), "RIGHT: FIRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#7891a6"))
	if finished:
		draw_string(ThemeDB.fallback_font, Vector2(160, 180), "CLEAR" if won else "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(160, 210), "R: RETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

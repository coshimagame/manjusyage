extends Node2D
## Standalone combat smoke-test for the provisional 100-enemy catalog.
## F6 on scenes/enemy_combat_sandbox.tscn. Does not alter the main game or canon.
const Catalog = preload("res://scripts/enemy_100_catalog.gd")
const SIZE := Vector2(640, 360)
const PLAYER_SPEED := 190.0
const SHOT_SPEED := 320.0
var player_pos := Vector2(90, 180)
var player_hp := 3
var score := 0
var elapsed := 0.0
var spawn_timer := 0.5
var shot_timer := 0.0
var next_enemy := 0
var vertical_scroll := false
var enemies: Array[Dictionary] = []
var shots: Array[Vector2] = []
var invincible := 0.0
var ids: PackedStringArray
var stage := 1
var stage_kills := 0
var boss_spawned := false
var boss_rank_index := 0
var stage_clear := false
const BOSS_RANKS := ["S", "M", "L"]
const KILLS_TO_BOSS := 8

func _ready() -> void:
	_set_stage(1)
	assert(Catalog.validate_catalog(), "Enemy catalog must have 100 unique entries.")
	queue_redraw()

func _process(delta: float) -> void:
	if player_hp <= 0 or stage_clear:
		queue_redraw()
		return
	elapsed += delta
	invincible = maxf(0.0, invincible - delta)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player_pos += direction * PLAYER_SPEED * delta
	player_pos = player_pos.clamp(Vector2(14, 18), SIZE - Vector2(14, 18))
	shot_timer -= delta
	if (Input.is_key_pressed(KEY_Z) or Input.is_action_pressed("ui_accept")) and shot_timer <= 0.0:
		shot_timer = 0.15
		shots.append(player_pos + (Vector2(0, -14) if vertical_scroll else Vector2(14, 0)))
	for i in range(shots.size() - 1, -1, -1):
		shots[i] += (Vector2.UP if vertical_scroll else Vector2.RIGHT) * SHOT_SPEED * delta
		if shots[i].x > SIZE.x or shots[i].y < 0:
			shots.remove_at(i)
	spawn_timer -= delta
	if spawn_timer <= 0.0 and not boss_spawned:
		spawn_timer = 1.2
		var enemy_id := ids[next_enemy % ids.size()]
		next_enemy += 1
		var spawn := Vector2(randf_range(36, 604), -20) if vertical_scroll else Vector2(660, randf_range(36, 324))
		var spec := Catalog.get_enemy(enemy_id)
		enemies.append({"id": enemy_id, "spawn": spawn, "age": 0.0, "hp": int(spec["hp_proposal"])})
	for i in range(enemies.size() - 1, -1, -1):
		var foe := enemies[i]
		foe["age"] = float(foe["age"]) + delta
		var pos := _enemy_pos(foe)
		if pos.x < -45 or pos.x > 690 or pos.y < -65 or pos.y > 415:
			enemies.remove_at(i)
			continue
		var destroyed := false
		for j in range(shots.size() - 1, -1, -1):
			if pos.distance_squared_to(shots[j]) < 200.0:
				shots.remove_at(j)
				foe["hp"] = int(foe["hp"]) - 1
				if int(foe["hp"]) <= 0:
					score += 100
					if String(foe["id"]).begins_with("B"):
						boss_rank_index += 1
						boss_spawned = false
						if boss_rank_index >= BOSS_RANKS.size():
							stage_clear = true
					else:
						stage_kills += 1
					destroyed = true
				break
		if destroyed:
			enemies.remove_at(i)
			continue
		if invincible <= 0.0 and pos.distance_squared_to(player_pos) < 260.0:
			player_hp -= 1
			invincible = 1.2
			enemies.remove_at(i)
	if stage_kills >= KILLS_TO_BOSS and not boss_spawned and not stage_clear:
		boss_spawned = true
		var boss_id := "B%02d-%s" % [stage, BOSS_RANKS[boss_rank_index]]
		var spawn := Vector2(320, -20) if vertical_scroll else Vector2(660, 180)
		enemies.clear()
		var boss_spec := Catalog.get_enemy(boss_id)
		enemies.append({"id": boss_id, "spawn": spawn, "age": 0.0, "hp": int(boss_spec["hp_proposal"])})
	queue_redraw()

func _set_stage(new_stage: int) -> void:
	stage = clampi(new_stage, 1, 8)
	ids.clear()
	for enemy_id in Catalog.all_ids():
		var spec := Catalog.get_enemy(enemy_id)
		if int(spec.get("stage", 0)) == stage and String(spec.get("kind", "")) == "normal":
			ids.append(enemy_id)
	stage_kills = 0
	boss_spawned = false
	boss_rank_index = 0
	stage_clear = false
	next_enemy = 0
	player_hp = 3
	score = 0
	elapsed = 0.0
	spawn_timer = 0.5
	shot_timer = 0.0
	invincible = 0.0
	enemies.clear()
	shots.clear()
	player_pos = Vector2(320, 290) if vertical_scroll else Vector2(90, 180)
	queue_redraw()

func _enemy_pos(foe: Dictionary) -> Vector2:
	var p := Vector2(foe["spawn"]) + Catalog.offset_at(String(foe["id"]), float(foe["age"]), vertical_scroll)
	if String(foe["id"]).begins_with("B"):
		return Vector2(clampf(p.x, 40.0, 600.0), clampf(p.y, 76.0, 290.0)) if vertical_scroll else Vector2(clampf(p.x, 400.0, 510.0), clampf(p.y, 36.0, 324.0))
	return p

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			vertical_scroll = not vertical_scroll
			enemies.clear()
			shots.clear()
			player_pos = Vector2(320, 290) if vertical_scroll else Vector2(90, 180)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R:
			_set_stage(stage)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_N and stage_clear:
			_set_stage(1 if stage == 8 else stage + 1)
			get_viewport().set_input_as_handled()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#0b1524"))
	for x in range(0, 640, 32):
		draw_line(Vector2(x, 0), Vector2(x, 360), Color("#1a3040"), 1.0)
	for y in range(0, 360, 32):
		draw_line(Vector2(0, y), Vector2(640, y), Color("#1a3040"), 1.0)
	if player_hp > 0 and (invincible <= 0.0 or int(elapsed * 12.0) % 2 == 0):
		var tip := Vector2(0, -12) if vertical_scroll else Vector2(12, 0)
		var side := Vector2(10, 7) if vertical_scroll else Vector2(-8, 9)
		draw_colored_polygon(PackedVector2Array([player_pos + tip, player_pos + side, player_pos - side]), Color("#ffe38b"))
	for bullet in shots:
		draw_circle(bullet, 2.5, Color("#8defff"))
	for foe in enemies:
		var p := _enemy_pos(foe)
		var boss := String(foe["id"]).begins_with("B")
		draw_circle(p, 12.0 if boss else 7.0, Color("#f67d93") if boss else Color("#73d8c8"))
		draw_string(ThemeDB.fallback_font, p + Vector2(-13, -13), String(foe["id"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
	var mode := "VERTICAL" if vertical_scroll else "HORIZONTAL"
	draw_string(ThemeDB.fallback_font, Vector2(12, 19), "STAGE " + str(stage) + " / " + Catalog.STAGE_NAMES[stage - 1] + "  " + mode + "  HP " + str(player_hp) + "  SCORE " + str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(12, 347), "ARROWS MOVE  Z/ENTER FIRE  TAB H/V  R RESET  N NEXT AFTER CLEAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#b8d3e7"))
	if boss_spawned and not stage_clear:
		draw_string(ThemeDB.fallback_font, Vector2(12, 39), "BOSS %s / 3" % str(boss_rank_index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ffe38b"))
	if stage_clear:
		draw_string(ThemeDB.fallback_font, Vector2(180, 178), "STAGE CLEAR!  N: NEXT STAGE / R: RETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffe38b"))
	if player_hp <= 0:
		draw_string(ThemeDB.fallback_font, Vector2(250, 178), "GAME OVER - R TO RETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#ffadad"))

extends Node2D
## Stage 2 "追憶の海" standalone playable PROTOTYPE; not approved canon/art.
## Run res://scenes/stage2_combat_prototype.tscn directly in Godot 4.6.
const WIDTH := 640.0
const HEIGHT := 360.0
var pilot := Vector2(90, 180)
var shots: Array[Vector2] = []
var enemies: Array[Dictionary] = []
var enemy_shots: Array[Vector2] = []
var time := 0.0
var spawn_timer := 0.0
var boss_hp := 30
var hp := 4
var invulnerable := 0.0
var phase := "wave"
var wave_kills := 0
var fire_timer := 0.0
var font := SystemFont.new()
# Browser touch: drag the ship with one finger; shoot while held.
var touch_finger := -1
var touch_target := Vector2.ZERO

func _ready() -> void:
	font.font_names = PackedStringArray(["Noto Sans CJK JP", "Yu Gothic", "sans-serif"])
	queue_redraw()

func _process(delta: float) -> void:
	if phase == "won" or phase == "lost":
		queue_redraw()
		return
	time += delta
	invulnerable = maxf(0.0, invulnerable - delta)
	var axis := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if touch_finger >= 0:
		# Smooth tracking prevents teleporting through enemies on first contact.
		pilot = pilot.move_toward(touch_target, delta * 260.0)
	else:
		pilot += axis * delta * 185.0
	pilot = pilot.clamp(Vector2(16, 20), Vector2(610, 338))
	fire_timer -= delta
	if (Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A) or touch_finger >= 0) and fire_timer <= 0.0:
		shots.append(pilot + Vector2(16, 0))
		fire_timer = 0.14
	for i in range(shots.size() - 1, -1, -1):
		shots[i].x += delta * 360.0
		if shots[i].x > WIDTH + 10.0:
			shots.remove_at(i)
	if phase == "wave":
		spawn_timer -= delta
		if spawn_timer <= 0.0 and wave_kills < 15:
			enemies.append({"pos": Vector2(660, 65 + 230 * (0.5 + 0.5 * sin(time * 1.7))), "hp": 2})
			spawn_timer = 0.8
		for i in range(enemies.size() - 1, -1, -1):
			var e: Dictionary = enemies[i]
			e.pos.x -= delta * 95.0
			e.pos.y += sin(time * 3.0 + i) * delta * 15.0
			if e.pos.x < -20:
				enemies.remove_at(i)
				continue
			for j in range(shots.size() - 1, -1, -1):
				if e.pos.distance_to(shots[j]) < 16:
					shots.remove_at(j)
					e.hp -= 1
					if e.hp <= 0:
						enemies.remove_at(i)
						wave_kills += 1
					break
			if e.hp > 0 and i < enemies.size() and pilot.distance_to(enemies[i].pos) < 20:
				_hit()
		if wave_kills >= 15:
			enemies.clear()
			phase = "boss"
	else:
		var boss_pos := Vector2(530, 180 + 55 * sin(time * 0.8))
		for j in range(shots.size() - 1, -1, -1):
			if shots[j].distance_to(boss_pos) < 45:
				shots.remove_at(j)
				boss_hp -= 1
		if boss_hp <= 0:
			phase = "won"
		if phase == "boss" and int(time * 3.0) != int((time - delta) * 3.0):
			enemy_shots.append(boss_pos + Vector2(-36, 0))
	for i in range(enemy_shots.size() - 1, -1, -1):
		enemy_shots[i].x -= delta * 135
		if enemy_shots[i].x < 0:
			enemy_shots.remove_at(i)
		elif enemy_shots[i].distance_to(pilot) < 12:
			enemy_shots.remove_at(i)
			_hit()
	queue_redraw()

func _hit() -> void:
	if invulnerable > 0.0:
		return
	hp -= 1
	invulnerable = 1.2
	if hp <= 0:
		phase = "lost"

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and phase in ["won", "lost"]:
			get_tree().reload_current_scene()
		elif event.pressed and touch_finger == -1:
			touch_finger = event.index
			touch_target = event.position.clamp(Vector2(16, 20), Vector2(610, 338))
		elif not event.pressed and event.index == touch_finger:
			touch_finger = -1
	elif event is InputEventScreenDrag and event.index == touch_finger:
		touch_target = event.position.clamp(Vector2(16, 20), Vector2(610, 338))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()
	elif event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START and phase in ["won", "lost"]:
		get_tree().reload_current_scene()

func _draw() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("#071c35"))
	for i in range(12):
		var x := fposmod(i * 87.0 - time * (14 + i % 3 * 7), WIDTH)
		var y := 36.0 + i * 26.0
		draw_line(Vector2(x, y), Vector2(x + 85, y + sin(time + i) * 5), Color("#276078", 0.5), 2)
	for i in range(6):
		var x := fposmod(i * 150.0 - time * 45.0, 740.0) - 50
		draw_arc(Vector2(x, 180 + sin(time + i) * 55), 18 + i * 5, 0, TAU, 20, Color("#337b94", 0.35), 2)
	if invulnerable <= 0.0 or int(time * 12.0) % 2 == 0:
		draw_colored_polygon(PackedVector2Array([pilot + Vector2(19, 0), pilot + Vector2(-14, -10), pilot + Vector2(-7, 0), pilot + Vector2(-14, 10)]), Color("#f7c46a"))
		draw_rect(Rect2(pilot + Vector2(-10, -3), Vector2(13, 6)), Color("#f6eac8"))
	for p in shots:
		draw_rect(Rect2(p, Vector2(11, 3)), Color("#e4faff"))
	for e in enemies:
		var p: Vector2 = e.pos
		draw_colored_polygon(PackedVector2Array([p + Vector2(-15, 0), p + Vector2(0, -11), p + Vector2(15, 0), p + Vector2(0, 11)]), Color("#6cc8d6"))
		draw_circle(p, 4, Color("#e2ffff"))
	if phase == "boss" or phase == "won":
		var bp := Vector2(530, 180 + 55 * sin(time * 0.8))
		draw_circle(bp, 42, Color("#21586c"))
		draw_arc(bp, 34, 0, TAU, 32, Color("#7ad7d3"), 4)
		draw_circle(bp, 13, Color("#ff8eaa"))
	for p in enemy_shots:
		draw_circle(p, 4, Color("#ff9eaa"))
	draw_string(font, Vector2(15, 24), "STAGE 2 / 追憶の海  [試作]", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(font, Vector2(15, 44), "HP %d  /  撃破 %d/15  /  BOSS %d" % [hp, wave_kills, maxi(boss_hp, 0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d6e8ef"))
	draw_string(font, Vector2(15, 347), "矢印/ドラッグ: 移動  Z/Space/A/タッチ: 攻撃  R/Start: 再挑戦", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#b7d6e6"))
	if phase == "won" or phase == "lost":
		draw_rect(Rect2(110, 133, 420, 90), Color("#0a1628", 0.93))
		draw_string(font, Vector2(165, 183), "試作クリア！" if phase == "won" else "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#ffe6b5"))

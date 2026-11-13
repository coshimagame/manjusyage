extends Node2D
## Isolated stage-2 combat prototype. NOT wired to the campaign or canon.
## Run res://prototypes/stage2_combat.tscn directly in Godot 4.6.
const SIZE := Vector2(640, 360)
var ship := Vector2(96, 180)
var hp := 4
var elapsed := 0.0
var fire_cooldown := 0.0
var spawn_cooldown := 0.0
var bullets: Array[Vector2] = []
var foes: Array[Vector2] = []
var boss_hp := 24
var boss_active := false
var finished := false
var won := false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _process(delta: float) -> void:
	if finished:
		queue_redraw()
		return
	elapsed += delta
	var axis := Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A): axis.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): axis.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W): axis.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S): axis.y += 1
	axis += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	ship += axis.limit_length(1.0) * 175.0 * delta
	ship = ship.clamp(Vector2(12, 12), SIZE - Vector2(12, 12))
	fire_cooldown -= delta
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_accept")) and fire_cooldown <= 0:
		bullets.append(ship + Vector2(12, 0))
		fire_cooldown = 0.16
	for i in range(bullets.size() - 1, -1, -1):
		bullets[i].x += 320.0 * delta
		if bullets[i].x > SIZE.x: bullets.remove_at(i)
	if not boss_active and elapsed >= 25.0:
		boss_active = true
		foes.clear()
	if not boss_active:
		spawn_cooldown -= delta
		if spawn_cooldown <= 0:
			foes.append(Vector2(650, randf_range(25, 335)))
			spawn_cooldown = 0.85
	for i in range(foes.size() - 1, -1, -1):
		foes[i].x -= 105.0 * delta
		if foes[i].x < -20:
			foes.remove_at(i)
			continue
		if foes[i].distance_to(ship) < 15:
			hp -= 1
			foes.remove_at(i)
			if hp <= 0: finished = true
			continue
		for j in range(bullets.size() - 1, -1, -1):
			if foes[i].distance_to(bullets[j]) < 13:
				bullets.remove_at(j)
				foes.remove_at(i)
				break
	if boss_active:
		var boss_pos := Vector2(550, 180 + sin(elapsed * 1.8) * 90)
		for j in range(bullets.size() - 1, -1, -1):
			if bullets[j].distance_to(boss_pos) < 30:
				bullets.remove_at(j)
				boss_hp -= 1
				if boss_hp <= 0:
					finished = true
					won = true
		if not finished and ship.distance_to(boss_pos) < 36:
			hp = 0
			finished = true
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R and finished:
			get_tree().reload_current_scene()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#071329"))
	for i in range(24):
		var x := fposmod(float(i * 89) - elapsed * 24.0, 640.0)
		draw_circle(Vector2(x, float((i * 53) % 360)), 1.0, Color("#4b7591"))
	draw_colored_polygon(PackedVector2Array([ship + Vector2(14, 0), ship + Vector2(-11, -9), ship + Vector2(-6, 0), ship + Vector2(-11, 9)]), Color("#f04f5e"))
	for p in bullets: draw_rect(Rect2(p - Vector2(2, 1), Vector2(9, 3)), Color("#b7faff"))
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
	if finished:
		draw_rect(Rect2(150, 130, 340, 100), Color("#09111e"))
		draw_string(ThemeDB.fallback_font, Vector2(185, 175), "CLEAR" if won else "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(185, 208), "R: RETRY  (NO CAMPAIGN SAVE)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

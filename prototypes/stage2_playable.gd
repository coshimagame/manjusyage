extends Node2D
## Stage 2 combat prototype. Temporary procedural visuals; approved sprites untouched.
## Launch res://prototypes/stage2_playable.tscn directly in Godot 4.6.
signal stage_cleared
signal retry_requested
const BriefingProgress = preload("res://briefing_progress.gd")

const W := 640.0
const H := 360.0
# Reuse the existing optional PNG registry; missing artwork keeps procedural fallback.
const ArtCatalog = preload("res://art_catalog.gd")
var artwork = ArtCatalog.new()
var ship := Vector2(90, 180)
var hp := 5
# Brief invulnerability prevents one overlapping volley from draining all HP.
var hit_grace := 0.0
var enemy_hp := 30
var enemy_pos := Vector2(535, 180)
var enemy_phase := 0.0
var fire_cooldown := 0.0
var enemy_cooldown := 0.0
var elapsed := 0.0
var shots: Array[Vector2] = []
var hostile: Array[Vector2] = []
var state := "playing"
var paused := false
var touch_move := Vector2.ZERO
var touch_fire := false
var touch_id := -1
var fire_touch_id := -1

func _ready() -> void:
	artwork.reload()
	set_process(true)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	# Pause only live combat; do not mistake pause for a terminal result.
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_P or event.keycode == KEY_ESCAPE) and state == "playing":
		paused = not paused
		queue_redraw()
		return
	if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START and state == "playing":
		paused = not paused
		queue_redraw()
		return
	if paused:
		return
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if state != "playing" and e.pressed:
			_handle_result_pointer(e.position)
			return
		# Convert window touch coordinates to the 640x360 game canvas.
		var local_pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * e.position
		# Always release by finger ID, even when a finger crosses screen halves.
		if not e.pressed:
			if e.index == touch_id:
				touch_id = -1
				touch_move = Vector2.ZERO
			if e.index == fire_touch_id:
				fire_touch_id = -1
				touch_fire = false
		elif local_pos.x < W * 0.5:
			if touch_id < 0:
				touch_id = e.index
				touch_move = local_pos
		elif fire_touch_id < 0:
			fire_touch_id = e.index
			touch_fire = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and state != "playing":
		_handle_result_pointer(event.position)
		return
	elif event is InputEventJoypadButton and event.pressed and state != "playing":
		# A: retry; B: return to main menu. Match result-screen touch buttons.
		if event.button_index == JOY_BUTTON_A:
			_restart()
		elif event.button_index == JOY_BUTTON_B:
			get_tree().change_scene_to_file("res://main.tscn")
		return
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == touch_id:
			touch_move = get_global_transform_with_canvas().affine_inverse() * d.position
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q and state != "playing":
			get_tree().change_scene_to_file("res://main.tscn")
			return
		if state != "playing" and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_R):
			_restart()

func _handle_result_pointer(screen_pos: Vector2) -> void:
	# Touch and mouse share the same result-screen hit targets.
	var local_pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * screen_pos
	if Rect2(170, 178, 140, 38).has_point(local_pos):
		_restart()
	elif Rect2(330, 178, 140, 38).has_point(local_pos):
		get_tree().change_scene_to_file("res://main.tscn")

func _process(delta: float) -> void:
	if state != "playing" or paused:
		queue_redraw()
		return
	var dt: float = minf(delta, 0.05)
	elapsed += dt
	hit_grace = maxf(0.0, hit_grace - dt)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if touch_id >= 0:
		direction = (touch_move - ship).limit_length(1.0)
	ship += direction * 200.0 * dt
	ship = ship.clamp(Vector2(20, 20), Vector2(300, 340))
	fire_cooldown -= dt
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A) or touch_fire) and fire_cooldown <= 0.0:
		shots.append(ship + Vector2(18, 0))
		fire_cooldown = 0.13
	enemy_phase += dt * 1.7
	enemy_pos.y = 180.0 + sin(enemy_phase) * 95.0
	enemy_cooldown -= dt
	if enemy_cooldown <= 0.0:
		hostile.append(enemy_pos + Vector2(-22, 0))
		enemy_cooldown = 0.8
	for i in range(shots.size() - 1, -1, -1):
		shots[i].x += 350.0 * dt
		if shots[i].distance_to(enemy_pos) < 28.0:
			shots.remove_at(i)
			enemy_hp -= 1
			if enemy_hp <= 0:
				state = "clear"
				var progress = BriefingProgress.new()
				progress.load_data() # Preserve Stage 1 completion and prior unlocks.
				progress.mark_cleared(2)
				stage_cleared.emit()
				break
		elif shots[i].x > W:
			shots.remove_at(i)
	if state != "playing":
		queue_redraw()
		return
	for i in range(hostile.size() - 1, -1, -1):
		hostile[i].x -= 150.0 * dt
		if hostile[i].distance_to(ship) < 14.0:
			hostile.remove_at(i)
			if hit_grace > 0.0:
				continue
			hp -= 1
			hit_grace = 0.8
			if hp <= 0:
				state = "gameover"
				break
		elif hostile[i].x < 0.0:
			hostile.remove_at(i)
	queue_redraw()

func _restart() -> void:
	ship = Vector2(90, 180)
	hp = 5
	hit_grace = 0.0
	enemy_hp = 30
	enemy_phase = 0.0
	enemy_pos = Vector2(535, 180)
	elapsed = 0.0
	enemy_cooldown = 0.0
	fire_cooldown = 0.0
	shots.clear()
	hostile.clear()
	touch_id = -1
	touch_move = Vector2.ZERO
	fire_touch_id = -1
	touch_fire = false
	paused = false
	state = "playing"
	retry_requested.emit()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(W, H)), Color("#071025"))
	for n in range(24):
		var x := fposmod(float(n * 83) - elapsed * 22.0, W)
		var y := float((n * 47) % 350)
		draw_circle(Vector2(x, y), 1.0, Color("#496b91"))
	var player_art: Texture2D = artwork.texture("ship_cormii")
	var visible_ship := hit_grace <= 0.0 or int(elapsed * 12.0) % 2 == 0
	if player_art != null and visible_ship:
		draw_texture_rect(player_art, Rect2(ship - Vector2(20, 14), Vector2(40, 28)), false)
	elif player_art == null and visible_ship:
		draw_colored_polygon(PackedVector2Array([ship + Vector2(19, 0), ship + Vector2(-14, -11), ship + Vector2(-8, 0), ship + Vector2(-14, 11)]), Color("#69e4ff"))
	var boss_art: Texture2D = artwork.texture("boss_body")
	if boss_art != null:
		draw_texture_rect(boss_art, Rect2(enemy_pos - Vector2(30, 30), Vector2(60, 60)), false)
	else:
		draw_circle(enemy_pos, 25.0, Color("#8b234c"))
		draw_circle(enemy_pos, 12.0, Color("#f35c81"))
	for p in shots:
		draw_rect(Rect2(p, Vector2(11, 3)), Color("#ffe7a1"))
	for p in hostile:
		draw_circle(p, 5.0, Color("#ff7a88"))
	draw_rect(Rect2(12, 12, float(hp) * 22.0, 7), Color("#5ee2c5"))
	draw_rect(Rect2(420, 12, maxf(0.0, float(enemy_hp)) * 6.0, 7), Color("#f06088"))
	if paused and state == "playing":
		draw_rect(Rect2(175, 142, 290, 76), Color(0.02, 0.04, 0.12, 0.92))
		draw_string(ThemeDB.fallback_font, Vector2(272, 170), "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(207, 196), "P / ESC / START : RESUME", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	if state != "playing":
		draw_rect(Rect2(150, 132, 340, 90), Color(0.02, 0.04, 0.12, 0.92))
		var font := ThemeDB.fallback_font
		var label := "STAGE CLEAR" if state == "clear" else "GAME OVER"
		draw_string(font, Vector2(240, 170), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
		draw_rect(Rect2(170, 178, 140, 38), Color("#164b56"))
		draw_rect(Rect2(330, 178, 140, 38), Color("#45305b"))
		draw_string(font, Vector2(190, 202), "RETRY / ENTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
		draw_string(font, Vector2(351, 202), "MENU / Q", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

extends Node2D
## Standalone Stage 2 boss preview with the supplied BB02 artwork.
## Launch res://prototypes/stage2_playable.tscn directly in Godot 4.6.
signal stage_cleared
signal retry_requested

const W := 640.0
const H := 360.0
# Reuse the existing optional PNG registry; missing artwork keeps procedural fallback.
const ArtCatalog = preload("res://art_catalog.gd")
const BOSS_ART = preload("res://art/enemies/stage02_draft/BB02_h_draft.png")
const OCEAN_BACKDROP = preload("res://art/v09/cosmos.png")
const BOSS_REGION := Rect2(9,72,239,107)
var artwork = ArtCatalog.new()
var capture_requested := false
var hit_flash := 0.0
var hit_grace := 0.0
var ui_font := SystemFont.new()
var ship := Vector2(90, 180)
var hp := 5
var enemy_hp := 30
var enemy_pos := Vector2(535, 180)
var enemy_phase := 0.0
var fire_cooldown := 0.0
var enemy_cooldown := 0.0
var elapsed := 0.0
var shots: Array[Vector2] = []
var hostile: Array[Vector2] = []
var state := "playing"
var touch_move := Vector2.ZERO
var touch_fire := false
var touch_id := -1
var fire_touch_id := -1

func _ready() -> void:
	artwork.reload()
	ui_font.font_names=PackedStringArray(["Yu Gothic","Meiryo","Noto Sans CJK JP","sans-serif"])
	capture_requested=OS.get_cmdline_user_args().has("--stage2-shot")
	DisplayServer.window_set_title("曼珠沙華 — 第2ステージ ボス試作")
	set_process(true)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if state != "playing" and e.pressed:
			_restart()
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
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == touch_id:
			touch_move = get_global_transform_with_canvas().affine_inverse() * d.position
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:
			get_tree().quit()
			return
		if state != "playing" and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_R):
			_restart()

func _process(delta: float) -> void:
	if state != "playing":
		queue_redraw()
		return
	var dt: float = minf(delta, 0.05)
	elapsed += dt
	hit_flash=maxf(0.0,hit_flash-dt)
	hit_grace=maxf(0.0,hit_grace-dt)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if touch_id >= 0:
		direction = (touch_move - ship).limit_length(1.0)
	ship += direction * 200.0 * dt
	ship = ship.clamp(Vector2(20, 20), Vector2(300, 340))
	fire_cooldown -= dt
	var pads := Input.get_connected_joypads()
	var pad_fire := not pads.is_empty() and Input.is_joy_button_pressed(pads[0],JOY_BUTTON_A)
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_Z) or pad_fire or touch_fire) and fire_cooldown <= 0.0:
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
			hit_flash=.08
			if enemy_hp <= 0:
				state = "clear"
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
			if hit_grace>0:
				continue
			hit_grace=1.1
			hp -= 1
			if hp <= 0:
				state = "gameover"
				break
		elif hostile[i].x < 0.0:
			hostile.remove_at(i)
	queue_redraw()
	if capture_requested and elapsed>=.7 and DisplayServer.get_name()!="headless":
		capture_requested=false
		await RenderingServer.frame_post_draw
		var frame := get_viewport().get_texture().get_image()
		var error := frame.save_png("user://stage2-boss-preview.png") if frame else ERR_CANT_CREATE
		get_tree().quit(0 if error==OK else 1)

func _restart() -> void:
	ship = Vector2(90, 180)
	hp = 5
	enemy_hp = 30
	enemy_phase = 0.0
	enemy_pos=Vector2(535,180)
	hit_grace=0.0
	hit_flash=0.0
	enemy_cooldown = 0.0
	fire_cooldown = 0.0
	shots.clear()
	hostile.clear()
	touch_id = -1
	fire_touch_id = -1
	touch_fire = false
	state = "playing"
	retry_requested.emit()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(W, H)), Color("#071025"))
	draw_texture_rect(OCEAN_BACKDROP,Rect2(0,0,W,H),false,Color(.44,.69,.92))
	draw_rect(Rect2(0,0,W,H),Color("#061435",.36))
	for n in range(24):
		var x := fposmod(float(n * 83) - elapsed * 22.0, W)
		var y := float((n * 47) % 350)
		draw_circle(Vector2(x, y), 1.0, Color("#496b91"))
	var player_art: Texture2D = artwork.texture("ship_cormii")
	if player_art != null and (hit_grace<=0 or int(elapsed*16)%2==0):
		draw_texture_rect(player_art, Rect2(ship - Vector2(20, 14), Vector2(40, 28)), false)
	elif player_art==null:
		draw_colored_polygon(PackedVector2Array([ship + Vector2(19, 0), ship + Vector2(-14, -11), ship + Vector2(-8, 0), ship + Vector2(-14, 11)]), Color("#69e4ff"))
	if enemy_hp>0:
		var size := Vector2(168,75)*(1.0+sin(elapsed*3.8)*.03)
		var tint := Color("ffc7df") if hit_flash>0 else Color.WHITE
		draw_texture_rect_region(BOSS_ART,Rect2(enemy_pos-size*.5,size),BOSS_REGION,tint)
	for p in shots:
		draw_rect(Rect2(p, Vector2(11, 3)), Color("#ffe7a1"))
	for p in hostile:
		draw_colored_polygon(PackedVector2Array([p+Vector2(-6,0),p+Vector2(0,-4),p+Vector2(5,0),p+Vector2(0,4)]),Color("#f467ad"))
		draw_rect(Rect2(p-Vector2.ONE,Vector2(2,2)),Color("#fff4ea"))
	draw_rect(Rect2(0,0,W,34),Color("#071025",.88))
	draw_rect(Rect2(12, 12, float(hp) * 22.0, 7), Color("#5ee2c5"))
	draw_rect(Rect2(420, 12, maxf(0.0, float(enemy_hp)) * 6.0, 7), Color("#f06088"))
	draw_string(ui_font,Vector2(217,23),"第2ステージ  ボス試作",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#c8edff"))
	draw_string(ui_font,Vector2(12,347),"矢印キーで移動   Z / Space で射撃   Esc で終了",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#c8edff"))
	if state != "playing":
		draw_rect(Rect2(150, 132, 340, 90), Color(0.02, 0.04, 0.12, 0.92))
		var font := ThemeDB.fallback_font
		var label := "STAGE CLEAR" if state == "clear" else "GAME OVER"
		draw_string(font, Vector2(240, 170), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
		draw_string(font, Vector2(205, 201), "ENTER / TAP : RETRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

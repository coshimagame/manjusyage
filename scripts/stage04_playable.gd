extends Node2D
## Isolated stage-4 test; draft PNGs supplied separately in ZIP.
const IDS := ["EN401","EN402","EN403","EN404","EN405","EN406","EN407","EN408","EN409","SB04","MB04","BB04"]
var vertical := false
var player := Vector2(100,180)
var hp := 5
var spawn_index := 0
var spawn_timer := 0.0
var shot_timer := 0.0
var invincible := 0.0
var finished := false
var enemies: Array[Dictionary] = []
var bullets: Array[Vector2] = []
var enemy_bullets: Array[Dictionary] = []
var textures := {}

func _ready() -> void:
 reset()

func reset() -> void:
 player = Vector2(100,180)
 hp = 5
 spawn_index = 0
 spawn_timer = 0.0
 shot_timer = 0.0
 invincible = 0.0
 finished = false
 enemies.clear()
 bullets.clear()
 enemy_bullets.clear()
 textures.clear()
 for id in IDS:
  var path := "res://art/enemies/stage04_draft/%s_%s_draft.png" % [id,"v" if vertical else "h"]
  if ResourceLoader.exists(path): textures[id] = load(path)
 queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode == KEY_TAB:
   vertical = not vertical
   reset()
  elif event.keycode == KEY_R: reset()

func spawn_enemy(index: int) -> void:
 var position := Vector2(90.0 + float(index % 5)*100.0,-24.0) if vertical else Vector2(664.0,70.0 + float(index % 5)*48.0)
 enemies.append({"index":index,"pos":position,"age":0.0,"hp":(28 if index == 11 else 12) if index >= 9 else 2,"fire":0.9})

func _process(delta: float) -> void:
 if finished:
  queue_redraw()
  return
 invincible = maxf(0.0,invincible-delta)
 var motion := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
 if Input.is_key_pressed(KEY_W): motion.y -= 1.0
 if Input.is_key_pressed(KEY_S): motion.y += 1.0
 if Input.is_key_pressed(KEY_A): motion.x -= 1.0
 if Input.is_key_pressed(KEY_D): motion.x += 1.0
 player = (player + motion.limit_length()*190.0*delta).clamp(Vector2(16,32),Vector2(624,340))
 shot_timer -= delta
 if (Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_SPACE)) and shot_timer <= 0.0:
  bullets.append(player)
  shot_timer = 0.13
 spawn_timer += delta
 if spawn_index < 9 and spawn_timer >= 1.7:
  spawn_enemy(spawn_index)
  spawn_index += 1
  spawn_timer = 0.0
 elif spawn_index >= 9 and spawn_index < 12 and enemies.is_empty():
  spawn_enemy(spawn_index)
  spawn_index += 1
 for i in range(bullets.size()-1,-1,-1):
  bullets[i] += (Vector2.UP if vertical else Vector2.RIGHT)*350.0*delta
  if bullets[i].x > 650 or bullets[i].y < -10: bullets.remove_at(i)
 for i in range(enemy_bullets.size()-1,-1,-1):
  var b: Dictionary = enemy_bullets[i]
  b.pos += b.vel*delta
  if b.pos.x < -20 or b.pos.x > 660 or b.pos.y < -20 or b.pos.y > 380:
   enemy_bullets.remove_at(i)
  elif invincible <= 0.0 and b.pos.distance_to(player) < 12:
   enemy_bullets.remove_at(i)
   hp -= 1
   invincible = 1.0
   if hp <= 0: finished = true
 for i in range(enemies.size()-1,-1,-1):
  var e: Dictionary = enemies[i]
  e.age += delta
  var offset := sin(e.age*2.0)*24.0
  if e.index >= 9:
   e.pos = Vector2(320,115) + Vector2(offset,sin(e.age)*10.0)
  else:
   e.pos += (Vector2(0,65) if vertical else Vector2(-65,0))*delta
   e.pos += (Vector2(offset,0) if vertical else Vector2(0,offset))*delta*0.1
  e.fire -= delta
  if e.fire <= 0:
   enemy_bullets.append({"pos":e.pos,"vel":(player-e.pos).normalized()*115.0})
   e.fire = 0.55 if e.index >= 9 else 1.8
  for j in range(bullets.size()-1,-1,-1):
   if bullets[j].distance_to(e.pos) < (35.0 if e.index >= 9 else 19.0):
    bullets.remove_at(j)
    e.hp -= 1
    break
  if e.hp <= 0 or (e.index < 9 and (e.pos.x < -50 or e.pos.y > 410)):
   enemies.remove_at(i)
 if spawn_index == 12 and enemies.is_empty(): finished = true
 queue_redraw()

func _draw() -> void:
 draw_rect(Rect2(0,0,640,360),Color("#191020"))
 for e in enemies:
  var id: String = IDS[e.index]
  var texture: Texture2D = textures.get(id)
  var size := Vector2(90,90) if e.index >= 9 else Vector2(45,45)
  if texture != null: draw_texture_rect(texture,Rect2(e.pos-size/2,size),false)
  else: draw_circle(e.pos,14,Color.ORANGE_RED)
 for b in bullets: draw_circle(b,3,Color.CYAN)
 for b in enemy_bullets: draw_circle(b.pos,4,Color.HOT_PINK)
 if invincible <= 0.0: draw_colored_polygon(PackedVector2Array([player+Vector2(14,0),player+Vector2(-9,-8),player+Vector2(-9,8)]),Color.YELLOW)
 draw_string(ThemeDB.fallback_font,Vector2(12,20),"STAGE 4  HP %d  %s" % [hp,"VERTICAL" if vertical else "HORIZONTAL"],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
 draw_string(ThemeDB.fallback_font,Vector2(12,345),"MOVE: ARROWS/WASD   SHOOT: Z/SPACE   TAB: H/V   R: RETRY",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
 if finished: draw_string(ThemeDB.fallback_font,Vector2(175,180),"FINISHED / PRESS R",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color.WHITE)

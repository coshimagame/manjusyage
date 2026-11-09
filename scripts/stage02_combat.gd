extends Node2D
## Provisional Stage 2 combat integrated via main game briefing; draft PNGs optional.
## Main game and approved assets remain unchanged.
const W := 640.0
const H := 360.0
var stage := 2
var vertical := false
var player_pos := Vector2(100,180)
var hp := 5
var kills := 0
var elapsed := 0.0
var spawn_clock := 0.0
var spawn_index := 0
var fire_clock := 0.0
var invulnerable := 0.0
var game_over := false
var paused := false
var boss_spawned := false
var stage_complete := false
var result_saved := false
var save_failed := false
var enemies: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var enemy_shots: Array[Dictionary] = []
var textures := {}

func _ready() -> void:
 _load_stage()

func _enemy_id(slot: int) -> String:
 if slot < 9:
  return "EN%03d" % [stage * 100 + slot + 1] if stage > 1 else "EN%03d" % [slot + 1]
 return ["SB","MB","BB"][slot-9] + "%02d" % stage

func _load_stage() -> void:
 # A fresh attempt must not inherit the previous player's combat state.
 player_pos = Vector2(100, 180)
 hp = 5
 kills = 0
 invulnerable = 0.0
 game_over = false
 paused = false
 enemies.clear()
 shots.clear()
 enemy_shots.clear()
 elapsed = 0.0
 spawn_clock = 0.0
 spawn_index = 0
 fire_clock = 0.0
 boss_spawned = false
 stage_complete = false
 result_saved = false
 save_failed = false
 textures.clear()
 for slot in range(12):
  var eid := _enemy_id(slot)
  var orientation := "v" if vertical else "h"
  var path := "res://art/enemies/stage%02d_draft/%s_%s_draft.png" % [stage,eid,orientation]
  if ResourceLoader.exists(path):
   textures[eid] = load(path)
 queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode == KEY_P and not game_over:
   paused = not paused
   queue_redraw()
   get_viewport().set_input_as_handled()
  elif paused:
   return
  elif event.keycode == KEY_TAB:
   vertical = not vertical
   _load_stage()
  elif event.keycode == KEY_ESCAPE:
   get_tree().change_scene_to_file("res://prologue.tscn")
  elif event.keycode in [KEY_ENTER,KEY_SPACE] and game_over:
   get_tree().change_scene_to_file("res://prologue.tscn")
  elif event.keycode == KEY_S and game_over and stage_complete and save_failed:
   _save_clear_progress()
   queue_redraw()
  elif event.keycode == KEY_R:
   stage = 2
   hp = 5
   kills = 0
   game_over = false
   _load_stage()

func _unhandled_input(event: InputEvent) -> void:
 # Pad retry/return mirrors the keyboard flow without touching the save format.
 if event is InputEventJoypadButton and event.pressed:
  if event.button_index == JOY_BUTTON_START and not game_over:
   paused = not paused
   queue_redraw()
   get_viewport().set_input_as_handled()
   return
  if paused:
   return
  if game_over and event.button_index == JOY_BUTTON_Y:
   _load_stage()
   get_viewport().set_input_as_handled()
  elif game_over and event.button_index == JOY_BUTTON_B:
   get_tree().change_scene_to_file("res://prologue.tscn")
   get_viewport().set_input_as_handled()

func _first_pad() -> int:
 var connected := Input.get_connected_joypads()
 return connected[0] if not connected.is_empty() else -1

func _hurt() -> void:
 hp -= 1
 invulnerable = 1.1
 if hp <= 0: game_over = true

func _spawn(slot: int) -> void:
 var pos := Vector2(60.0 + float(slot % 5) * 110.0,-35.0) if vertical else Vector2(675.0,75.0 + float(slot % 5) * 53.0)
 enemies.append({"id":_enemy_id(slot),"slot":slot,"pos":pos,"origin":pos,"age":0.0,"speed":28.0 if slot >= 9 else 65.0,"hp":28 if slot == 11 else 2,"fire":1.0})

func _save_clear_progress() -> void:
 # Keep a failed write visible and allow an explicit retry from the result screen.
 var progress = load("res://briefing_progress.gd").new()
 progress.load_data()
 progress.mark_cleared(stage)
 var verify = load("res://briefing_progress.gd").new()
 verify.load_data()
 save_failed = not bool(verify.cleared.get(stage, false))

func _process(delta: float) -> void:
 if paused:
  return
 if game_over:
  queue_redraw()
  return
 if stage_complete:
  if not result_saved:
   result_saved = true
   _save_clear_progress()
  game_over = true
  queue_redraw()
  return
 elapsed += delta
 invulnerable = maxf(0.0,invulnerable-delta)
 var movement := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
 var pad := _first_pad()
 if pad >= 0:
  movement += Vector2(Input.get_joy_axis(pad,JOY_AXIS_LEFT_X),Input.get_joy_axis(pad,JOY_AXIS_LEFT_Y))
 if Input.is_key_pressed(KEY_A): movement.x -= 1.0
 if Input.is_key_pressed(KEY_D): movement.x += 1.0
 if Input.is_key_pressed(KEY_W): movement.y -= 1.0
 if Input.is_key_pressed(KEY_S): movement.y += 1.0
 if movement.length() < 0.2: movement = Vector2.ZERO
 elif movement.length() > 1.0: movement = movement.normalized()
 player_pos += movement * 190.0 * delta
 player_pos = player_pos.clamp(Vector2(14,35),Vector2(626,345))
 fire_clock -= delta
 var pad_firing := pad >= 0 and Input.is_joy_button_pressed(pad, JOY_BUTTON_A)
 if (Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_SPACE) or pad_firing) and fire_clock <= 0.0:
  shots.append({"pos":player_pos + (Vector2(0,-15) if vertical else Vector2(16,0))})
  fire_clock = 0.14
 spawn_clock += delta
 if spawn_index < 9 and spawn_clock >= 2.0:
  spawn_clock = 0.0
  _spawn(spawn_index)
  spawn_index += 1
 elif spawn_index >= 9 and not boss_spawned and enemies.is_empty():
  boss_spawned = true
  _spawn(11)
 for i in range(shots.size()-1,-1,-1):
  var s: Dictionary = shots[i]
  s.pos += (Vector2.UP if vertical else Vector2.RIGHT) * 370.0 * delta
  if s.pos.x > W or s.pos.y < 0: shots.remove_at(i)
 for i in range(enemy_shots.size()-1,-1,-1):
  var s: Dictionary = enemy_shots[i]
  s.pos += s.vel * delta
  if s.pos.x < -10 or s.pos.y > H+10 or s.pos.x > W+10 or s.pos.y < -10:
   enemy_shots.remove_at(i)
  elif invulnerable <= 0.0 and s.pos.distance_to(player_pos) < 11.0:
   enemy_shots.remove_at(i)
   _hurt()
 for i in range(enemies.size()-1,-1,-1):
  var e: Dictionary = enemies[i]
  e.age += delta
  var lateral: float = sin(e.age * (2.0 + float(e.slot % 3))) * 22.0
  if e.slot == 11:
   # Boss must remain reachable by player shots until defeated.
   e.pos = Vector2(clampf(e.origin.x + lateral, 100.0, 540.0), 95.0) if vertical else Vector2(520.0, clampf(e.origin.y + lateral, 55.0, 305.0))
  else:
   e.pos = e.origin + (Vector2(0,e.age*e.speed) if vertical else Vector2(-e.age*e.speed,0)) + (Vector2(lateral,0) if vertical else Vector2(0,lateral))
  e.fire -= delta
  if e.fire <= 0.0:
   var direction: Vector2 = (player_pos-e.pos).normalized()
   enemy_shots.append({"pos":e.pos,"vel":direction*105.0})
   e.fire = 1.7 if e.slot < 9 else 0.45
  for j in range(shots.size()-1,-1,-1):
   if shots[j].pos.distance_to(e.pos) < (27.0 if e.slot >= 9 else 16.0):
    shots.remove_at(j)
    e.hp -= 1
    break
  if e.hp <= 0:
   enemies.remove_at(i)
   kills += 1
   if e.slot == 11: stage_complete = true
  elif e.slot != 11 and (e.pos.x < -80 or e.pos.y > H+80):
   enemies.remove_at(i)
  elif invulnerable <= 0.0 and e.pos.distance_to(player_pos) < 22.0:
   _hurt()
 queue_redraw()

func _draw() -> void:
 draw_rect(Rect2(0,0,W,H),Color("#0b1725"))
 for x in range(0,640,40): draw_line(Vector2(x,0),Vector2(x,360),Color("#193047"),1.0)
 for y in range(0,360,40): draw_line(Vector2(0,y),Vector2(640,y),Color("#193047"),1.0)
 for e in enemies:
  var texture: Texture2D = textures.get(e.id)
  if texture != null:
   var size := Vector2(72,72) if e.slot >= 9 else Vector2(37,37)
   draw_texture_rect(texture,Rect2(e.pos-size/2.0,size),false)
  else:
   # Distinctive procedural fallback silhouettes; never overwrite approved PNGs.
   var slot: int = int(e.get("slot", 0))
   if slot == 11:
    draw_colored_polygon(PackedVector2Array([e.pos+Vector2(-32,0),e.pos+Vector2(-15,-20),e.pos+Vector2(0,-12),e.pos+Vector2(15,-20),e.pos+Vector2(32,0),e.pos+Vector2(12,19),e.pos+Vector2(-12,19)]),Color("#8e3158"))
    draw_circle(e.pos,8.0,Color("#ffb3cc"))
    draw_arc(e.pos,24.0,0.0,TAU,24,Color("#ff7097"),2.0)
   elif slot >= 9:
    draw_colored_polygon(PackedVector2Array([e.pos+Vector2(0,-21),e.pos+Vector2(22,0),e.pos+Vector2(0,21),e.pos+Vector2(-22,0)]),Color("#c25374"))
    draw_circle(e.pos,5.0,Color("#ffe1a3"))
   elif slot % 3 == 0:
    draw_colored_polygon(PackedVector2Array([e.pos+Vector2(-15,-11),e.pos+Vector2(15,0),e.pos+Vector2(-15,11)]),Color("#f17c69"))
   elif slot % 3 == 1:
    draw_colored_polygon(PackedVector2Array([e.pos+Vector2(0,-16),e.pos+Vector2(14,0),e.pos+Vector2(0,16),e.pos+Vector2(-14,0)]),Color("#e3a75f"))
   else:
    draw_circle(e.pos,12.0,Color("#875eb8"))
    draw_circle(e.pos,5.0,Color("#d5b7ff"))
 # Readable boss HP indicator without replacing any approved sprite art.
 for e in enemies:
  if int(e.get("slot", -1)) == 11:
   var boss_hp: float = clampf(float(e.get("hp", 0)) / 28.0, 0.0, 1.0)
   draw_rect(Rect2(180, 26, 280, 13), Color("#070e1c"))
   draw_rect(Rect2(182, 28, 276.0 * boss_hp, 9), Color("#ff668c"))
   draw_rect(Rect2(180, 26, 280, 13), Color("#f6cbd7"), false, 1.0)
   draw_string(ThemeDB.fallback_font, Vector2(180, 23), "STAGE 02 BOSS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
   break
 for s in shots: draw_circle(s.pos,3.0,Color("#63dfff"))
 for s in enemy_shots: draw_circle(s.pos,4.0,Color("#ff6c9c"))
 if invulnerable <= 0.0 or int(elapsed*10.0)%2 == 0:
  var ship := PackedVector2Array([player_pos+Vector2(15,0),player_pos+Vector2(-11,-9),player_pos+Vector2(-6,0),player_pos+Vector2(-11,9)])
  if vertical: ship = PackedVector2Array([player_pos+Vector2(0,-15),player_pos+Vector2(-9,11),player_pos,player_pos+Vector2(9,11)])
  draw_colored_polygon(ship,Color("#ffd46d"))
 draw_string(ThemeDB.fallback_font,Vector2(12,20),"STAGE %d  HP %d  KILLS %d  %s" % [stage,hp,kills,"VERTICAL" if vertical else "HORIZONTAL"],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
 draw_string(ThemeDB.fallback_font,Vector2(12,350),"MOVE: ARROWS/WASD | SHOOT: Z/SPACE | TAB: ORIENT | P/START: PAUSE | R: RETRY",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
 if paused:
  draw_rect(Rect2(170,125,300,105),Color("#090c16e8"))
  draw_string(ThemeDB.fallback_font,Vector2(270,165),"PAUSED",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color.WHITE)
  draw_string(ThemeDB.fallback_font,Vector2(208,200),"P / START : RESUME",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
 if game_over:
  draw_rect(Rect2(150,120,340,90),Color("#090c16dd"))
  var result_label := "STAGE 02 CLEAR" if stage_complete else "GAME OVER"
  draw_string(ThemeDB.fallback_font,Vector2(195,160),result_label,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
  draw_string(ThemeDB.fallback_font,Vector2(175,190),"ENTER/B: TITLE  /  R/Y: RETRY",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
  if stage_complete:
   var save_label := "SAVE FAILED - S: RETRY SAVE" if save_failed else "CLEAR SAVED - TITLE: L FOR BRIEFING"
   draw_string(ThemeDB.fallback_font,Vector2(155,225),save_label,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#ff8080") if save_failed else Color("#9de4bd"))

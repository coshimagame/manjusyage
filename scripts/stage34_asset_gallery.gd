extends Node2D
## Draft gallery for stage 3/4. No approved assets are overwritten.
var stage := 3
var vertical := false
var textures: Array[Texture2D] = []

func _ready() -> void:
 _load()

func _id(slot: int) -> String:
 if slot < 9: return "EN%03d" % [stage*100+slot+1]
 return ["SB","MB","BB"][slot-9] + "%02d" % stage

func _load() -> void:
 textures.clear()
 for i in range(12):
  var path := "res://art/enemies/stage%02d_draft/%s_%s_draft.png" % [stage,_id(i),"v" if vertical else "h"]
  textures.append(load(path) as Texture2D if ResourceLoader.exists(path) else null)
 queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode == KEY_SPACE: vertical = not vertical
  elif event.keycode == KEY_3: stage = 3
  elif event.keycode == KEY_4: stage = 4
  else: return
  _load()

func _draw() -> void:
 draw_rect(Rect2(0,0,640,360),Color("#101522"))
 draw_string(ThemeDB.fallback_font,Vector2(12,23),"STAGE %d / %s / DRAFT" % [stage,"VERTICAL" if vertical else "HORIZONTAL"],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
 for i in range(12):
  var center := Vector2(57+(i%6)*105,91+int(i/6)*137)
  draw_rect(Rect2(center-Vector2(44,43),Vector2(88,102)),Color("#2a293e"),false,1.0)
  var tex := textures[i]
  if tex != null:
   var original := tex.get_size()
   var factor: float = minf(74.0/maxf(original.x,1.0),66.0/maxf(original.y,1.0))
   var size := original*factor
   draw_texture_rect(tex,Rect2(center-size/2.0,size),false)
  else: draw_string(ThemeDB.fallback_font,center-Vector2(29,3),"NO PNG",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color.ORANGE_RED)
  draw_string(ThemeDB.fallback_font,center+Vector2(-24,53),_id(i),HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
 draw_string(ThemeDB.fallback_font,Vector2(12,343),"3 / 4: STAGE  |  SPACE: H/V  |  DRAFT ONLY",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)

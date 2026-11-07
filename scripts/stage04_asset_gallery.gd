extends Node2D
## Stage 4 draft PNG preview; does not replace approved assets.
const IDS := ["EN401","EN402","EN403","EN404","EN405","EN406","EN407","EN408","EN409","SB04","MB04","BB04"]
var vertical := false
var textures: Array[Texture2D] = []
var elapsed := 0.0
func _ready() -> void:
 _load_images()
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
  vertical = not vertical
  _load_images()
func _load_images() -> void:
 textures.clear()
 for id in IDS:
  var path := "res://art/enemies/stage04_draft/%s_%s_draft.png" % [id,"v" if vertical else "h"]
  textures.append(load(path) as Texture2D if ResourceLoader.exists(path) else null)
 queue_redraw()
func _process(delta: float) -> void:
 elapsed += delta
 queue_redraw()
func _draw() -> void:
 draw_rect(Rect2(0,0,640,360),Color("#171020"))
 draw_string(ThemeDB.fallback_font,Vector2(12,24),"STAGE 04 / DRAFT / %s" % ("VERTICAL" if vertical else "HORIZONTAL"),HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
 for i in range(IDS.size()):
  var center := Vector2(55+(i%6)*105,98+int(i/6)*140)
  draw_rect(Rect2(center-Vector2(45,48),Vector2(90,105)),Color("#3c2736"),false,1)
  var texture := textures[i]
  if texture != null:
   var original := texture.get_size()
   var factor: float = minf(74.0/maxf(original.x,1.0),68.0/maxf(original.y,1.0))
   var size := original*factor
   draw_texture_rect(texture,Rect2(center-size/2.0+Vector2(0,sin(elapsed*2.0+i)*3.0),size),false)
  else:
   draw_string(ThemeDB.fallback_font,center-Vector2(30,5),"MISSING",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color.RED)
  draw_string(ThemeDB.fallback_font,center+Vector2(-25,52),IDS[i],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color.WHITE)
 draw_string(ThemeDB.fallback_font,Vector2(12,343),"SPACE: H/V   |   DRAFT PNG PREVIEW ONLY",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#ffce75"))

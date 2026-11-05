extends RefCounted
# Data-driven organic hazards; each stage can override these definitions.
const STAGES = {
 1: {"name":"赤い残響","color":"d94368","events":[{"kind":"breath","at":10.0,"x":300.0,"width":160.0,"duration":7.0},{"kind":"grow","at":21.0,"x":480.0,"width":90.0,"duration":5.0}]},
 2: {"name":"追憶の海","color":"43bfe5","events":[{"kind":"breath","at":12.0,"x":260.0,"width":180.0,"duration":7.0}]},
 3: {"name":"孤独な庭","color":"b66de6","events":[{"kind":"grow","at":12.0,"x":370.0,"width":100.0,"duration":7.0}]},
 4: {"name":"分岐する空","color":"f2b96a","events":[{"kind":"breath","at":12.0,"x":300.0,"width":150.0,"duration":7.0}]},
 5: {"name":"忘却の要塞","color":"db5572","events":[{"kind":"grow","at":12.0,"x":400.0,"width":130.0,"duration":7.0}]},
 6: {"name":"白い彼岸","color":"a2a9f6","events":[{"kind":"breath","at":12.0,"x":300.0,"width":150.0,"duration":7.0}]},
 7: {"name":"輪廻の終点","color":"ee708c","events":[{"kind":"grow","at":12.0,"x":350.0,"width":130.0,"duration":7.0}]},
 8: {"name":"曼珠沙華","color":"f74b79","events":[{"kind":"breath","at":12.0,"x":300.0,"width":200.0,"duration":7.0}]}
}
const WARNING := 1.2
const SAFE_GAP := 148.0
var stage_id := 1
var elapsed := 0.0
var background_texture: Texture2D

func setup(stage: int) -> void:
 stage_id=clampi(stage,1,8)
 elapsed=0.0
 var path="res://art/stages/stage_%02d/background.png"%stage_id
 background_texture=load(path) as Texture2D if ResourceLoader.exists(path) else null

func tick(dt: float) -> void:
 elapsed+=dt

func _phase(event: Dictionary) -> float:
 return elapsed-float(event.get("at",0.0))

func _depth(event: Dictionary) -> float:
 var t=_phase(event)
 var d=float(event.get("duration",6.0))
 if t<0.0 or t>d: return 0.0
 var phase=(t-WARNING)/maxf(.1,d-WARNING)
 if phase<=0.0: return 0.0
 return pow(sin(PI*clampf(phase,0.0,1.0)),2.0)

func hazard_rects() -> Array:
 var rects: Array=[]
 for e in STAGES[stage_id]["events"]:
  var depth=_depth(e)
  if depth<=0.0: continue
  var x=float(e["x"]); var w=float(e["width"])
  var max_height=(360.0-SAFE_GAP)/2.0
  var h=max_height*depth
  rects.append(Rect2(x,0,w,h))
  rects.append(Rect2(x,360.0-h,w,h))
 return rects

func is_hazard(point: Vector2) -> bool:
 for rect in hazard_rects():
  if rect.has_point(point): return true
 return false

func draw_layer(canvas: CanvasItem) -> void:
 if background_texture!=null:
  canvas.draw_texture_rect(background_texture,Rect2(0,0,640,360),false,Color(1,1,1,.58))
 var color=Color.html(str(STAGES[stage_id]["color"]))
 for e in STAGES[stage_id]["events"]:
  var t=_phase(e)
  var duration=float(e.get("duration",6.0))
  if t<0.0 or t>duration: continue
  var x=float(e["x"]); var w=float(e["width"])
  if t<WARNING:
   var glow=.2+.5*abs(sin(elapsed*11.0))
   canvas.draw_rect(Rect2(x,6,w,8),Color(color.r,color.g,color.b,glow))
   canvas.draw_rect(Rect2(x,346,w,8),Color(color.r,color.g,color.b,glow))
 for rect in hazard_rects():
  canvas.draw_rect(rect,color.darkened(.65))
  var edge_y=rect.end.y if rect.position.y==0.0 else rect.position.y
  canvas.draw_line(Vector2(rect.position.x,edge_y),Vector2(rect.end.x,edge_y),color,4.0)
  for j in range(6):
   var px=rect.position.x+8+j*(rect.size.x-16)/5.0
   canvas.draw_circle(Vector2(px,edge_y),2.5+abs(sin(elapsed*7+j))*2.0,color.lightened(.3))

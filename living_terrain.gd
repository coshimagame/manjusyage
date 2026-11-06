extends RefCounted
# Data-driven organic hazards; each stage can override these definitions.
const STAGES = {1:{"name":"赤い残響","color":"d94368","events":[{"id":"S1_01","name":"鼓動する入口","kind":"breath","at":10,"x":220,"width":74,"duration":4,"intensity":0.52},{"id":"S1_02","name":"脈管の裂け目","kind":"grow","at":22,"x":267,"width":93,"duration":5,"intensity":0.62},{"id":"S1_03","name":"赤い門歯","kind":"pulse","at":34,"x":314,"width":112,"duration":6,"intensity":0.72},{"id":"S1_04","name":"循環弁","kind":"jaw","at":46,"x":361,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S1_05","name":"伸びる肋骨","kind":"spike","at":58,"x":408,"width":150,"duration":4,"intensity":0.52},{"id":"S1_06","name":"血流の逆転","kind":"iris","at":70,"x":455,"width":169,"duration":5,"intensity":0.62},{"id":"S1_07","name":"触覚の群れ","kind":"breath","at":82,"x":242,"width":88,"duration":6,"intensity":0.72},{"id":"S1_08","name":"拍動砲門","kind":"grow","at":94,"x":289,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S1_09","name":"閉じる喉","kind":"pulse","at":106,"x":336,"width":126,"duration":4,"intensity":0.52},{"id":"S1_10","name":"二重の心拍","kind":"jaw","at":118,"x":383,"width":145,"duration":5,"intensity":0.62},{"id":"S1_11","name":"増殖する壁","kind":"spike","at":130,"x":430,"width":164,"duration":6,"intensity":0.72},{"id":"S1_12","name":"深紅の瞳","kind":"iris","at":142,"x":477,"width":83,"duration":7,"intensity":0.8200000000000001},{"id":"S1_13","name":"出口の収縮","kind":"breath","at":154,"x":264,"width":102,"duration":4,"intensity":0.52}]},2:{"name":"追憶の海","color":"43bfe5","events":[{"id":"S2_01","name":"記憶の潮","kind":"grow","at":10,"x":243,"width":74,"duration":4,"intensity":0.52},{"id":"S2_02","name":"海底の呼吸","kind":"pulse","at":22,"x":290,"width":93,"duration":5,"intensity":0.62},{"id":"S2_03","name":"泡の通路","kind":"jaw","at":34,"x":337,"width":112,"duration":6,"intensity":0.72},{"id":"S2_04","name":"水圧の顎","kind":"spike","at":46,"x":384,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S2_05","name":"珊瑚の突起","kind":"iris","at":58,"x":431,"width":150,"duration":4,"intensity":0.52},{"id":"S2_06","name":"逆流する記録","kind":"breath","at":70,"x":478,"width":169,"duration":5,"intensity":0.62},{"id":"S2_07","name":"発光の弁","kind":"grow","at":82,"x":265,"width":88,"duration":6,"intensity":0.72},{"id":"S2_08","name":"沈む天井","kind":"pulse","at":94,"x":312,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S2_09","name":"深海の瞳","kind":"jaw","at":106,"x":359,"width":126,"duration":4,"intensity":0.52},{"id":"S2_10","name":"青い水門","kind":"spike","at":118,"x":406,"width":145,"duration":5,"intensity":0.62},{"id":"S2_11","name":"追憶の棘","kind":"iris","at":130,"x":453,"width":164,"duration":6,"intensity":0.72},{"id":"S2_12","name":"潮騒の鼓動","kind":"breath","at":142,"x":240,"width":83,"duration":7,"intensity":0.8200000000000001},{"id":"S2_13","name":"水底の裂け目","kind":"grow","at":154,"x":287,"width":102,"duration":4,"intensity":0.52}]},3:{"name":"孤独な庭","color":"b66de6","events":[{"id":"S3_01","name":"根の目覚め","kind":"pulse","at":10,"x":266,"width":74,"duration":4,"intensity":0.52},{"id":"S3_02","name":"花粉の脈","kind":"jaw","at":22,"x":313,"width":93,"duration":5,"intensity":0.62},{"id":"S3_03","name":"蔓の顎","kind":"spike","at":34,"x":360,"width":112,"duration":6,"intensity":0.72},{"id":"S3_04","name":"花弁の門","kind":"iris","at":46,"x":407,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S3_05","name":"芽吹く棘","kind":"breath","at":58,"x":454,"width":150,"duration":4,"intensity":0.52},{"id":"S3_06","name":"胞子の呼吸","kind":"grow","at":70,"x":241,"width":169,"duration":5,"intensity":0.62},{"id":"S3_07","name":"庭師の瞳","kind":"pulse","at":82,"x":288,"width":88,"duration":6,"intensity":0.72},{"id":"S3_08","name":"二重の枝","kind":"jaw","at":94,"x":335,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S3_09","name":"絡む花茎","kind":"spike","at":106,"x":382,"width":126,"duration":4,"intensity":0.52},{"id":"S3_10","name":"紫の拍動","kind":"iris","at":118,"x":429,"width":145,"duration":5,"intensity":0.62},{"id":"S3_11","name":"開花する壁","kind":"breath","at":130,"x":476,"width":164,"duration":6,"intensity":0.72},{"id":"S3_12","name":"閉じる庭園","kind":"grow","at":142,"x":263,"width":83,"duration":7,"intensity":0.8200000000000001},{"id":"S3_13","name":"種子の門","kind":"pulse","at":154,"x":310,"width":102,"duration":4,"intensity":0.52}]},4:{"name":"分岐する空","color":"f2b96a","events":[{"id":"S4_01","name":"風圧の脈","kind":"jaw","at":10,"x":289,"width":74,"duration":4,"intensity":0.52},{"id":"S4_02","name":"翼の収縮","kind":"spike","at":22,"x":336,"width":93,"duration":5,"intensity":0.62},{"id":"S4_03","name":"空路の顎","kind":"iris","at":34,"x":383,"width":112,"duration":6,"intensity":0.72},{"id":"S4_04","name":"回転する弁","kind":"breath","at":46,"x":430,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S4_05","name":"伸びる支柱","kind":"grow","at":58,"x":477,"width":150,"duration":4,"intensity":0.52},{"id":"S4_06","name":"雲間の棘","kind":"pulse","at":70,"x":264,"width":169,"duration":5,"intensity":0.62},{"id":"S4_07","name":"輸送の鼓動","kind":"jaw","at":82,"x":311,"width":88,"duration":6,"intensity":0.72},{"id":"S4_08","name":"浮遊する門","kind":"spike","at":94,"x":358,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S4_09","name":"風車の瞳","kind":"iris","at":106,"x":405,"width":126,"duration":4,"intensity":0.52},{"id":"S4_10","name":"分岐の裂け目","kind":"breath","at":118,"x":452,"width":145,"duration":5,"intensity":0.62},{"id":"S4_11","name":"落ちる天井","kind":"grow","at":130,"x":239,"width":164,"duration":6,"intensity":0.72},{"id":"S4_12","name":"空の呼吸","kind":"pulse","at":142,"x":286,"width":83,"duration":7,"intensity":0.8200000000000001}]},5:{"name":"忘却の要塞","color":"db5572","events":[{"id":"S5_01","name":"記録の脈","kind":"spike","at":10,"x":312,"width":74,"duration":4,"intensity":0.52},{"id":"S5_02","name":"消去する壁","kind":"iris","at":22,"x":359,"width":93,"duration":5,"intensity":0.62},{"id":"S5_03","name":"暗号の顎","kind":"breath","at":34,"x":406,"width":112,"duration":6,"intensity":0.72},{"id":"S5_04","name":"封印弁","kind":"grow","at":46,"x":453,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S5_05","name":"増殖する端末","kind":"pulse","at":58,"x":240,"width":150,"duration":4,"intensity":0.52},{"id":"S5_06","name":"記憶の棘","kind":"jaw","at":70,"x":287,"width":169,"duration":5,"intensity":0.62},{"id":"S5_07","name":"映写の瞳","kind":"spike","at":82,"x":334,"width":88,"duration":6,"intensity":0.72},{"id":"S5_08","name":"閉じる保管庫","kind":"iris","at":94,"x":381,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S5_09","name":"二重の門","kind":"breath","at":106,"x":428,"width":126,"duration":4,"intensity":0.52},{"id":"S5_10","name":"忘却の呼吸","kind":"grow","at":118,"x":475,"width":145,"duration":5,"intensity":0.62},{"id":"S5_11","name":"復元する壁","kind":"pulse","at":130,"x":262,"width":164,"duration":6,"intensity":0.72},{"id":"S5_12","name":"最終封印","kind":"jaw","at":142,"x":309,"width":83,"duration":7,"intensity":0.8200000000000001}]},6:{"name":"白い彼岸","color":"a2a9f6","events":[{"id":"S6_01","name":"白い呼吸","kind":"iris","at":10,"x":335,"width":74,"duration":4,"intensity":0.52},{"id":"S6_02","name":"透明な顎","kind":"breath","at":22,"x":382,"width":93,"duration":5,"intensity":0.62},{"id":"S6_03","name":"夢の弁","kind":"grow","at":34,"x":429,"width":112,"duration":6,"intensity":0.72},{"id":"S6_04","name":"転移の棘","kind":"pulse","at":46,"x":476,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S6_05","name":"療養室の脈","kind":"jaw","at":58,"x":263,"width":150,"duration":4,"intensity":0.52},{"id":"S6_06","name":"残像の門","kind":"spike","at":70,"x":310,"width":169,"duration":5,"intensity":0.62},{"id":"S6_07","name":"結晶の瞳","kind":"iris","at":82,"x":357,"width":88,"duration":6,"intensity":0.72},{"id":"S6_08","name":"半透明の壁","kind":"breath","at":94,"x":404,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S6_09","name":"眠りの収縮","kind":"grow","at":106,"x":451,"width":126,"duration":4,"intensity":0.52},{"id":"S6_10","name":"意識の拍動","kind":"pulse","at":118,"x":238,"width":145,"duration":5,"intensity":0.62},{"id":"S6_11","name":"目覚める天井","kind":"jaw","at":130,"x":285,"width":164,"duration":6,"intensity":0.72},{"id":"S6_12","name":"白い出口","kind":"spike","at":142,"x":332,"width":83,"duration":7,"intensity":0.8200000000000001}]},7:{"name":"輪廻の終点","color":"ee708c","events":[{"id":"S7_01","name":"世界線の脈","kind":"breath","at":10,"x":358,"width":74,"duration":4,"intensity":0.52},{"id":"S7_02","name":"二重の壁","kind":"grow","at":22,"x":405,"width":93,"duration":5,"intensity":0.62},{"id":"S7_03","name":"輪廻の顎","kind":"pulse","at":34,"x":452,"width":112,"duration":6,"intensity":0.72},{"id":"S7_04","name":"位相の弁","kind":"jaw","at":46,"x":239,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S7_05","name":"重なる棘","kind":"spike","at":58,"x":286,"width":150,"duration":4,"intensity":0.52},{"id":"S7_06","name":"反転の呼吸","kind":"iris","at":70,"x":333,"width":169,"duration":5,"intensity":0.62},{"id":"S7_07","name":"双子の門","kind":"breath","at":82,"x":380,"width":88,"duration":6,"intensity":0.72},{"id":"S7_08","name":"交差する瞳","kind":"grow","at":94,"x":427,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S7_09","name":"世界の裂け目","kind":"pulse","at":106,"x":474,"width":126,"duration":4,"intensity":0.52},{"id":"S7_10","name":"時差の拍動","kind":"jaw","at":118,"x":261,"width":145,"duration":5,"intensity":0.62},{"id":"S7_11","name":"境界の収縮","kind":"spike","at":130,"x":308,"width":164,"duration":6,"intensity":0.72},{"id":"S7_12","name":"終点の門","kind":"iris","at":142,"x":355,"width":83,"duration":7,"intensity":0.8200000000000001}]},8:{"name":"曼珠沙華","color":"f74b79","events":[{"id":"S8_01","name":"花弁の呼吸","kind":"grow","at":10,"x":381,"width":74,"duration":4,"intensity":0.52},{"id":"S8_02","name":"紅蓮の顎","kind":"pulse","at":22,"x":428,"width":93,"duration":5,"intensity":0.62},{"id":"S8_03","name":"種子の脈","kind":"jaw","at":34,"x":475,"width":112,"duration":6,"intensity":0.72},{"id":"S8_04","name":"彼岸の弁","kind":"spike","at":46,"x":262,"width":131,"duration":7,"intensity":0.8200000000000001},{"id":"S8_05","name":"伸びる花茎","kind":"iris","at":58,"x":309,"width":150,"duration":4,"intensity":0.52},{"id":"S8_06","name":"中枢の棘","kind":"breath","at":70,"x":356,"width":169,"duration":5,"intensity":0.62},{"id":"S8_07","name":"最後の瞳","kind":"grow","at":82,"x":403,"width":88,"duration":6,"intensity":0.72},{"id":"S8_08","name":"輪廻の門","kind":"pulse","at":94,"x":450,"width":107,"duration":7,"intensity":0.8200000000000001},{"id":"S8_09","name":"花冠の収縮","kind":"jaw","at":106,"x":237,"width":126,"duration":4,"intensity":0.52},{"id":"S8_10","name":"世界の拍動","kind":"spike","at":118,"x":284,"width":145,"duration":5,"intensity":0.62},{"id":"S8_11","name":"崩れる壁","kind":"iris","at":130,"x":331,"width":164,"duration":6,"intensity":0.72},{"id":"S8_12","name":"赤い再生","kind":"breath","at":142,"x":378,"width":83,"duration":7,"intensity":0.82},{"id":"S8_13","name":"最後の花開き","kind":"iris","at":154,"x":415,"width":130,"duration":8,"intensity":0.9}]}}
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
  var style=str(e.get("kind","breath"))
  var intensity=float(e.get("intensity",.7))
  var h=max_height*depth*intensity
  if style=="pulse": h*=.5+.5*abs(sin(elapsed*9.0))
  elif style=="spike": h*=.65+.35*abs(sin(elapsed*13.0))
  elif style=="iris": h*=.7+.3*abs(sin(elapsed*4.0))
  elif style=="jaw": h*=.75+.25*abs(sin(elapsed*7.0))
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

extends RefCounted

const ACCENTS := [Color("ff6e9b"), Color("60dfff"), Color("ffd16d")]
const BACKGROUNDS := [Color("200b1b"), Color("071527"), Color("201407")]
const PANEL := Color("080e1c")

static func card(game, rect: Rect2, accent: Color) -> void:
	var a := rect.position
	var b := rect.end
	var outline := PackedVector2Array([
		a+Vector2(8,0), Vector2(b.x-8,a.y), Vector2(b.x,a.y+8),
		b-Vector2(0,8), b-Vector2(8,0), Vector2(a.x+8,b.y),
		Vector2(a.x,b.y-8), a+Vector2(0,8), a+Vector2(8,0)
	])
	game.draw_colored_polygon(outline.slice(0,8),PANEL)
	game.draw_polyline(outline,Color(accent,.28),4)
	game.draw_polyline(outline,Color(accent,.88),1)
	game.draw_line(a+Vector2(12,4),a+Vector2(63,4),accent,1)
	game.draw_line(b-Vector2(62,4),b-Vector2(12,4),Color(accent,.55),1)

static func draw(game, pilot: Dictionary, slot: int) -> void:
	var id := int(pilot.character)
	var accent: Color = ACCENTS[id]
	game.draw_rect(Rect2(0,0,640,360),BACKGROUNDS[id])
	for i in range(18):
		var x := i*44.0-120.0
		game.draw_line(Vector2(x,56),Vector2(x+120,336),Color(accent,.08),1)

	card(game,Rect2(16,9,608,44),accent)
	game.japanese(game.PILOT_NAMES[id],Vector2(30,37),22,Color.WHITE)
	game.text_at("P"+str(slot+1),Vector2(177,25),accent,2)
	game.japanese("ライフ",Vector2(238,34),12,Color.WHITE)
	for i in range(4):
		var x := 293.0+i*19.0
		game.draw_colored_polygon(PackedVector2Array([
			Vector2(x,23),Vector2(x+4,19),Vector2(x+8,23),
			Vector2(x+12,19),Vector2(x+16,23),Vector2(x+8,33)
		]),Color("ffa2bd") if i<int(pilot.hp) else Color("514255"))
	game.japanese("エネルギー",Vector2(396,34),11,Color.WHITE)
	game.draw_rect(Rect2(467,23,110,9),Color(accent,.18))
	game.draw_rect(Rect2(467,23,110*clampf(float(pilot.charge)/100.0,0,1),9),accent)
	game.text_at(str(int(pilot.charge)),Vector2(586,24),Color.WHITE)

	if game.archive_page and id==2:
		game.draw_mafio_archive()
	else:
		draw_portrait(game,id,accent)
		card(game,Rect2(238,64,386,187),accent)
		match id:
			0: draw_output(game,pilot,accent)
			1: draw_analysis(game,pilot,accent)
			2: draw_digestion(game,pilot,accent)
		draw_loadout(game,pilot,id,accent)
	var hint := "← → 操縦士切替     Tab / Start 戻る"
	if id==2: hint+="     E / X 図鑑"
	game.japanese(hint,Vector2(20,348),11,accent)

static func draw_portrait(game, id: int, accent: Color) -> void:
	var panel := Rect2(16,64,210,187)
	card(game,panel,accent)
	var center := panel.get_center()
	for radius in [56.0,69.0,82.0]:
		game.draw_arc(center,radius,0,TAU,48,Color(accent,.12),1)
	var portrait: Texture2D = game.pilot_portraits[id]
	if portrait:
		var native := portrait.get_size()
		var size := native*minf(191.0/native.x,177.0/native.y)
		game.draw_texture_rect(portrait,Rect2(center-size*.5,size),false)
	elif game.character_system_ui:
		var regions := [Rect2(10,62,245,250),Rect2(579,62,218,250),Rect2(1115,62,214,250)]
		game.draw_texture_rect_region(game.character_system_ui,Rect2(47,70,148,172),regions[id])
	game.draw_rect(Rect2(25,227,192,16),Color(PANEL,.91))
	game.japanese("操縦士  "+game.PILOT_NAMES[id],Vector2(33,240),11,Color.WHITE)

static func draw_loadout(game, pilot: Dictionary, id: int, accent: Color) -> void:
	card(game,Rect2(16,262,210,68),accent)
	card(game,Rect2(238,262,386,68),accent)
	var preview := pilot.duplicate()
	preview.pos=Vector2(141,296)
	preview.inv=0.0
	game.visual.ship(game,preview,id,0,2.0)
	game.japanese("機体",Vector2(28,287),12,accent)
	game.japanese("搭載系",Vector2(254,285),13,accent)
	var modules: Array = game.status_frame_modules(id)
	for i in range(modules.size()):
		var x := 254.0+i*117.0
		game.draw_rect(Rect2(x,295,108,22),Color(accent,.12))
		game.draw_rect(Rect2(x,295,2,22),accent)
		game.japanese(modules[i],Vector2(x+9,311),12,Color.WHITE)

static func draw_output(game, pilot: Dictionary, accent: Color) -> void:
	game.japanese("出力変動",Vector2(254,91),17,accent)
	game.japanese(game.Abilities.label(pilot,game.elapsed),Vector2(526,91),14,Color.WHITE)
	for y in [119,142,164,185]:
		game.draw_line(Vector2(257,y),Vector2(602,y),Color(accent,.16),1)
	var points := PackedVector2Array()
	var peak: float = game.Abilities.damage(pilot,0)
	for i in range(81):
		var output: float = game.Abilities.damage(pilot,i*.099)
		points.append(Vector2(257+i*4.31,185-output/peak*65))
	game.draw_polyline(points,Color(accent,.3),4)
	game.draw_polyline(points,accent,2)
	var cursor := 257.0+fposmod(game.elapsed,8.0)*43.1
	game.draw_line(Vector2(cursor,111),Vector2(cursor,194),Color("fff1eb"),1)
	game.japanese("現在の出力  ×%.2f"%float(game.Abilities.damage(pilot,game.elapsed)),Vector2(254,220),14,Color.WHITE)
	game.japanese("成長 Lv.%d"%(game.Abilities.level(pilot)+1),Vector2(507,220),13,accent)

static func draw_analysis(game, pilot: Dictionary, accent: Color) -> void:
	game.japanese("解析端末",Vector2(254,91),17,accent)
	var rank: int = game.Abilities.level(pilot)+1
	var center := Vector2(328,169)
	for i in range(4):
		var points := PackedVector2Array()
		for j in range(6):
			points.append(center+Vector2.from_angle(-PI*.5+j*TAU/5)*(16+i*12))
		game.draw_polyline(points,Color(accent,.86 if i<rank else .22),1.4)
	game.draw_rect(Rect2(center-Vector2(26,10),Vector2(52,20)),PANEL)
	game.text_at("LV "+str(rank),center-Vector2(23,6),Color.WHITE,2)
	game.japanese("解析経験  "+str(pilot.experience),Vector2(421,134),14,Color.WHITE)
	game.japanese("出力  ×%.2f"%float(game.Abilities.damage(pilot,game.elapsed)),Vector2(421,160),14,Color.WHITE)
	game.japanese("解析上限" if rank>=4 else "次の段階  %d"%(rank*8),Vector2(421,187),12,accent)
	for i in range(8):
		var active := rank>=4 or i<int(pilot.experience)%8
		game.draw_rect(Rect2(421+i*22,199,19,10),Color(accent,1.0 if active else .16))

static func draw_digestion(game, pilot: Dictionary, accent: Color) -> void:
	game.japanese("捕食・消化",Vector2(254,91),17,accent)
	var remaining := float(pilot.digest)
	var progress := 1.0-clampf(remaining/maxf(.1,float(pilot.digest_total)),0,1)
	var center := Vector2(316,157)
	game.draw_arc(center,45,0,TAU,34,Color(accent,.25),3)
	if remaining>0:
		game.draw_arc(center,45,-PI/2,-PI/2+TAU*progress,34,accent,3)
		game.japanese(str(int(round(progress*100)))+"%",center+Vector2(-20,6),17,Color.WHITE)
		game.japanese("消化中  "+game.status_technique_name(str(pilot.pending_technique)),Vector2(390,159),13,accent)
		game.japanese("残り %.1f 秒"%remaining,Vector2(390,179),12,Color.WHITE)
	else:
		game.japanese("待機",center+Vector2(-16,5),16,accent)
		game.japanese("弱った敵に近づいてバースト",Vector2(390,159),12,accent)
	game.japanese("保持技  "+game.status_technique_name(str(pilot.learned)),Vector2(390,132),14,Color.WHITE)
	game.japanese("捕食記録  "+str(game.mafio_archive.total_unlocked()),Vector2(390,203),12,Color.WHITE)
	for i in range(3):
		var x := 254.0+i*120
		var amount := clampf(progress*3-i,0,1) if remaining>0 else 0.0
		game.draw_rect(Rect2(x,222,103,5),Color(accent,.17))
		game.draw_rect(Rect2(x,222,103*amount,5),accent)
		game.japanese(["捕食","分解","同化"][i],Vector2(x,242),10,accent)

extends Node2D

# Temporary story treatment; names and narration are not final canon.
const PAGES = [
	["PROLOGUE / 01", "星が消えた夜", "空が裂けた夜、宇宙はひとつではなくなった。\n昨日まで隣にあった星が、別の世界へ消えていった。"],
	["PROLOGUE / 02", "八つの境界", "重力も、光の速さも、世界ごとに違っていた。\n帰る道を探すには、八つの境界を越えるしかない。"],
	["PROLOGUE / 03", "後席から見た空", "それぞれの世界で、ムゥの後席に乗って操縦を学んだ。\n不安な空にも、頼れる背中があった。"],
	["PROLOGUE / 04", "似た機体、違う力", "よく似た機体から、異なる現象が生まれていた。\n三つの世界の法則が、この空で重なり始める。"],
	["PROLOGUE / 05", "整備室の灯", "よく似た機体でも、世界の法則に合わせて形が違う。\nそれを一つずつ知っていたのが、ムゥだった。"],
	["PROLOGUE / 06", "無線の約束", "飛ぶ場所は、誰かに決められるものじゃない。\n古い整備室で交わした言葉が、今も残っている。"],
	["PROLOGUE / 07", "最後の出撃", "世界を渡るたび、シールドは少しずつ弱くなる。\nそれでも、帰る場所をあきらめるわけにはいかない。"],
	["PROLOGUE / 08", "三つの光", "三機の光が、暗闇へ走り出す。\n今度こそ、この戦いの向こうへ。"]
]
# The spoken lines are v0.1 proposal, not user-approved final script.
# 3 different worldlines have corresponding versions of Mu; this does not
# imply a single Mu necessarily trained every pilot across all worlds.
const DIALOGUES = {
	2: [["ムゥ", "視線は前だ。機体の音を聞いてみろ。"], ["コルミィ", "うん！ もっと速く飛べそう！"]],
	3: [["ジヨーザ", "同じ設計でも、応答が違う。なぜだろう。"], ["ムゥ", "そこに気づいたか。ほうほう。"]],
	4: [["ムゥ", "ここが壊れていた。直せば、まだ飛べる。"], ["マフィオ", "ねえ、これも食べて強くなれる？"]],
	5: [["ムゥ", "飛ぶ場所は、自分たちで決めろ。"], ["三人", "やるっきゃない！"]]
}

var page := 0
var age := 0.0
var clock := 0.0
var finished := false
var font: SystemFont
var planet_tex: ImageTexture
var music: AudioStreamPlayer
var pilot_dialogue_portraits: Dictionary = {}
var opening_backdrop: Texture2D
var test_shot := false
var opening_shot := false
var frames := 0

func _ready():
	DisplayServer.window_set_title("曼珠沙華（MANJUSHAGE）")
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Yu Gothic", "Meiryo", "Noto Sans CJK JP", "Noto Sans JP", "sans-serif"])
	pilot_dialogue_portraits = {
		"コルミィ": pilot_texture_from_file("res://art/active/pilots/cormii_dialogue_pixel_v01.png"),
		"ジヨーザ": pilot_texture_from_file("res://art/active/pilots/jiyoza_dialogue_pixel_v01.png"),
		"マフィオ": pilot_texture_from_file("res://art/active/pilots/mafio_dialogue_pixel_v01.png")
	}
	# OPEN-VIS-001: a user-requested opening illustration. It is retained as a
	# separately versioned source asset and only replaces page 01's backdrop;
	# text, input, music and the later animated prologue pages remain live.
	opening_backdrop = pilot_texture_from_file("res://art/active/cinematics/prologue_rift_pixel_v01.png")
	cache_planet_texture()
	music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = load("res://audio/title.wav")
	music.volume_db = -6
	music.play()
	music.finished.connect(_loop_music)
	for arg in OS.get_cmdline_user_args():
		if arg == "--autotest" or arg.begins_with("--shot="):
			finish()
			return
		if arg == "--story-shot": test_shot = true; page = 1; age = 4.0
		if arg == "--training-shot": test_shot=true;page=2;age=4.0
		if arg == "--workshop-shot": test_shot=true;page=4;age=4.0
		if arg == "--opening-shot": test_shot=true;opening_shot=true;page=0;age=4.0
		# Capture the Cormii dialogue beat without changing the normal prologue.
		if arg == "--pilot-story-shot": test_shot=true;page=2;age=5.0
	queue_redraw()

func pilot_texture_from_file(path:String)->Texture2D:
	if ResourceLoader.exists(path, "Texture2D"):
		return load(path) as Texture2D
	if not FileAccess.file_exists(path):
		return null
	var image=Image.load_from_file(path)
	return ImageTexture.create_from_image(image) if image and not image.is_empty() else null

# Cache the static 163x163 planet once, instead of drawing ~20,000 tiny
# rectangles every frame. All original lighting/detail values are retained.
func cache_planet_texture():
	var image=Image.create(163,163,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	for py in range(-81,82):
		for px in range(-81,82):
			var radius=Vector2(px,py).length()
			if radius>81: continue
			var light=clampf((float(-px-py)+100)/210.0,.05,1.0)
			var col=Color("172945").lerp(Color("7eafb2"),light)
			if sin(py*.17+sin(px*.045)*2)>.6: col=col.lerp(Color("c4c9bb"),.22)
			if radius>78: col=Color("a7d6df").lerp(Color("294b76"),1-light)
			image.set_pixel(px+81,py+81,col)
	planet_tex=ImageTexture.create_from_image(image)

func _loop_music():
	if not finished: music.play()

func _unhandled_input(event):
	if finished: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE: finish()
		elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]: advance()
		elif event.keycode == KEY_M: music.stream_paused = not music.stream_paused
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START: finish()
		elif event.button_index == JOY_BUTTON_A: advance()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance()

func advance():
	if age < 2.5: age = 2.5; return
	page += 1
	age = 0.0
	if page >= PAGES.size(): finish()

func finish():
	if finished: return
	finished = true
	music.stop()
	# Deferred scene transition prevents the skip button reaching the title menu.
	get_tree().change_scene_to_file.call_deferred("res://main.tscn")

func _process(dt):
	if finished: return
	clock += dt
	age += dt
	if age > 8.5: advance()
	queue_redraw()
	frames += 1
	if test_shot and frames == 5:
		# A direct readback keeps the scripted capture from waiting indefinitely on
		# headless render backends that never emit frame_post_draw.
		if DisplayServer.get_name().to_lower() == "headless":
			print("PROLOGUE CAPTURE SKIP: headless viewport has no readable texture; use a normal renderer capture")
			get_tree().quit()
			return
		var texture = get_viewport().get_texture()
		var image = texture.get_image() if texture != null else null
		if image != null:
			var preview_path="opening-preview.png" if opening_shot else ("pilot-story-preview.png" if page==2 and age>=4.25 else "story-preview.png")
			image.save_png("res://"+preview_path)
		get_tree().quit()

func _draw():
	if finished or font == null: return
	var has_opening_backdrop := page == 0 and opening_backdrop != null
	if has_opening_backdrop:
		draw_opening_backdrop()
	else:
		draw_legacy_backdrop()
	if page in [2,3]: draw_training()
	if page in [4,5]: draw_workshop()
	if page>=6:
		for i in range(3):
			var pos=Vector2(95+i*41+sin(clock)*4,130+i*21)
			var hull=PackedVector2Array([pos+Vector2(-20,0),pos+Vector2(-11,-5),pos+Vector2(-6,-13),pos+Vector2(3,-4),pos+Vector2(21,0),pos+Vector2(2,5),pos+Vector2(-8,12)])
			draw_colored_polygon(hull,Color("849db4"))
			draw_line(pos+Vector2(-15,0),pos+Vector2(13,0),Color("e1e8d4"),2)
			draw_rect(Rect2(pos+Vector2(-3,-3),Vector2(6,3)),[Color("6cf1eb"),Color("ffad81"),Color("c8acff")][i])
			draw_line(pos+Vector2(-19,1),pos+Vector2(-32-sin(clock*12)*4,1),Color("ffb474"),3)
	if DIALOGUES.has(page): draw_story_dialogue()
	draw_rect(Rect2(0,252,640,108),Color(.025,.04,.08,.94))
	draw_line(Vector2(28,253),Vector2(612,253),Color("637e9b"))
	var opacity=clampf(age*1.5,0,1)
	draw_string(font,Vector2(30,34),PAGES[page][0],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(.55,.76,.86,opacity))
	draw_string(font,Vector2(30,281),PAGES[page][1],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color(.94,.9,.75,opacity))
	var lines = PAGES[page][2].split("\n")
	for i in range(lines.size()):
		var text=lines[i].substr(0,int(age*22))
		draw_string(font,Vector2(30,307+i*21),text,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("d8e5ee"))
	draw_string(font,Vector2(30,350),"Enter / A：次へ    Esc / Start：スキップ    M：音",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("8ba4be"))
	draw_string(font,Vector2(574,350),str(page+1)+" / "+str(PAGES.size()),HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("8ba4be"))

func draw_opening_backdrop():
	# Preserve the generated pixel clusters with nearest sampling and add only
	# lightweight, live parallax so the opening remains a game scene, not a
	# frozen slide. The lower narrative panel remains deliberately unobstructed.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var drift = Vector2(sin(clock*.23)*1.5, cos(clock*.17)*1.0)
	draw_texture_rect(opening_backdrop,Rect2(Vector2(-3,-2)+drift,Vector2(646,364)),false,Color.WHITE)
	draw_rect(Rect2(0,0,640,252),Color("050817",.14))
	for i in range(12):
		var t=fposmod(clock*.055+i*.137,1.0)
		var pos=Vector2(612-t*505,42+fposmod(i*47+sin(clock+i)*9,174))
		draw_rect(Rect2(pos,Vector2(2 if i%3==0 else 1,1)),Color("f6d89b",.22+.44*(1.0-t)))
	for i in range(6):
		var phase=fposmod(clock*.12+i*.19,1.0)
		var pos=Vector2(548-phase*260,186+sin(clock*1.5+i)*22+i*5)
		var petal=PackedVector2Array([pos+Vector2(-5,0),pos+Vector2(0,-2),pos+Vector2(8,1),pos+Vector2(1,3)])
		draw_colored_polygon(petal,Color("d84862",.2+.38*(1.0-phase)))
	var pulse=.28+.18*(sin(clock*2.2)+1.0)*.5
	draw_arc(Vector2(408,143),52+sin(clock*1.4)*4,-2.75,-.35,22,Color("f0d3ae",pulse),1)

func draw_legacy_backdrop():
	# The later pages retain the original programmatic scenery and its lighter
	# training/workshop overlays.
	for y in range(360):
		var color = Color("090d24").lerp(Color("323354"), float(y)/360.0)
		draw_line(Vector2(0,y),Vector2(640,y),color)
	for layer in range(3):
		for i in range(65):
			var x = fposmod(i*137.0-layer*clock*4.0,640)
			var y = fposmod(i*73.0+layer*39.0,260)
			var glow = 0.4+0.3*sin(clock+i)
			draw_rect(Rect2(x,y,1+int(layer==2),1),Color(.65,.8,1,glow))
	for band in range(9):
		for i in range(24):
			var x = fposmod(i*31.0+band*19-clock*(2+band*.4),740)-50
			var y = 90+band*9+sin(i*.9+band)*13
			draw_rect(Rect2(x,y,34,3),Color(.24,.25+band*.008,.46,.20))
	if planet_tex!=null: draw_texture(planet_tex,Vector2(357,51))
	var crack = PackedVector2Array([Vector2(175,0),Vector2(210,55),Vector2(194,92),Vector2(239,132),Vector2(220,177),Vector2(265,226)])
	draw_polyline(crack,Color(.52,.36,.9,.15),13)
	draw_polyline(crack,Color(.65,.55,1,.7),3)
	draw_polyline(crack,Color("e0d9ff"),1)
	for layer in range(3):
		var points = PackedVector2Array([Vector2(0,270)])
		for i in range(34):
			points.append(Vector2(i*20,220+layer*13-sin(i*.8+layer)*15-sin(i*1.9)*8))
		points.append(Vector2(640,360)); points.append(Vector2(0,360))
		draw_colored_polygon(points,[Color("29334d"),Color("1b273f"),Color("101c31")][layer])


func draw_training():
	# MOV-002: common tandem hull, no unapproved human appearance or gender assignment.
	for i in range(3):
		var pos=Vector2(floor(85+age*13+i*142),103+i*37)
		var col=[Color("f4ac91"),Color("94c9ed"),Color("efdc9d")][i]
		for y in range(-8,9):
			var width=40-abs(y)*3
			draw_rect(Rect2(pos.x-width/2,pos.y+y,width,1),Color("a8bdca") if y<0 else Color("4e607e"))
		draw_rect(Rect2(pos+Vector2(-12,-13),Vector2(7,8)),col)
		draw_rect(Rect2(pos+Vector2(4,-13),Vector2(7,8)),Color("e8eddd"))
		draw_rect(Rect2(pos+Vector2(-30,-2),Vector2(12+int(clock*10)%4,4)),col)
		if page==2:
			draw_string(font,pos+Vector2(-28,27),["コルミィ","ジヨーザ","マフィオ"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("e5e8eb"))
		else:
			for j in range(4):
				var offset=Vector2(38+j*11,sin(clock*4+j)*(8 if i==0 else 2))
				if i==2: offset.x=75-j*11-fposmod(clock*20,11)
				draw_rect(Rect2(pos+offset,Vector2(3,2)),col)


# 0.9 story-vignette treatment: a workshop seen in silhouette only.
# Mu's face, hair, clothes and final voice have deliberately not been fixed.
func draw_workshop():
	draw_rect(Rect2(34,78,563,171),Color("151d35"))
	draw_rect(Rect2(41,84,550,152),Color("253046"))
	for i in range(11):
		var x=56+i*51
		draw_line(Vector2(x,84),Vector2(x,231),Color("344057"),1)
	draw_rect(Rect2(58,107,264,100),Color("121f37"))
	draw_rect(Rect2(62,111,256,92),Color("213d56"))
	# Holographic maintenance diagram; pulses with a gentle breathing glow.
	var breath=.55+.4*sin(clock*1.6)
	draw_line(Vector2(79,153),Vector2(295,153),Color(.21,.78,.90,breath),1)
	draw_circle(Vector2(196,150),43,Color("183550"))
	draw_arc(Vector2(196,150),40,0,TAU,36,Color(.38,.88,.96,breath),2)
	for i in range(3):
		var x=140+i*49
		var y=140+sin(clock*2.0+i)*5
		var c=[Color("f38c91"),Color("88d4fc"),Color("efc579")][i]
		draw_colored_polygon(PackedVector2Array([Vector2(x-16,y),Vector2(x-3,y-7),Vector2(x+15,y),Vector2(x-4,y+7)]),c.darkened(.38))
		draw_line(Vector2(x-12,y),Vector2(x+12,y),c,2)
	draw_rect(Rect2(354,183,200,43),Color("101727"))
	draw_rect(Rect2(354,183,200,3),Color("ac6477"))
	for j in range(9):
		draw_rect(Rect2(365+j*20,197,11,3),Color("2c5668"))
		draw_rect(Rect2(368+j*20,202,5,2),Color("75c3ce") if j%3==0 else Color("536375"))
	# Engineer: back-facing silhouette with animated tools, no confirmed portrait.
	var shoulder=Vector2(468+sin(clock*1.3)*1.5,151)
	draw_colored_polygon(PackedVector2Array([shoulder+Vector2(-27,14),shoulder+Vector2(-20,-9),shoulder+Vector2(17,-9),shoulder+Vector2(29,14),shoulder+Vector2(35,72),shoulder+Vector2(-32,72)]),Color("394254"))
	draw_circle(shoulder+Vector2(0,-15),17,Color("232b3c"))
	draw_rect(Rect2(shoulder+Vector2(-17,-21),Vector2(35,4)),Color("687d8c"))
	draw_line(shoulder+Vector2(-23,27),Vector2(409,202),Color("657889"),7)
	draw_line(Vector2(409,202),Vector2(393+sin(clock*4)*2,198),Color("afc6bb"),2)
	for k in range(7):
		var x=390+float(k*5)
		var y=186+sin(clock*3+k*2)*10
		draw_rect(Rect2(x,y,2,2),Color(1,.76,.47,.3+.5*absf(sin(clock*2+k))))
	draw_string(font,Vector2(63,99),"ANALYSIS / 3 WORLDLINES",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("87cde1"))

func draw_story_dialogue():
	var index=0 if age < 4.25 else 1
	var entry=DIALOGUES[page][index]
	var local_age=age if index==0 else age-4.25
	var letters=maxi(0,int((local_age-.35)*23))
	var dialogue=entry[1].substr(0,letters)
	var reveal=clampf(local_age*2.0,0,1)
	draw_story_pilot_portrait(str(entry[0]),reveal)
	draw_rect(Rect2(62,209,518,37),Color(.025,.055,.115,.83*reveal))
	draw_rect(Rect2(62,209,3,37),Color(.95,.48,.51,.87*reveal))
	draw_string(font,Vector2(77,224),entry[0],HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(.95,.68,.54,reveal))
	draw_string(font,Vector2(143,232),dialogue,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color(.95,.94,.87,reveal))
	if int(clock*2)%2==0 and letters>=entry[1].length():
		draw_rect(Rect2(555,232,7,2),Color(.91,.76,.54,reveal))

# STORY-VIS-001 — show the same active pixel portraits during the relevant
# dialogue beats without assigning a portrait to Mu or Kuu.
func draw_story_pilot_portrait(speaker:String,reveal:float):
	var portrait: Texture2D = pilot_dialogue_portraits.get(speaker)
	if portrait == null: return
	var panel=Rect2(468,49,139,144)
	draw_rect(panel,Color(.025,.055,.115,.72*reveal))
	draw_rect(panel,Color(.75,.83,1,.58*reveal),false,1)
	var source_size=portrait.get_size()
	var scale=minf(130.0/source_size.x,136.0/source_size.y)
	var portrait_size=source_size*scale
	var target=Rect2(panel.get_center()-portrait_size*.5,portrait_size)
	draw_texture_rect(portrait,target,false,Color(1,1,1,reveal))


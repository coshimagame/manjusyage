extends Node2D

# Temporary story treatment; names and narration are not final canon.
const PAGES = [
	["PROLOGUE / 01", "星が消えた夜", "空が裂けた夜、宇宙はひとつではなくなった。\n昨日まで隣にあった星が、別の世界へ消えていった。"],
	["PROLOGUE / 02", "八つの境界", "重力も、光の速さも、世界ごとに違っていた。\n帰る道を探すには、八つの境界を越えるしかない。"],
	["PROLOGUE / 03", "覚えている敵", "境界の番人は、私たちを知っていた。\nまだ出会っていないはずなのに。"],
	["PROLOGUE / 04", "消えなかった記憶", "『その武器で、また私を倒すつもりか。』\n繰り返す世界で、敵だけが前の戦いを覚えていた。"],
	["PROLOGUE / 05", "最後の出撃", "世界を渡るたび、シールドは少しずつ弱くなる。\nそれでも、帰る場所をあきらめるわけにはいかない。"],
	["PROLOGUE / 06", "三つの光", "三機の光が、暗闇へ走り出す。\n今度こそ、この戦いの向こうへ。"]
]
var page := 0
var age := 0.0
var clock := 0.0
var finished := false
var font: SystemFont
var music: AudioStreamPlayer
var test_shot := false
var frames := 0

func _ready():
	DisplayServer.window_set_title("曼珠沙華（MANJUSHAGE）")
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Yu Gothic", "Meiryo", "sans-serif"])
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
	queue_redraw()

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
		await RenderingServer.frame_post_draw
		var image = get_viewport().get_texture().get_image()
		image.save_png("res://story-preview.png")
		get_tree().quit()

func _draw():
	if finished or font == null: return
	# 16-bit-inspired palette ramps and multilayer pixel scenery, no external art.
	for y in range(360):
		var color = Color("090d24").lerp(Color("323354"), float(y)/360.0)
		draw_line(Vector2(0,y),Vector2(640,y),color)
	for layer in range(3):
		for i in range(65):
			var x = fposmod(i*137.0-layer*clock*4.0,640)
			var y = fposmod(i*73.0+layer*39.0,260)
			var glow = 0.4+0.3*sin(clock+i)
			draw_rect(Rect2(x,y,1+int(layer==2),1),Color(.65,.8,1,glow))
	# Cloud bands separated by palette and parallax.
	for band in range(9):
		for i in range(24):
			var x = fposmod(i*31.0+band*19-clock*(2+band*.4),740)-50
			var y = 90+band*9+sin(i*.9+band)*13
			draw_rect(Rect2(x,y,34,3),Color(.24,.25+band*.008,.46,.20))
	# Shaded planet with atmospheric rim and cloud stripes.
	var center = Vector2(438,132)
	for py in range(-81,82):
		for px in range(-81,82):
			var radius = Vector2(px,py).length()
			if radius > 81: continue
			var light = clampf((float(-px-py)+100)/210,0.05,1)
			var c = Color("172945").lerp(Color("7eafb2"),light)
			if sin(py*.17+sin(px*.045)*2)>0.6: c=c.lerp(Color("c4c9bb"),.22)
			if radius>78: c=Color("a7d6df").lerp(Color("294b76"),1-light)
			draw_rect(Rect2(center+Vector2(px,py),Vector2.ONE),c)
	# Fracture through the horizon.
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
	if page>=4:
		for i in range(3):
			var pos=Vector2(95+i*41+sin(clock)*4,130+i*21)
			var hull=PackedVector2Array([pos+Vector2(-20,0),pos+Vector2(-11,-5),pos+Vector2(-6,-13),pos+Vector2(3,-4),pos+Vector2(21,0),pos+Vector2(2,5),pos+Vector2(-8,12)])
			draw_colored_polygon(hull,Color("849db4"))
			draw_line(pos+Vector2(-15,0),pos+Vector2(13,0),Color("e1e8d4"),2)
			draw_rect(Rect2(pos+Vector2(-3,-3),Vector2(6,3)),[Color("6cf1eb"),Color("ffad81"),Color("c8acff")][i])
			draw_line(pos+Vector2(-19,1),pos+Vector2(-32-sin(clock*12)*4,1),Color("ffb474"),3)
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
	draw_string(font,Vector2(574,350),str(page+1)+" / 6",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("8ba4be"))

extends RefCounted

# Scenery uses only the landscape strip of each supplied concept-board row.
const RED := Rect2(186, 2, 628, 112)
const SEA := Rect2(186, 121, 628, 112)
const VENTS := [Vector2(490, 300), Vector2(360, 77)]
const SURGES := [10.5, 19.0]
const WARNING := 1.6
const SEA_ENEMIES := ["EN201", "EN202", "EN203", "EN204"]
const MOTION_PROFILES := {"EN201":"EN006", "EN202":"EN002", "EN203":"EN009", "EN204":"EN004"}
const CROPS := {"EN201":Rect2(16,44,83,66), "EN202":Rect2(8,36,114,74), "EN203":Rect2(20,46,89,63), "EN204":Rect2(13,34,96,75), "BB02":Rect2(10,72,238,108)}

static func draw_landscape(g, board:Texture2D, ocean:bool):
	var t:float = g.elapsed
	var diving:bool = g.vertical.active
	var chamber := smoothstep(44.0, 55.0, t)
	var depth := smoothstep(4.0, 24.0, t)
	var source := SEA if ocean else RED
	var scroll := t * (8.0 if ocean else 11.0)
	var breath := sin(t * (1.3 if ocean else 2.3))
	# A distant plane keeps its full silhouette. The moving strips sample a
	# mirrored panorama, so refraction never wraps via the labels on the board.
	var tint := Color(.50,.64,.78) if ocean else Color(.76,.53,.58)
	if not ocean: tint.a=smoothstep(3.0,16.0,t)
	if board and tint.a>0:
		for y in range(46, 338, 4):
			var v := (y-46.0)/292.0
			var displacement := sin(v*15.0+t*1.6)*2.5 if ocean else sin(v*8.0+t)*1.0
			var width := 1256.0 if ocean else 1080.0
			var offset := fposmod(scroll + displacement, width*2)
			var start := 0.0
			while start < 640:
				var u := fposmod(start+offset,width*2)
				var mirror := u>=width
				var span := minf(640.0-start, (width*2 if mirror else width)-u)
				if span<.01: break
				var sx := width*2-u-span if mirror else u
				var sy := source.position.y+clampf(v*101.0+4.0+breath*1.2+(sin(t*.6)*3 if diving else 0),0,109)
				var dst := Rect2(start,y,span,4)
				if mirror:
					g.draw_set_transform(Vector2(2*start+span,0),0,Vector2(-1,1))
				g.draw_texture_rect_region(board,dst,Rect2(source.position.x+sx/width*source.size.x,sy,span/width*source.size.x,2.2),tint)
				if mirror: g.draw_set_transform(Vector2.ZERO)
				start+=span
	# Quiet midwater preserves silhouettes of hostile shots and rescue pods.
	g.draw_rect(Rect2(0,47,640,290),Color("080c24",.24 if ocean else .31))
	if ocean:
		draw_water(g,t,depth)
	else:
		draw_membrane(g,t,chamber,diving)

static func draw_membrane(g,t:float,chamber:float,diving:bool):
	var growth := smoothstep(4.0,24.0,t)
	var pulse := pow(maxf(0,cos(t*2.4)),5)
	for side in [-1,1]:
		for i in range(8):
			var x := fposmod(i*104.0-t*24,832)-98
			var root := Vector2(x,48 if side<0 else 335)
			var length := (12+growth*(18+14*sin(i*1.7))+chamber*15)*(1+.12*pulse)
			var spine := PackedVector2Array()
			for j in range(10):
				var u := j/9.0
				var p := root+Vector2(u*(62+8*sin(t*.65+i))+sin(u*PI)*13, -side*length*sin(u*PI*.8))
				if diving: p=Vector2(16+(p.y-46)*.36 if side<0 else 623-(336-p.y)*.36, fposmod(i*61.0+g.vertical.age*52+j*4,380)-18)
				spine.append(p.round())
			g.draw_polyline(spine,Color("271529"),8)
			g.draw_polyline(spine,Color("774153"),3)
			g.draw_line(spine[2],spine[5],Color("be696e").lerp(Color("e7a085"),pulse*.55),1)
	if chamber>.01:
		# A pair of branching vessels converge on the boss chamber. Their pulse
		# follows the actual boss cooldown once the core begins firing.
		# The two valves close around the heart. Breaking the armor opens the
		# matching half, and the scenery falls dark during the death sequence.
		var center:=Vector2(492,184)
		for side in range(2):
			var open:bool=not g.boss.is_empty() and g.bio.armor.size()==2 and g.bio.armor[side]<=0
			var stretch:=1.24 if open else 1.0
			var shell:=PackedVector2Array()
			for j in range(21):
				var angle:=PI*side+PI*j/20
				shell.append((center+Vector2(cos(angle)*(100+pulse*5),sin(angle)*(87+9*pulse)*stretch)).round())
			g.draw_polyline(shell,Color("331626",chamber*.85),10)
			g.draw_polyline(shell,Color("a24e67",chamber*(.23 if open else .70)),3)
		var charge := clampf((.8-float(g.boss.get("cool",2.0)))/.8,0,1)
		for side in [-1,1]:
			for n in range(3):
				var points := PackedVector2Array()
				for j in range(27):
					var u:=j/26.0
					points.append(Vector2(j*25, (65 if side<0 else 318)-side*(10+n*6)*sin(u*PI*3+t*.55+n)-side*34*pow(u,3)).round())
				g.draw_polyline(points,Color("401c37",chamber*.9),5)
				g.draw_polyline(points,Color("cc6978",chamber*(.15+.56*charge)),1)

static func draw_water(g,t:float,depth:float):
	for i in range(6):
		var x:=fposmod(i*139+t*4,830)-125
		var sway:=sin(t*.36+i)*15
		var beam:=PackedVector2Array([Vector2(x,47),Vector2(x+8,47),Vector2(x-52+sway,250+depth*32),Vector2(x-81+sway,250+depth*32)])
		g.draw_colored_polygon(beam,Color(.30,.73,.85,.075-depth*.032))
	# The sunken arches pass across the path in the second half of the descent.
	# Their ribs and missing stones form one landmark with perspective.
	var ruin:=smoothstep(10.0,20.0,t)
	if ruin>0:
		for i in range(3):
			var x:=730.0-fmod(maxf(0,t-10)*16.0,940.0)+i*80
			var base:=Vector2(x,284+i*9)
			var arch:=PackedVector2Array()
			for j in range(18):
				var angle:=PI+PI*j/17.0
				arch.append((base+Vector2(cos(angle)*54,sin(angle)*95)).round())
			g.draw_polyline(arch,Color("10233a",ruin*.92),11)
			g.draw_polyline(arch,Color("397386",ruin*.68),2)
			for j in [2,5,9,13,16]:
				g.draw_line(arch[j],arch[j]+Vector2(0,5),Color("7d99a7",ruin*.62),2)
			for edge in [arch[0],arch[-1]]:
				g.draw_rect(Rect2(edge,Vector2(8,58)),Color("14263c",ruin*.9))
	for i in range(5):
		var x:=fposmod(i*163.0-t*14.0,815.0)-90.0
		var base:=Vector2(x,345+sin(i)*8)
		var height:= (29+i%3*9)*(1.0+depth*.64)
		for branch in range(3):
			var points:=PackedVector2Array()
			for j in range(10):
				var u:=j/9.0
				points.append((base+Vector2((branch-1)*u*u*22+sin(u*3.8+t*.9+i)*u*9,-height*u)).round())
			g.draw_polyline(points,Color("153447"),5)
			g.draw_polyline(points,Color("54738a"),1)
	for i in range(21):
		var pos:=Vector2(fposmod(i*91.0-t*8+sin(t+i)*3,640),335-fposmod(i*37+t*(8+i%4),285)).round()
		g.draw_line(pos,pos+Vector2(1,-2),Color(.48,.73,.80,.45))
	for i in range(VENTS.size()):
		var lead:float=SURGES[i]-t
		if lead<-.38 or lead>WARNING: continue
		var strength:=clampf(1.0-lead/WARNING,0,1)
		var vent:Vector2=VENTS[i]
		for lane in plume_lanes(i):
			g.draw_line(vent,vent+lane*(12+strength*54),Color(.39,.88,1,.16+.56*strength),1)
		g.draw_arc(vent,18-strength*11,0,TAU,24,Color(.7,1,1,.85),2)

static func plume_lanes(index:int)->Array[Vector2]:
	var lanes:Array[Vector2]=[]
	var axis:float= -PI*.67 if index==0 else PI*.75
	for j in range(-2,3): lanes.append(Vector2.from_angle(axis+j*.21))
	return lanes

static func tide(g,previous:float):
	for i in range(SURGES.size()):
		if previous < SURGES[i] and g.elapsed>=SURGES[i]:
			for lane in plume_lanes(i):
				g.shots.append({"pos":VENTS[i],"vel":lane*64,"r":3,"form":"bubble","tide":true})

static func boss_lanes(volley:int)->Array[Vector2]:
	var lanes:Array[Vector2]=[]
	if volley%3!=0:
		for j in range(-2,3):
			lanes.append(Vector2.from_angle(PI+j*.22+sin(float(volley))*.19))
	else:
		var gap:=PI+sin(volley*.65)*.60
		for j in range(16):
			var angle:=j*TAU/16+volley*.11
			if absf(angle_difference(gap,angle))>.43: lanes.append(Vector2.from_angle(angle))
	return lanes

static func draw_guardian(g,texture:Texture2D):
	var p:Vector2=g.boss.pos
	var charge:=clampf((.9-float(g.boss.cool))/.9,0,1)
	var muzzle:=p+Vector2(-34,0)
	if charge>0:
		for lane in boss_lanes(g.boss.volleys+1):
			g.draw_line(muzzle+lane*8,muzzle+lane*(12+charge*56),Color(.57,.89,1,charge*.66),1)
	var size:=Vector2(168,80+sin(g.boss.age*2.6)*5)
	g.draw_texture_rect(texture,Rect2(p-size*.5,size),false,Color(1,.8,.9) if g.boss.flash>0 else Color.WHITE)
	g.draw_arc(p,13,0,TAU,20,g.COLORS[g.boss.color],2)
	g.draw_rect(Rect2(225,55,188,3),Color("18233c"))
	g.draw_rect(Rect2(225,55,188*clampf(g.boss.hp/g.boss.max,0,1),3),Color("8cd8f0"))

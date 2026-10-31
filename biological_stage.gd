extends RefCounted

# BIO-001: playable design experiment, not final creature/character canon.
var organs: Array = []
var next_organ := 700.0
var armor: Array = []

func reset():
	organs.clear()
	armor.clear()
	next_organ=700.0

func ceiling(x: float, distance: float, time: float) -> float:
	return 65+sin((x+distance*.4)*.014)*13+sin(time*1.7)*5

func floor_y(x: float, distance: float, time: float) -> float:
	return 298+sin((x+distance*.4)*.012+2)*12-sin(time*1.7)*5

func update(g, dt):
	if g.gate>0 or not g.boss.is_empty():
		organs.clear()
		return
	if g.travel<500: return
	if g.travel>=next_organ:
		var upper=int(next_organ/600)%2==1
		organs.append({"pos":Vector2(660,108 if upper else 255),"upper":upper,"hp":6+g.count*2,"cool":1.5,"flash":0.0})
		next_organ+=600
	for organ in organs:
		organ.pos.x-=dt*44
		organ.cool-=dt; organ.flash=maxf(0,organ.flash-dt)
		if organ.cool<=0 and organ.pos.x<610:
			organ.cool=2.8
			var direction=(g.players[0].pos-organ.pos).normalized()
			g.shots.append({"pos":organ.pos,"vel":direction*75,"r":3})
		for bullet in g.bullets:
			if bullet.pos.distance_to(organ.pos)<22 and organ.hp>0:
				organ.hp-=1; organ.flash=.08; bullet.pos.x=800; g.sfx("hit")
		for pilot in g.players:
			if pilot.down==0 and pilot.pos.distance_to(organ.pos)<23: g.hurt(pilot)
		if organ.hp<=0:
			g.explode(organ.pos,Color("ff7185"),28)
			g.sfx("burst")
			g.score+=300
			g.pickups.append({"pos":organ.pos,"kind":1})
	organs=organs.filter(func(o): return o.hp>0 and o.pos.x> -40)
	for pilot in g.players:
		if pilot.down==0 and (pilot.pos.y<ceiling(pilot.pos.x,g.travel,g.clock)+6 or pilot.pos.y>floor_y(pilot.pos.x,g.travel,g.clock)-6):
			g.hurt(pilot)

func begin_boss(count):
	organs.clear()
	armor=[18+count*6,18+count*6]

func part_pos(g, index):
	return g.boss.pos+Vector2(-27,-57 if index==0 else 57)

func damage_part(g, index, amount):
	if armor[index]<=0: return
	armor[index]=maxi(0,armor[index]-amount)
	if armor[index]==0:
		g.explode(part_pos(g,index),Color("ff8c79"),45)
		g.sfx("burst"); g.shake=5

func intercept(g, bullet) -> bool:
	for i in range(armor.size()):
		if armor[i]>0 and bullet.pos.distance_to(part_pos(g,i))<27:
			damage_part(g,i,1)
			bullet.pos.x=800
			g.sfx("hit")
			return true
	return false

func exposed() -> bool:
	return armor.size()==2 and armor[0]<=0 and armor[1]<=0

# BIO VFX v0.9: pale-red lilies are scenery, never hitboxes or bullets.
# Draw them behind combat, using only original vector/pixel geometry.
func draw_spider_lily(g, pos: Vector2, radius: float, opacity: float):
	var stem=Color(0.49,0.23,0.35,opacity*.55)
	var petal=Color(0.97,0.28,0.43,opacity)
	var edge=Color(1.0,0.61,0.56,opacity*.65)
	g.draw_line(pos+Vector2(0,radius*1.7),pos,stem,1)
	for i in range(6):
		var a=-PI*.91+float(i)*PI*.165
		var tip=pos+Vector2(cos(a)*radius,sin(a)*radius*.67)
		var bend=pos+Vector2(cos(a)*radius*.48-4,sin(a)*radius*.55-5)
		g.draw_polyline(PackedVector2Array([pos,bend,tip,tip+Vector2(3,-5)]),petal,2)
		g.draw_line(bend+Vector2(-1,-1),tip,edge,1)
	for i in range(7):
		var spread=float(i-3)
		var end=pos+Vector2(spread*radius*.31,-radius*(1.0-absf(spread)*.08))
		var bend=pos+Vector2(spread*radius*.19,-radius*.47)
		g.draw_polyline(PackedVector2Array([pos,bend,end]),edge,1)
		g.draw_circle(end,1.5,Color(1.0,.77,.48,opacity*.75))
	g.draw_circle(pos,3.5,Color(.82,.16,.30,opacity*.9))

func draw_background(g):
	# Deep space / dusty crimson atmosphere. No repetitive neon wire circles.
	for y in range(33,338,2):
		var blend=float(y-33)/305.0
		var col=Color("090e20").lerp(Color("291326"),blend)
		g.draw_rect(Rect2(0,y,640,2),col)
	# Three depths of small, static-to-slow-moving cosmic dust.
	for i in range(80):
		var depth=float(i%3+1)
		var sx=floor(fposmod(float(i*89)-g.travel*(.015+.013*depth),680.0)-20)
		var sy=47+float((i*67)%270)
		var light=Color(.42,.50,.65,.17) if depth<2 else Color(.89,.66,.70,.37)
		g.draw_rect(Rect2(sx,sy,1 if depth<3 else 2,1),light)
	# Dark distant tissue strata and diagonal light veins.
	for i in range(12):
		var x=floor(fposmod(i*83-g.travel*.09,790)-80)
		var offset=sin(float(i)*1.6)*22
		var body=PackedVector2Array([Vector2(x-17,338),Vector2(x+22,211+offset),Vector2(x+40,197+offset),Vector2(x+64,338)])
		g.draw_colored_polygon(body,Color(.14,.12,.21,.72))
		g.draw_line(Vector2(x+24,215+offset),Vector2(x+46,326),Color(.35,.17,.28,.25),2)
	# Spider-lily silhouettes: recognizable petals, long stamens, dark enough
	# that magenta enemy projectiles retain the strongest local contrast.
	for i in range(9):
		var x=floor(fposmod(float(i)*119-g.travel*.17,820.0)-95)
		var y=110+float((i*53)%155)
		var size=float(21+(i%4)*7)
		draw_spider_lily(g,Vector2(x,y),size,.22 if i%3==0 else .13)
	if g.travel<500 and g.mode!="menu": return
	# Keep ceiling/floor exactly aligned with the existing damage geometry.
	for x in range(0,640,4):
		var top=ceiling(x,g.travel,g.clock)
		var bottom=floor_y(x,g.travel,g.clock)
		g.draw_rect(Rect2(x,33,4,top-33),Color("532538"))
		g.draw_rect(Rect2(x,top-10,4,10),Color("a34a5d"))
		g.draw_rect(Rect2(x,top-3,4,3),Color("f69a81"))
		g.draw_rect(Rect2(x,bottom,4,338-bottom),Color("532538"))
		g.draw_rect(Rect2(x,bottom,4,3),Color("f69a81"))
		g.draw_rect(Rect2(x,bottom+3,4,7),Color("a34a5d"))
	# Articulated ribs and bioluminescent veins along the safe area edges.
	for i in range(14):
		var x=floor(fposmod(float(i)*63-g.travel*.44,800.0)-90)
		for side in [0,1]:
			var upper=side==0
			var border=ceiling(x,g.travel,g.clock) if upper else floor_y(x,g.travel,g.clock)
			var direction=1 if upper else -1
			var root=Vector2(x,border)
			var rib=Vector2(x+22,border+direction*17)
			g.draw_line(root,rib,Color("311b33"),6)
			g.draw_line(root+Vector2(0,direction*2),rib,Color("cb6876"),2)
			g.draw_rect(Rect2(x+13,border+direction*13,3,3),Color("ffd0a2"))

func draw_organs(g):
	for organ in organs:
		var p=organ.pos
		var anchor=Vector2(p.x,ceiling(p.x,g.travel,g.clock) if organ.upper else floor_y(p.x,g.travel,g.clock))
		g.draw_line(anchor,p,Color("9f4966"),9)
		g.draw_line(anchor+Vector2(-2,0),p+Vector2(-2,0),Color("e08187"),2)
		g.draw_circle(p,21,Color("542d4e"))
		g.draw_circle(p+Vector2(-3,-3),16,Color("b65070"))
		g.draw_circle(p+Vector2(-7,-3),8,Color("fff1d0") if organ.flash>0 else Color("f7aa7c"))

func draw_boss(g):
	var p=g.boss.pos
	var pulse=1+sin(g.boss.age*3.4)*.035
	for side in [-1,1]:
		var points=PackedVector2Array()
		for j in range(15):
			points.append(p+Vector2(30-j*6,side*(43+sin(j*.27+g.boss.age)*20)))
		g.draw_polyline(points,Color("6b3455"),12)
		g.draw_polyline(points,Color("d26a7c"),3)
	# Layered pixel strips form two lobes and a tapering heart, with a lit left rim.
	for row in range(-49,56,2):
		var half=0.0
		if row< -13:
			half=28+sqrt(maxf(0,27*27-(row+25)*(row+25)))
		else:
			half=53*(56.0-row)/69.0
		var shade=Color("682d51").lerp(Color("d36b7e"),1.0-float(row+49)/120)
		g.draw_rect(Rect2(p.x-half*pulse,p.y+row*pulse,half*2*pulse,3),shade)
		g.draw_rect(Rect2(p.x-half*pulse+3,p.y+row*pulse,4,2),Color("f7a598"))
		g.draw_rect(Rect2(p.x+half*pulse-7,p.y+row*pulse,7,3),Color("703451"))
	g.draw_line(p+Vector2(-2,-48),p+Vector2(-2,-29),Color("422540"),5)
	for i in range(6):
		g.draw_line(p+Vector2(i*7-26,-25),p+Vector2(i*4-18,23),Color("6e3153"),2)
	var core=g.COLORS[g.boss.color] if exposed() else Color("796285")
	g.draw_circle(p+Vector2(-11,0),19,Color("34233f"))
	g.draw_circle(p+Vector2(-12,-2),12,Color("fff3d6") if g.boss.flash>0 else core)
	for i in range(armor.size()):
		if armor[i]<=0: continue
		var a=part_pos(g,i)
		g.draw_circle(a,27,Color("482b45"))
		g.draw_circle(a+Vector2(-2,-3),22,Color("b06b83"))
		g.draw_arc(a,18,PI*.8,PI*1.8,16,Color("f4b2ac"),3)
		g.draw_circle(a+Vector2(-8,0),7,Color("f8d39c"))
	g.japanese("外殻を2つ破壊 → 同色でコアを狙う" if not exposed() else "コア露出：色を合わせて攻撃",Vector2(210,75),13,Color("ffc7b8"))
	g.draw_rect(Rect2(193,83,360,4),Color("43233c"))
	g.draw_rect(Rect2(193,83,360*maxf(0,g.boss.hp)/g.boss.max,4),core)

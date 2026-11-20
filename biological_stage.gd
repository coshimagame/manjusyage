extends RefCounted

# BIO-001: playable design experiment, not final creature/character canon.
var organs: Array = []
var next_organ := 700.0
var tendrils: Array = []
var next_tendril := 620.0
var armor: Array = []
var recoil := [0.0,0.0]
const RECOIL_TIME := 3.0

func reset():
	organs.clear()
	tendrils.clear()
	armor.clear()
	recoil=[0.0,0.0]
	next_organ=700.0
	next_tendril=620.0

func ceiling(x: float, distance: float, time: float) -> float:
	return 65+sin((x+distance*.4)*.014)*13+sin(time*1.7)*5-11*recoil[0]/RECOIL_TIME

func floor_y(x: float, distance: float, time: float) -> float:
	return 298+sin((x+distance*.4)*.012+2)*12-sin(time*1.7)*5+11*recoil[1]/RECOIL_TIME

func update(g, dt):
	for i in range(2): recoil[i]=maxf(0,recoil[i]-dt)
	if g.gate>0 or not g.boss.is_empty():
		organs.clear()
		tendrils.clear()
		return
	if g.travel<500: return
	if g.travel>=next_organ:
		var upper=int(next_organ/600)%2==1
		organs.append({"pos":Vector2(660,108 if upper else 255),"upper":upper,"hp":6+g.count*2,"cool":1.5,"flash":0.0})
		next_organ+=600
	if g.travel>=next_tendril:
		var tendril_upper=int(next_tendril/460)%2==0
		tendrils.append({"x":672.0,"upper":tendril_upper,"age":0.0,"phase":float(tendrils.size())*.83,"fired":false})
		next_tendril+=460
	for tendril in tendrils:
		tendril.x-=dt*52.0
		tendril.age+=dt
		# The wall grows first, holds a bright readably telegraphed bud, then
		# releases one slow spore. It uses the existing enemy-shot path and never
		# changes the solid ceiling/floor or player save data.
		if not tendril.fired and tendril.age>=1.28 and tendril.x<600:
			var live_players=g.players.filter(func(p): return p.down==0)
			if not live_players.is_empty() and recoil[0 if tendril.upper else 1]<=0:
				var tip=tendril_tip(g,tendril)
				var target=live_players[0]
				g.shots.append({"pos":tip,"vel":(target.pos-tip).normalized()*80.0,"r":3,"form":"spore","bio_tendril":true})
			tendril.fired=true
	tendrils=tendrils.filter(func(t): return t.x>-80 and t.age<8.0)
	for organ in organs:
		organ.pos.x-=dt*44
		organ.cool-=dt; organ.flash=maxf(0,organ.flash-dt)
		if organ.cool<=0 and organ.pos.x<610:
			organ.cool=2.8
			var direction=(g.players[0].pos-organ.pos).normalized()
			g.shots.append({"pos":organ.pos,"vel":direction*75,"r":3})
		for bullet in g.bullets:
			if bullet.pos.distance_to(organ.pos)<22 and organ.hp>0:
				g.visual.hit(bullet.pos)
				organ.hp-=1; organ.flash=.08; bullet.pos.x=800; g.sfx("hit")
		for pilot in g.players:
			if pilot.down==0 and pilot.pos.distance_to(organ.pos)<23: g.hurt(pilot)
		if organ.hp<=0:
			if g.slice_mode and g.art_v09: recoil[0 if organ.upper else 1]=RECOIL_TIME
			g.explode(organ.pos,Color("ff7185"),28)
			g.sfx("burst")
			g.score+=300
			g.pickups.append({"pos":organ.pos,"kind":1})
	organs=organs.filter(func(o): return o.hp>0 and o.pos.x> -40)
	for pilot in g.players:
		if pilot.down==0 and (pilot.pos.y<ceiling(pilot.pos.x,g.travel,g.clock)+6 or pilot.pos.y>floor_y(pilot.pos.x,g.travel,g.clock)-6):
			g.hurt(pilot)

func tendril_anchor(g, tendril) -> Vector2:
	return Vector2(tendril.x,ceiling(tendril.x,g.travel,g.clock) if tendril.upper else floor_y(tendril.x,g.travel,g.clock))

func tendril_tip(g, tendril) -> Vector2:
	var inward=1.0 if tendril.upper else -1.0
	var reach=clampf(tendril.age/1.05,0.0,1.0)*(1.0-.8*clampf(recoil[0 if tendril.upper else 1],0,1))
	var sway=sin(tendril.age*5.0+tendril.phase)*8.0
	return tendril_anchor(g,tendril)+Vector2(sway,inward*(22.0+48.0*reach))

func begin_boss(count):
	organs.clear()
	tendrils.clear()
	recoil=[0.0,0.0]
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
			g.visual.hit(bullet.pos)
			damage_part(g,i,1)
			bullet.pos.x=800
			g.sfx("hit")
			return true
	return false

func exposed() -> bool:
	return armor.size()==2 and armor[0]<=0 and armor[1]<=0

func draw_background(g):
	for y in range(33,338):
		g.draw_line(Vector2(0,y),Vector2(640,y),Color("100f29").lerp(Color("341b38"),float(y)/338))
	for i in range(28):
		var x=fposmod(i*71-g.travel*.17,720)-40
		var y=85+(i*43)%185
		g.draw_arc(Vector2(x,y),18+(i%4)*8,0,TAU,20,Color("562c4c"),2)
		g.draw_arc(Vector2(x-3,y-2),13+(i%4)*8,PI,TAU,16,Color("76405a"),1)
	if g.travel<500 and g.mode!="menu": return
	for x in range(0,640,4):
		var top=ceiling(x,g.travel,g.clock)
		var bottom=floor_y(x,g.travel,g.clock)
		g.draw_rect(Rect2(x,33,4,top-33),Color("632b46"))
		g.draw_rect(Rect2(x,top-8,4,5),Color("ae5265"))
		g.draw_rect(Rect2(x,top-3,4,3),Color("ed8d86"))
		g.draw_rect(Rect2(x,bottom,4,338-bottom),Color("632b46"))
		g.draw_rect(Rect2(x,bottom,4,3),Color("ed8d86"))
		g.draw_rect(Rect2(x,bottom+3,4,5),Color("ae5265"))
	for i in range(12):
		var x=fposmod(i*61-g.travel*.4,730)-40
		for side in [0,1]:
			var y=ceiling(x,g.travel,g.clock)-12 if side==0 else floor_y(x,g.travel,g.clock)+12
			g.draw_line(Vector2(x,y),Vector2(x+22,y-8 if side==0 else y+8),Color("db6982"),2)

func draw_organs(g):
	for organ in organs:
		var p=organ.pos
		var anchor=Vector2(p.x,ceiling(p.x,g.travel,g.clock) if organ.upper else floor_y(p.x,g.travel,g.clock))
		g.draw_line(anchor,p,Color("9f4966"),9)
		g.draw_line(anchor+Vector2(-2,0),p+Vector2(-2,0),Color("e08187"),2)
		g.draw_circle(p,21,Color("542d4e"))
		g.draw_circle(p+Vector2(-3,-3),16,Color("b65070"))
		g.draw_circle(p+Vector2(-7,-3),8,Color("fff1d0") if organ.flash>0 else Color("f7aa7c"))

func draw_tendrils(g):
	for tendril in tendrils:
		var anchor=tendril_anchor(g,tendril)
		var tip=tendril_tip(g,tendril)
		var inward=1.0 if tendril.upper else -1.0
		var points=PackedVector2Array([anchor])
		for i in range(1,7):
			var ratio=float(i)/6.0
			points.append(anchor.lerp(tip,ratio)+Vector2(sin(tendril.age*5.0+i*1.7+tendril.phase)*5.0*ratio,inward*sin(ratio*PI)*6.0))
		g.draw_polyline(points,Color("4b233d"),11)
		g.draw_polyline(points,Color("9f4966"),6)
		g.draw_polyline(points,Color("e08187"),2)
		var telegraph=clampf((tendril.age-.74)/.45,0.0,1.0) if not tendril.fired and recoil[0 if tendril.upper else 1]<=0 else 0.0
		g.draw_circle(tip,9+telegraph*5,Color("6b2d52"))
		g.draw_circle(tip+Vector2(-2,-2),5,Color("ffc091") if telegraph>.6 else Color("d2687b"))
		if telegraph>0:
			g.draw_arc(tip,14+telegraph*9,0,TAU,18,Color("fff0c5",telegraph*.78),1)

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

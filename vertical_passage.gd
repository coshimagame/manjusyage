extends RefCounted

var active=false
var done=false
var age=0.0
var spawn=0.0
var wave=0

func reset():
	active=false; done=false; age=0; spawn=0; wave=0

func begin(g):
	active=true; age=0; spawn=1; wave=0
	g.enemies.clear(); g.shots.clear(); g.bullets.clear(); g.pickups.clear(); g.bio.organs.clear()
	for i in range(g.count):
		g.players[i].pos=Vector2(230+i*90,270)
		g.players[i].inv=2
		g.players[i].cool=0

func update(g,dt):
	age+=dt
	# Clear approach and exit frames; movement stays in screen coordinates.
	if age<2 or age>22:
		g.shots.clear(); g.enemies.clear(); g.bullets.clear()
		if age>=24:
			active=false; done=true; g.travel=3700; g.wave_timer=2
			for i in range(g.count):
				g.players[i].pos=Vector2(100,100+i*70); g.players[i].inv=2
		return
	spawn-=dt
	if spawn<=0:
		spawn=1.4; wave+=1
		var wave_group: Array=[]
		var pattern="fan" if wave%2==0 else "aimed"
		for j in range(3):
			wave_group.append({"pos":Vector2(110+fposmod(wave*71+j*143,430),40),"hp":3.0,"cool":1.2,"technique":pattern})
		g.enemy_analysis.mark_new_group(wave_group,"prototype/"+pattern)
		g.enemies.append_array(wave_group)
	for i in range(g.count):
		var p=g.players[i]
		p.inv-=dt; p.cool-=dt; p.burst=maxf(0,p.burst-dt); p.charge=minf(100,p.charge+dt*2)
		g.Abilities.digest(p,dt)
		if p.down>0:
			p.down=maxf(.01,p.down-dt)
			var near=g.players.any(func(other):return other.down==0 and other.pos.distance_to(p.pos)<55)
			p.rescue=maxf(0,p.rescue+dt*(1 if near else -.5))
			if p.rescue>=1.5 or (p.down<.1 and g.reserves>0):
				if p.rescue<1.5: g.reserves-=1
				p.down=0;p.hp=4;p.inv=2;p.rescue=0
			continue
		var input=g.movement(i)
		if g.auto_test: input=[Vector2.ZERO,true];p.inv=100
		if p.character==0:
			if input[1]:
				p.shot_hold=minf(1.7,float(p.shot_hold)+dt)
			elif p.shot_hold>=.70:
				var charged=g.Abilities.damage(p,g.elapsed,randf())*(3.0+maxf(0,p.shot_hold-.7)*1.5)
				g.bullets.append({"pos":p.pos+Vector2(0,-18),"vel":Vector2(0,-430),"color":p.color,"owner":i,"damage":charged,"grade":"charged_"+str(p.last_power_grade)})
				p.shot_hold=0.0
				g.sfx("shot")
			else: p.shot_hold=0.0
		p.pos+=input[0]*155*dt
		p.pos=p.pos.clamp(Vector2(65,100),Vector2(575,315))
		if input[1] and p.cool<=0:
			p.cool=.13
			var power=g.Abilities.damage(p,g.elapsed,randf()) if p.character==0 else g.Abilities.damage(p,g.elapsed)
			for velocity in g.Abilities.velocities(p,Vector2.UP,g.enemies):
				g.bullets.append({"pos":p.pos+Vector2(0,-18),"vel":velocity,"color":p.color,"owner":i,"damage":power,"grade":p.last_power_grade if p.character==0 else "normal"})
			if i==0:g.sfx("shot")
	for b in g.bullets:
		b.pos+=b.vel*dt
		for e in g.enemies:
			if e.hp>0 and b.pos.distance_to(e.pos)<20:
				e.hp-=b.damage;b.pos.y=-100;g.sfx("hit")
	for e in g.enemies:
		e.pos.y+=45*dt;e.cool-=dt
		if e.cool<=0:
			e.cool=2.1
			var direction=(g.players[wave%g.count].pos-e.pos).normalized()
			for angle in ([-.2,0,.2] if e.technique=="fan" else [0]):
				g.shots.append({"pos":e.pos,"vel":direction.rotated(angle)*80,"r":3,"analysis_eligible":e.get("analysis_eligible",false),"source_id":e.get("analysis_id","")})
		for p in g.players:
			if p.down==0 and e.pos.distance_to(p.pos)<20:g.hurt(p)
		if e.hp<=0:
			g.explode(e.pos,Color("ff799e"),20);g.score+=100
			for p in g.players:
				if p.down==0:p.experience+=1
	for shot in g.shots:
		shot.pos+=shot.vel*dt
		for p in g.players:
			if p.down==0 and p.pos.distance_to(shot.pos)<11:g.hurt(p);shot.pos.y=900
	g.bullets=g.bullets.filter(func(b):return b.pos.y>30 and b.pos.x>0 and b.pos.x<640)
	g.enemies=g.enemies.filter(func(e):return e.hp>0 and e.pos.y<350)
	g.shots=g.shots.filter(func(b):return b.pos.y<340 and b.pos.y>30 and b.pos.x>0 and b.pos.x<640)
	if not g.players.any(func(p):return p.down==0) and g.reserves==0:g.finish(false)

func draw(g):
	for y in range(33,338):
		g.draw_line(Vector2(0,y),Vector2(640,y),Color("101b39").lerp(Color("31506e"),float(y)/360))
	for i in range(40):
		var y=fposmod(i*23+age*55,310)+33
		var x=60+(i*113)%520
		g.draw_line(Vector2(x,y),Vector2(x,y+7),Color("749ab5"))
	for side in [0,1]:
		for y in range(33,338,4):
			var depth=35+sin(y*.04+age)*9
			g.draw_rect(Rect2(0 if side==0 else 640-depth,y,depth,4),Color("684365"))
	for e in g.enemies:g.sprite(g.FOE,e.pos-Vector2(16,10),[Color("473a67"),Color("ad83a7"),Color("d96f9c"),Color("ffda8b")],2)
	for b in g.bullets:
		if str(b.get("grade","")).begins_with("charged_"):
			g.draw_circle(b.pos,9,Color("ffcc8e"))
			g.draw_rect(Rect2(b.pos-Vector2(3,13),Vector2(6,22)),Color("fff1d3"))
		else:
			g.draw_rect(Rect2(b.pos-Vector2(2,8),Vector2(4,13)),g.COLORS[b.color])
	for b in g.shots:g.draw_circle(b.pos,b.r,Color("ff9baa"))
	for p in g.players:
		if p.down>0:g.draw_circle(p.pos,5,Color("e1c9a4"));continue
		g.draw_set_transform(p.pos,-PI/2)
		g.ship(Vector2.ZERO,g.COLORS[p.color],1,p.character)
		g.draw_set_transform(Vector2.ZERO)
	if age<2 or age>22:
		g.draw_rect(Rect2(0,135,640,62),Color("121b33"))
		g.japanese("縦スクロールへ移行：上方向に射撃" if age<2 else "横スクロールへ復帰：右方向に射撃",Vector2(135,171),18,g.WHITE)

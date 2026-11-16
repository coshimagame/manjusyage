extends RefCounted

# Candidate art, not canon. Native-size detail is redrawn over registered sprites.
var cosmos: Texture2D
var atlas: Texture2D
var ship_variants=[]
var stage_concepts: Texture2D
var creatures=[]
var stage1_enemy_h={}
var stage1_enemy_v={}
var blasts=[]
var hits=[]
var confirms=[]
var collects=[]
var intensity=1.0
var flash_level=.35

func setup():
	cosmos=load("res://art/v09/cosmos.png")
	atlas=load("res://art/v09/ship-atlas.png")
	# These three authored combat sprites were already present in art/active, but
	# the v0.9 renderer had never consumed them. Keep the shared atlas as a
	# motion underlay and put the individual silhouette on top at gameplay scale.
	ship_variants=[
		load("res://art/active/ship_cormii.png"),
		load("res://art/active/ship_jiyoza.png"),
		load("res://art/active/ship_mafio.png")
	]
	# User-provided Stage 1 enemy sheets stay as byte-preserved draft assets.
	# H/V are deliberately loaded as separate layouts rather than rotating an
	# illustration; each route gets the composition authored for it.
	for id in ["EN001","EN002","EN003","EN004","EN005","EN006","EN007","EN008","EN009","MB01","SB01","BB01"]:
		stage1_enemy_h[id]=load("res://art/stage1/enemies/"+id+"_h_draft.png")
		stage1_enemy_v[id]=load("res://art/stage1/enemies/"+id+"_v_draft.png")
	# STG-CONCEPT-001 is a user-supplied eight-stage concept board. Only its
	# Stage 1 environment strip is used here as a dim, non-colliding backdrop;
	# the other seven rows remain concept material, not playable stage claims.
	var concept_image=Image.load_from_file("res://art/concept/eight_stage_retro_pixel_concepts_20261106.png")
	stage_concepts=ImageTexture.create_from_image(concept_image) if concept_image and not concept_image.is_empty() else null
	for i in range(4):creatures.append(load("res://art/v09/enemy-"+str(i)+".png"))

func stage1_enemy_texture(id:String,vertical:bool):
	return (stage1_enemy_v if vertical else stage1_enemy_h).get(id,null)

func fitted_texture_size(tex:Texture2D,bounds:Vector2)->Vector2:
	var native=tex.get_size()
	return native*minf(bounds.x/native.x,bounds.y/native.y)

func update(dt):
	for e in blasts:e.age+=dt
	blasts=blasts.filter(func(e):return e.age<e.life)
	for h in hits:h.age+=dt
	hits=hits.filter(func(h):return h.age<.16)
	for c in confirms:c.age+=dt
	confirms=confirms.filter(func(c):return c.age<.62)
	for c in collects:c.age+=dt
	collects=collects.filter(func(c):return c.age<.42)

func hit(pos):
	if hits.size()<45:hits.append({"pos":pos,"age":0.0})

func confirm(pos,combo):
	# A compact reward echo distinguishes a destroyed organism from a hit spark.
	if confirms.size()<18:confirms.append({"pos":pos,"combo":combo,"age":0.0})

func collect(pos,kind):
	# A pickup is a reward beat, not another projectile: the bloom appears only
	# after collection and never changes its collision or travel path.
	if collects.size()<24:collects.append({"pos":pos,"kind":int(kind),"age":0.0})

func explode(pos,amount):
	var size=2 if amount>=80 else (1 if amount>=28 else 0)
	if blasts.size()<24:blasts.append({"pos":pos,"size":size,"age":0.0,"life":[.7,1.1,2.7][size]})

func background(g):
	g.draw_rect(Rect2(0,0,640,360),Color("080d21"))
	g.draw_texture(cosmos,Vector2(-36-floor(sin(g.travel*.0006)*24),-36),Color(.63,.65,.78,1))
	if g.bio_route and stage_concepts:
		# Source rect 180..815 / 0..116 is the Stage 1 scenery only: it omits
		# the board title, tile previews, and boss progression samples.
		g.draw_texture_rect_region(stage_concepts,Rect2(0,37,640,117),Rect2(180,0,635,116),Color(1,.74,.78,.44))
		g.draw_rect(Rect2(0,37,640,117),Color("250c18",.20))
	for i in range(5):
		var x=fposmod(i*193-g.travel*.11,960)-160
		var points=PackedVector2Array()
		for j in range(13):points.append(Vector2(x+j*8,110+(i*67)%150+sin(j*.19+i)*36+sin(g.clock*.6+i)*3))
		g.draw_polyline(points,Color(.3,.18,.32,.34),5)
		g.draw_polyline(points,Color(.54,.3,.37,.25),1)
	for i in range(24):
		var x=fposmod(i*139-g.travel*.25,700)-30
		var y=fposmod(i*47+(g.clock*11 if g.vertical.active else sin(g.clock*.6+i)*5),290)+40
		g.draw_line(Vector2(x,y),Vector2(x+2,y-1),Color(.6,.43,.49,.35))
	if g.mode=="menu":return
	if g.vertical.active:
		for side in [0,1]:
			for j in range(7):
				var y=fposmod(j*67+g.vertical.age*46,470)-65
				g.draw_texture_rect(creatures[3],Rect2(-18 if side==0 else 612,y,48,60),false,Color(.28,.32,.45,1))
	elif g.travel>=500:
		# Keep a smooth four-pixel contour, then lay the expensive texture in broader
		# bands behind it. This retains the breathing cave silhouette at 640x360.
		var ceiling_edge=PackedVector2Array()
		var floor_edge=PackedVector2Array()
		for x in range(0,641,4):
			var top=g.bio.ceiling(x,g.travel,g.clock)
			var bottom=g.bio.floor_y(x,g.travel,g.clock)
			ceiling_edge.append(Vector2(x,top-2))
			floor_edge.append(Vector2(x,bottom+1))
		for x in range(0,640,8):
			var top=g.bio.ceiling(x,g.travel,g.clock)
			var bottom=g.bio.floor_y(x,g.travel,g.clock)
			g.draw_texture_rect_region(cosmos,Rect2(x,36,8,maxf(0,top-36)),Rect2(fposmod(x+g.travel*.4,760),0,8,70),Color(.65,.55,.65,1))
			g.draw_texture_rect_region(cosmos,Rect2(x,bottom,8,337-bottom),Rect2(fposmod(x+g.travel*.4,760),345,8,80),Color(.65,.55,.65,1))
		g.draw_polyline(ceiling_edge,Color("a46b76"),3)
		g.draw_polyline(floor_edge,Color("b17c83"),2)

func ship(g,p,index,rotation=0.0,scale_factor=1.0):
	var direction=p.get("motion",Vector2.ZERO)
	var state=1 if direction.y<-.2 else (2 if direction.y>.2 else (3 if direction.x>.2 else 0))
	if p.get("cool",0)>.085 and state==0:state=4
	if p.get("digest",0)>0 or p.get("burst",0)>0:state=5
	var tint=g.COLORS[p.color]
	g.draw_set_transform(p.pos.round(),rotation,Vector2.ONE*scale_factor)
	for side in [-1,1]:
		var length=10+int(g.clock*24)%3*3+int(direction.x>0)*7
		g.draw_colored_polygon(PackedVector2Array([Vector2(-23,side*7-2),Vector2(-26-length,side*7),Vector2(-23,side*7+3)]),Color("375778"))
		g.draw_line(Vector2(-24,side*7),Vector2(-24-length*.7,side*7),tint,2)
		g.draw_line(Vector2(-24,side*7),Vector2(-29,side*7),Color("fff3d5"),1)
	var modulation=Color(.55,.78,1,.7) if p.get("inv",0)>0 and int(g.clock*12)%2==0 else Color.WHITE
	var character=int(p.get("character",index))
	var variant=ship_variants[clampi(character,0,ship_variants.size()-1)] if not ship_variants.is_empty() else null
	if variant:
		# The animated common frame preserves the shared-designer language; the
		# individual 32x20 base is the visible fighter body rather than a menu-only
		# asset. It also rotates with vertical passage because this function already
		# inherits the stage transform.
		g.draw_texture_rect_region(atlas,Rect2(-28,-18,56,36),Rect2(state*56,0,56,36),Color(modulation.r,modulation.g,modulation.b,.30))
		g.draw_texture_rect(variant,Rect2(-24,-15,48,30),false,modulation)
	else:
		g.draw_texture_rect_region(atlas,Rect2(-28,-18,56,36),Rect2(state*56,0,56,36),modulation)
	# All three use the same core atlas, but their visible equipment silhouette is
	# now distinct at gameplay scale. These overlays deliberately change fins,
	# sensors and thrusters rather than merely tinting one identical fighter.
	if character==0: # コルミィ: forward swept flower-canards / burst thrusters.
		for side in [-1,1]:
			g.draw_colored_polygon(PackedVector2Array([Vector2(-5,side*6),Vector2(8,side*15),Vector2(17,side*12),Vector2(7,side*4)]),Color("b93f59"))
			g.draw_line(Vector2(2,side*7),Vector2(15,side*12),Color("ffd4ad"),1)
		g.draw_arc(Vector2(-12,0),15,PI*.65,PI*1.35,12,Color("ff8498",.75),1)
	elif character==1: # ジヨーザ: long sensor booms / precision lattice.
		for side in [-1,1]:
			g.draw_line(Vector2(-2,side*6),Vector2(4,side*15),Color("70dff5"),2)
			g.draw_line(Vector2(4,side*15),Vector2(11,side*15),Color("bdf7ff"),1)
		g.draw_line(Vector2(9,-9),Vector2(18,-9),Color("70dff5"),1)
		g.draw_line(Vector2(14,-13),Vector2(14,-5),Color("70dff5"),1)
	else: # マフィオ: asymmetric intake pods / absorb-and-rebuild fins.
		g.draw_colored_polygon(PackedVector2Array([Vector2(-12,-7),Vector2(-3,-15),Vector2(6,-10),Vector2(-2,-4)]),Color("d4a65a"))
		g.draw_colored_polygon(PackedVector2Array([Vector2(-15,7),Vector2(-5,15),Vector2(7,10),Vector2(-3,4)]),Color("7b5b9a"))
		g.draw_circle(Vector2(-9,0),4,Color("f3d17b"))
		g.draw_arc(Vector2(-9,0),7,-PI*.65,PI*.65,9,Color("e8b7ff"),1)
	# Hand-placed native cockpit, armor seams, nozzles and muzzle stay legible.
	g.draw_line(Vector2(-6,-4),Vector2(5,-3),Color("90e2df"),1)
	g.draw_line(Vector2(6,-2),Vector2(17,-1),Color("eee1bf"),1)
	g.draw_line(Vector2(3,3),Vector2(19,2),Color("384451"),1)
	for side in [-1,1]:
		g.draw_rect(Rect2(21,side*2-1,5,2),Color("111b2a"))
		g.draw_rect(Rect2(-19,side*7-1,3,2),tint)
	if p.get("cool",0)>.085:
		g.draw_colored_polygon(PackedVector2Array([Vector2(26,-3),Vector2(36,0),Vector2(26,3),Vector2(29,0)]),tint)
		g.draw_line(Vector2(25,0),Vector2(32,0),Color("fffbe7"),1)
	if p.character==0 and fposmod(g.elapsed,8)<1.5:
		g.draw_arc(Vector2(-7,0),17+sin(g.clock*18)*2,PI*.65,PI*1.35,12,Color(tint,.6),1)
	elif p.character==1:
		for j in range(1+g.Abilities.level(p)):
			g.draw_line(Vector2(10+j*4,-10),Vector2(12+j*4,-10),tint,1)
	elif p.character==2 and p.get("digest",0)>0:
		for j in range(6):
			var a=g.clock*5+j*TAU/6
			g.draw_line(Vector2.from_angle(a)*20,Vector2.from_angle(a+.2)*13,Color("ffe0a2"),2)
	g.draw_arc(Vector2.ZERO,8,0,TAU,20,Color(.8,.95,1,.4),1)
	g.draw_rect(Rect2(-1,-1,2,2),Color.WHITE)
	g.draw_set_transform(Vector2.ZERO)
	if scale_factor==1:g.text_at(str(index+1),p.pos+Vector2(-3,-24),g.COLORS[index])

func enemy(g,e):
	var technique=e.get("technique","")
	var art_id=str(e.get("art_id",""))
	var tex=stage1_enemy_texture(art_id,g.vertical.active)
	if tex==null:tex=creatures[1 if technique=="fan" or technique=="orbit" else 0]
	var elite=art_id in ["MB01","SB01"]
	var display_scale=float(e.get("scale",1.0))
	var display_size=(fitted_texture_size(tex,Vector2(78,58) if elite else Vector2(48,42))*display_scale) if art_id!="" else tex.get_size()
	var opening=clampf((.65-e.cool)/.65,0,1)
	# A short, exact firing lane tells the player where this organism's next
	# pattern will travel. It uses the same target and angle rules as game.gd,
	# including the deliberately narrow fan gap; this is a readability aid, not
	# an extra attack or a damage change.
	if opening>.08 and not g.players.is_empty():
		var target=g.players[g.wave_id%g.players.size()].pos
		var offsets=e.get("shot_offsets",[-.2,0,.2] if technique=="fan" else ([0] if technique=="dive" else [-.11,.11]))
		var shot_form=str(e.get("shot_form","thorn"))
		var telegraph_color={"petal":Color("ffbd78"),"needle":Color("cfa2ff"),"bubble":Color("91dcff"),"orb":Color("9ee7ef"),"drip":Color("b3a6ff"),"spore":Color("ffd77d"),"ring":Color("ff8fbb"),"claw":Color("ff8f88")}.get(shot_form,Color("ffe2a3"))
		var lane_length=18+opening*48
		for offset in offsets:
			var lane=(target-e.pos).normalized().rotated(offset)
			g.draw_line(e.pos+lane*8,e.pos+lane*lane_length,Color(telegraph_color,.13+opening*.48),1)
		if opening>.54:g.draw_arc(e.pos,10+opening*7,0,TAU,18,Color(telegraph_color,.35+opening*.4),1)
	var motion=str(e.get("motion",technique))
	# Mechanics tests can inject a minimal legacy enemy dictionary. Presentation
	# must keep drawing that fixture even when it has no authored phase value.
	var phase=float(e.get("phase",0.0))
	var tilt=PI/2 if g.vertical.active else sin(g.clock*4+e.pos.x)*.035
	if motion in ["bird","wasp","crab"]:tilt+=sin(e.age*1.35+phase)*.16
	elif motion in ["turtle","mushroom","centipede"]:tilt+=sin(e.age*1.15+phase)*.07
	elif motion in ["rotor","flower"]:tilt+=sin(e.age*2.0+phase)*.1
	var pulse=1.0+sin(g.clock*(6.2 if motion=="jelly" else 4.0)+phase)*(.055 if motion in ["jelly","flower","mushroom"] else .025)
	g.draw_set_transform(e.pos.round(),tilt,Vector2(1,pulse))
	if art_id!="":g.draw_texture_rect(tex,Rect2(-display_size*.5,display_size),false,Color(1,.7,.65) if e.get("flash",0)>0 else Color.WHITE)
	else:g.draw_texture(tex,-tex.get_size()*.5,Color(1,.7,.65) if e.get("flash",0)>0 else Color.WHITE)
	if opening>0:g.draw_arc(Vector2(-display_size.x*.31,0),4+opening*7,PI*.55,PI*1.45,12,Color("fff0b7"),1)
	if motion in ["moth","flower","rotor"]:g.draw_arc(Vector2.ZERO,maxf(10,display_size.x*.27),0,TAU,12,Color("ffc9bb",.58),1)
	elif motion in ["jelly","mushroom"]:g.draw_arc(Vector2(0,display_size.y*.18),maxf(9,display_size.x*.23),0,TAU,12,Color("b8d7dd",.58),1)
	elif motion in ["turtle","centipede"]:g.draw_line(Vector2(-display_size.x*.42,0),Vector2(display_size.x*.42,0),Color("b8d7dd",.52),1)
	g.draw_set_transform(Vector2.ZERO)
	if e.hp<=3 and g.players.any(func(p):return p.character==2 and p.down==0 and p.pos.distance_to(e.pos)<85):
		g.draw_arc(e.pos,27,PI*.65,PI*1.35,10,Color("d4b576"),1)

func projectile(g,b,hostile=false):
	g.draw_set_transform(b.pos.round(),b.get("vel",Vector2.RIGHT).angle())
	if hostile:
		# Enemy shots have a dark diamond hull, warm core and short ember. They
		# therefore read differently from long friendly bolts even in dense fire.
		var radius=float(b.r)
		var form=str(b.get("form","thorn"))
		var dark=Color("171329")
		var hot=Color("e36f71")
		if form=="needle":
			g.draw_line(Vector2(-radius-11,0),Vector2(radius+5,0),Color("6b354f",.75),3)
			g.draw_colored_polygon(PackedVector2Array([Vector2(-radius-1,-radius),Vector2(radius+6,0),Vector2(-radius-1,radius)]),dark)
			g.draw_colored_polygon(PackedVector2Array([Vector2(-radius+1,-1),Vector2(radius+3,0),Vector2(-radius+1,1)]),Color("f7b4b9"))
		elif form in ["bubble","orb"]:
			g.draw_circle(Vector2.ZERO,radius+3,dark)
			g.draw_circle(Vector2.ZERO,radius+1,Color("72d9eb") if form=="bubble" else hot)
			g.draw_circle(Vector2(-radius*.3,-radius*.35),maxf(1,radius*.34),Color("fff5d1"))
		elif form=="spore":
			g.draw_circle(Vector2.ZERO,radius+3,dark)
			g.draw_circle(Vector2.ZERO,radius+1,Color("f0a76e"))
			for petal in range(4):
				var d=Vector2.from_angle(petal*TAU/4.0+PI*.25)
				g.draw_circle(d*(radius+4),1.5,Color("ffd784"))
		elif form=="ring":
			g.draw_circle(Vector2.ZERO,radius+3,dark)
			g.draw_arc(Vector2.ZERO,radius+1,0,TAU,12,Color("ff9ac2"),2)
			g.draw_circle(Vector2.ZERO,1,Color("fff0bc"))
		elif form=="claw":
			g.draw_line(Vector2(-radius-7,-radius*.8),Vector2(radius+3,-radius*.25),dark,3)
			g.draw_line(Vector2(-radius-7,radius*.8),Vector2(radius+3,radius*.25),dark,3)
			g.draw_line(Vector2(-radius-6,-radius*.8),Vector2(radius+2,-radius*.25),Color("ff9d8a"),1)
			g.draw_line(Vector2(-radius-6,radius*.8),Vector2(radius+2,radius*.25),Color("ff9d8a"),1)
		else:
			g.draw_line(Vector2(-radius-8,0),Vector2(-radius,0),Color("6b354f",.7),3)
			g.draw_line(Vector2(-radius-7,0),Vector2(-radius,0),Color("f06f72",.55),1)
			g.draw_colored_polygon(PackedVector2Array([Vector2(-radius-1,0),Vector2(0,-radius-2),Vector2(radius+2,0),Vector2(0,radius+2)]),dark)
			g.draw_colored_polygon(PackedVector2Array([Vector2(-radius+1,0),Vector2(0,-radius),Vector2(radius,0),Vector2(0,radius)]),hot)
			g.draw_circle(Vector2(1,0),maxf(1,radius-2),Color("fff0bc"))
		if form=="petal" or form=="drip":
			g.draw_colored_polygon(PackedVector2Array([Vector2(-radius-2,0),Vector2(0,-radius-3),Vector2(radius+3,0),Vector2(0,radius+3)]),dark)
			g.draw_colored_polygon(PackedVector2Array([Vector2(-radius,0),Vector2(0,-radius-1),Vector2(radius+1,0),Vector2(0,radius+1)]),Color("ff9aac") if form=="petal" else Color("b9a6ff"))
			g.draw_circle(Vector2.ZERO,maxf(1,radius-2),Color("fff0bc"))
	else:
		var col=g.COLORS[b.color]
		var p=g.players[b.owner]
		if p.character==1:
			g.draw_line(Vector2(-13,0),Vector2(6,0),Color(col,.35),5)
			g.draw_line(Vector2(-10,0),Vector2(6,0),col,2)
		elif p.character==2 and p.learned!="none":
			g.draw_arc(Vector2(-3,0),4,-PI*.7,PI*.7,8,col,2)
		else:
			g.draw_line(Vector2(-15,0),Vector2(-4,0),Color(col,.22),5)
			g.draw_colored_polygon(PackedVector2Array([Vector2(-12,0),Vector2(-2,-3),Vector2(8,0),Vector2(-2,3)]),Color(col,.82))
		g.draw_line(Vector2(-4,0),Vector2(5,0),Color("fff8d7"),1)
	g.draw_set_transform(Vector2.ZERO)

func pickup(g,item):
	var pos=item.pos+Vector2(0,sin(g.clock*5.0+item.pos.x*.03)*2.0)
	var hull=int(item.kind)==0
	var col=Color("ff7895") if hull else Color("78e8ff")
	var glow=Color("ffd9a6") if hull else Color("c6fbff")
	# Constrained rings make pickups visible against the bio-background. Their
	# slow bob and shaped cores prevent a heal or cell from reading as a bullet.
	g.draw_arc(pos,10+sin(g.clock*4.0)*1.5,0,TAU,16,Color(col,.32),1)
	g.draw_arc(pos,7,0,TAU,16,Color(glow,.82),1)
	if hull:
		for petal in range(4):
			var d=Vector2.from_angle(petal*TAU/4.0)
			g.draw_colored_polygon(PackedVector2Array([pos+d*2,pos+d.rotated(.45)*7,pos+d*10,pos+d.rotated(-.45)*7]),col)
		g.draw_circle(pos,3,glow)
		g.draw_line(pos-Vector2(2,0),pos+Vector2(2,0),Color.WHITE,1)
		g.draw_line(pos-Vector2(0,2),pos+Vector2(0,2),Color.WHITE,1)
	else:
		g.draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-10),pos+Vector2(7,0),pos+Vector2(0,10),pos+Vector2(-7,0)]),Color("18304b"))
		g.draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-7),pos+Vector2(5,0),pos+Vector2(0,7),pos+Vector2(-5,0)]),col)
		g.draw_line(pos+Vector2(0,-5),pos+Vector2(0,5),glow,1)
		g.draw_line(pos+Vector2(-3,0),pos+Vector2(3,0),glow,1)

func boss(g):
	var p=g.boss.pos
	var anticipation=clampf((.65-g.boss.cool)/.65,0,1)
	# Show the actual fan lanes shortly before release.  This is intentionally
	# drawn from the same formula as update_boss(), so the warning teaches the
	# safe gaps instead of adding another, misleading visual pattern.
	if anticipation>.08:
		var phase=1 if not g.bio_route or not g.bio.exposed() else (3 if g.boss.hp<g.boss.max*.5 else 2)
		var fan=7 if phase==3 else 5
		var muzzle=p+Vector2(-35,0)
		var alpha=.10+anticipation*.42
		for j in range(fan):
			var angle=PI+(j-(fan-1)*.5)*.24+sin(g.boss.age)*.15
			var lane=Vector2.from_angle(angle)
			g.draw_line(muzzle+lane*8,muzzle+lane*(34+anticipation*58),Color(1,.58,.46,alpha),1)
		if anticipation>.55:
			g.draw_arc(muzzle,8+anticipation*8,0,TAU,20,Color(1,.82,.57,alpha),1)
	for side in [-1,1]:
		var pts=PackedVector2Array()
		for j in range(12):pts.append(p+Vector2(55-j*9,side*(38+sin(j*.24+g.clock*1.8)*13+anticipation*j*1.3)))
		g.draw_polyline(pts,Color("301d34"),9)
		g.draw_polyline(pts,Color("a65a70"),3)
		g.draw_polyline(pts,Color("ecc2a2"),1)
	var boss_tex=stage1_enemy_texture("BB01",g.vertical.active)
	if boss_tex:
		var boss_size=fitted_texture_size(boss_tex,Vector2(210,122) if not g.vertical.active else Vector2(158,120))
		g.draw_texture_rect(boss_tex,Rect2(p-boss_size*.5,boss_size),false,Color(1,.7,.7) if g.boss.flash>0 else Color.WHITE)
	else:g.draw_texture_rect(creatures[2],Rect2(p+Vector2(-40,-77),Vector2(164,154+sin(g.clock*2.8)*3)),false,Color(1,.7,.7) if g.boss.flash>0 else Color.WHITE)
	var core=g.COLORS[g.boss.color] if g.bio.exposed() else Color("542d48")
	g.draw_circle(p,18,Color("0b1023"))
	g.draw_arc(p,18,0,TAU,28,Color("c28d78"),2)
	g.draw_circle(p,12+sin(g.clock*2.8),core)
	if g.bio.exposed():g.draw_arc(p,15+anticipation*4,0,TAU,24,Color("fff5c7"),1)
	for i in range(g.bio.armor.size()):
		var a=g.bio.part_pos(g,i)
		if g.bio.armor[i]>0:
			var armor_tex=stage1_enemy_texture("EN009",g.vertical.active)
			if armor_tex:
				var armor_size=fitted_texture_size(armor_tex,Vector2(48,48))
				g.draw_texture_rect(armor_tex,Rect2(a-armor_size*.5,armor_size),false,Color.WHITE)
			else:g.draw_texture(creatures[3],a-Vector2(27,27))
			if anticipation>0:g.draw_arc(a,24,0,TAU,24,Color("ffca83"),1)
		else:g.draw_line(a+Vector2(-14,-9),a+Vector2(13,8),Color("a44257"),4)
	# The encounter objective is a readable foreground card, not a floating label
	# lost against the organic hull. The coloured key repeats the attack language.
	g.draw_rect(Rect2(404,50,224,25),Color("100f25",.92))
	g.draw_rect(Rect2(404,50,224,25),Color(core,.85),false,1)
	g.draw_rect(Rect2(409,55,3,15),core)
	g.japanese("外殻を破壊" if not g.bio.exposed() else "コア露出 / 同じ色で撃つ",Vector2(417,61),10,Color("f5dfc8"))
	g.draw_rect(Rect2(417,67,201,3),Color("392438"))
	g.draw_rect(Rect2(417,67,201*maxf(0,g.boss.hp)/g.boss.max,3),core)
	if anticipation>.42:
		g.japanese("扇弾 接近",Vector2(557,84),9,Color("ffd29a"))

func effects(g):
	for h in hits:
		for i in range(5):
			var d=Vector2.from_angle(i*TAU/5)
			g.draw_line(h.pos+d*(3+h.age*20),h.pos+d*(6+h.age*60),Color(1,.84,.64,1-h.age/.16),1)
	for e in blasts:
		var t=e.age
		var radius=[13,25,55][e.size]
		if t<.075:g.draw_circle(e.pos,radius*(1+t*9),Color(1,.96,.8,flash_level))
		for i in range(8+e.size*5):
			var d=Vector2.from_angle(i*2.399)
			var pos=e.pos+d*(12+t*(35+i%4*11))
			if t<.7+e.size*.25:g.draw_line(pos,pos+d*(3+i%4),Color("d4b398"),2)
			var age=t-.035-i%5*.027
			if age>0 and age<.45+e.size*.2:
				var r=maxf(0,(1-age/(.45+e.size*.2))*(radius*.35)+sin(age*9)*3)
				var center=e.pos+d*(radius*.55+age*13)
				g.draw_circle(center,r,Color("77344a"))
				g.draw_circle(center-Vector2(1,1),r*.65,Color("ec9566"))
				if age<.15:g.draw_circle(center-Vector2(1,1),r*.35,Color("fff0b1"))
		if t>.15:g.draw_arc(e.pos,radius+t*45,0,TAU,40,Color(.85,.45,.38,maxf(0,.5-t*.45)),1)
	for c in confirms:
		var t=c.age
		var alpha=maxf(0,1-t/.62)
		var pos=c.pos+Vector2(0,-10-t*26)
		for i in range(4):
			var d=Vector2.from_angle(i*TAU/4+PI*.25)
			g.draw_line(pos+d*(3+t*10),pos+d*(7+t*20),Color(1,.82,.52,alpha),1)
		g.text_at("+"+str(100*c.combo),pos+Vector2(-8,-8),Color(1,.94,.72,alpha))
	for c in collects:
		var t=c.age
		var alpha=maxf(0,1-t/.42)
		var col=Color("ff8fa4") if c.kind==0 else Color("91edff")
		for i in range(6):
			var d=Vector2.from_angle(i*TAU/6.0+t*2.0)
			g.draw_line(c.pos+d*(3+t*24),c.pos+d*(8+t*44),Color(col,alpha),1)
		g.draw_arc(c.pos,7+t*34,0,TAU,20,Color("fff3cc",alpha*.8),1)

func draw(g):
	background(g)
	if g.mode=="controls":g.draw_controls();return
	if g.mode=="menu":g.draw_menu();return
	if g.gate>0:g.draw_gate()
	for o in g.bio.organs:
		g.draw_texture(creatures[3],o.pos-Vector2(27,27))
		if o.cool<.6:g.draw_arc(o.pos,25,0,TAU,24,Color("ffd0a0"),1)
	for e in g.enemies:enemy(g,e)
	for b in g.bullets:projectile(g,b)
	for b in g.shots:projectile(g,b,true)
	for item in g.pickups:
		pickup(g,item)
	if not g.boss.is_empty():boss(g)
	for i in range(g.players.size()):
		var p=g.players[i]
		if p.down>0:
			# The art-v09 path owns the production HUD: mirror the base renderer's
			# rescue signal here so a busy biological scene still reads at a glance.
			g.draw_arc(p.pos,20+sin(g.clock*6.0)*2,0,TAU,16,Color(g.COLORS[i].r,g.COLORS[i].g,g.COLORS[i].b,.42),1)
			g.draw_arc(p.pos,9,0,TAU,16,g.COLORS[i],2)
			# Keep the pod label below the craft: the opening title occupies the upper
			# left lane and must never hide a co-op rescue callout.
			g.draw_rect(Rect2(p.pos+Vector2(-19,16),Vector2(38,10)),Color("10152a",.9))
			g.draw_rect(Rect2(p.pos+Vector2(-19,16),Vector2(38,10)),Color(g.COLORS[i],.75),false,1)
			g.text_at("SOS",p.pos+Vector2(-8,18),g.COLORS[i])
			var rescue_ratio=clampf(p.rescue/1.5,0.0,1.0)
			g.draw_rect(Rect2(p.pos+Vector2(-12,12),Vector2(24,3)),Color("18233c"))
			g.draw_rect(Rect2(p.pos+Vector2(-12,12),Vector2(24*rescue_ratio,3)),Color.WHITE)
			if rescue_ratio>0:
				g.draw_rect(Rect2(p.pos+Vector2(-18,28),Vector2(36,8)),Color("10152a",.88))
				g.text_at("LINK %02d"%int(rescue_ratio*100),p.pos+Vector2(-16,30),Color("fff1c9"))
				for rescuer in g.players:
					if rescuer.down==0 and rescuer.pos.distance_to(p.pos)<55:
						g.draw_line(rescuer.pos,p.pos,Color(g.COLORS[rescuer.color].r,g.COLORS[rescuer.color].g,g.COLORS[rescuer.color].b,.72),1.5,true)
				g.draw_arc(p.pos,15+rescue_ratio*12,0,TAU,16,Color(1,1,1,.7),1)
		else:ship(g,p,i,-PI/2 if g.vertical.active else 0)
		if p.burst>0:g.draw_arc(p.pos,(.55-p.burst)*650,0,TAU,48,g.COLORS[p.color],2)
	effects(g)
	hud(g)
	if g.vertical.active and (g.vertical.age<2 or g.vertical.age>g.vertical.duration-2):
		g.japanese("進路転換：上へ射撃" if g.vertical.age<2 else "進路転換：右へ射撃",Vector2(217,177),17,Color("f1dfbe"))
	if g.slice_mode and g.elapsed<4:g.japanese("赤い残響",Vector2(40,100),27,Color("f0ddd0"))
	if g.mode=="pause":
		g.draw_rect(Rect2(0,100,640,150),Color(0,.02,.06,.9))
		g.centered("PAUSED / START TO RESUME",160,g.WHITE,2)
		g.japanese("F10 振動調整 / F12 閃光調整 / Q タイトル",Vector2(160,210),12)
	elif g.mode in ["clear","over"]:g.draw_result()

func pilot_badge(g,pos,character,accent):
	# Small, shape-coded crests make the pilots readable without relying on color.
	g.draw_circle(pos,8,Color("091326"))
	g.draw_arc(pos,8,0,TAU,16,Color(accent,.8),1)
	if character==0:
		for i in range(4):
			var d=Vector2.from_angle(i*TAU/4.0)
			g.draw_line(pos+d*2,pos+d*5,accent,2)
		g.draw_circle(pos,2,Color("fff0cf"))
	elif character==1:
		g.draw_line(pos-Vector2(5,0),pos+Vector2(5,0),accent,1)
		g.draw_line(pos-Vector2(0,5),pos+Vector2(0,5),accent,1)
		g.draw_rect(Rect2(pos-Vector2(2,2),Vector2(4,4)),Color("d6fbff"),false,1)
	else:
		g.draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-5),pos+Vector2(5,0),pos+Vector2(0,5),pos+Vector2(-5,0)]),accent)
		g.draw_circle(pos,1,Color("fff0cf"))

func hud(g):
	# The play HUD uses the same framed, warm-metal language as the sortie card:
	# pilots read left-to-right, while score and reserves are deliberately isolated.
	g.draw_rect(Rect2(0,0,640,47),Color("070d1d"))
	g.draw_rect(Rect2(7,4,626,39),Color("0e1930"))
	g.draw_rect(Rect2(7,4,626,39),Color("6d576b"),false,1)
	g.draw_line(Vector2(12,45),Vector2(628,45),Color("b08075"),1)
	for i in range(g.count):
		var p=g.players[i]
		var x=12+i*155
		g.draw_rect(Rect2(x,7,148,33),Color("0b172c"))
		g.draw_rect(Rect2(x,7,148,33),Color(g.COLORS[i],.72),false,1)
		g.draw_rect(Rect2(x,7,3,33),g.COLORS[i])
		pilot_badge(g,Vector2(x+17,22),p.character,g.COLORS[i])
		g.text_at("P"+str(i+1),Vector2(x+29,12),g.COLORS[i])
		g.japanese(g.PILOT_NAMES[p.character],Vector2(x+47,18),12,Color("f7ebd6"))
		# Four petal-like hull lamps and a ticked charge channel give HP and
		# energy their own silhouettes instead of two anonymous rectangles.
		for j in range(4):
			var lamp=Color(g.COLORS[i]) if j<p.hp else Color("303a50")
			g.draw_colored_polygon(PackedVector2Array([Vector2(x+48+j*8,28),Vector2(x+51+j*8,26),Vector2(x+54+j*8,28),Vector2(x+51+j*8,31)]),lamp)
		g.draw_rect(Rect2(x+83,27,39,6),Color("29384f"))
		g.draw_rect(Rect2(x+84,28,maxf(0,p.charge*.37),4),g.COLORS[i])
		for tick in [10,20,30]:g.draw_line(Vector2(x+84+tick,27),Vector2(x+84+tick,33),Color("10172a"),1)
		g.draw_circle(Vector2(x+132,30),4,Color(g.COLORS[p.color],.28))
		g.draw_arc(Vector2(x+132,30),4,0,TAU,12,g.COLORS[p.color],1)
		if p.charge>=100:
			g.text_at("!",Vector2(x+140,26),Color("fff2cb"))
		else:
			g.japanese(g.Abilities.label(p,g.elapsed),Vector2(x+84,40),8,Color("b6a9b6"))
	# Score card stays static even when player cards change between 1–3P.
	g.draw_rect(Rect2(480,7,148,33),Color("17162a"))
	g.draw_rect(Rect2(480,7,148,33),Color("8b6971"),false,1)
	g.japanese("SCORE",Vector2(490,18),9,Color("aa9eaa"))
	g.text_at("%07d"%g.score,Vector2(544,13),Color("fff0d3"))
	g.japanese("予備機",Vector2(490,35),10,Color("b8aab1"))
	g.text_at("x"+str(g.reserves),Vector2(548,30),Color("f5c777"))
	g.draw_rect(Rect2(0,337,640,23),Color("070d1d"))
	g.draw_rect(Rect2(8,340,624,16),Color("0e1930"))
	g.draw_rect(Rect2(8,340,624,16),Color("594d62"),false,1)
	g.japanese("RED ECHO // 第1境界・生体宙域",Vector2(16,352),10,Color("e1c6bd"))
	g.draw_rect(Rect2(286,346,150,3),Color("34364c"))
	g.draw_rect(Rect2(286,346,minf(150,g.travel/4800.0*150),3),Color("d57b73"))
	g.japanese("X 色  /  B 固有技  /  START 停止",Vector2(454,352),9,Color("aaa2b5"))

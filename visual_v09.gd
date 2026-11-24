extends RefCounted

const ArtCatalog = preload("res://art_catalog.gd")
# Candidate art, not canon. Native-size detail is redrawn over registered sprites.
var cosmos: Texture2D
var atlas: Texture2D
var ship_variants=[]
var vertical_ship_variants=[]
var stage_concepts: Texture2D
var creatures=[]
var blasts=[]
var hits=[]
var confirms=[]
var pillars=[]
var intensity=1.0
var flash_level=.35

func _tex(path:String) -> Texture2D:
	# Resource loader first (exported builds only carry the remapped
	# imported texture), raw image read as the local-iteration fallback.
	if ResourceLoader.exists(path, "Texture2D"):
		var res = ResourceLoader.load(path, "Texture2D")
		if res is Texture2D: return res
	if FileAccess.file_exists(path):
		var image=Image.load_from_file(path)
		if image and not image.is_empty(): return ImageTexture.create_from_image(image)
	return null

func slot_or(key:String, fallback:String) -> Texture2D:
	# Swappable-art convention: an art/active/<key>.png drop-in wins over the
	# built-in file, so any of these textures can be replaced without code.
	var t=_tex("res://art/active/"+key+".png")
	if t: return t
	t=_tex(fallback)
	if t: return t
	return load(fallback) if ResourceLoader.exists(fallback) else null

func setup():
	cosmos=slot_or("v09_cosmos","res://art/v09/cosmos.png")
	atlas=slot_or("v09_ship_atlas","res://art/v09/ship-atlas.png")
	# STG-CONCEPT-001 is a user-supplied eight-stage concept board. Only its
	# Stage 1 environment strip is used here as a dim, non-colliding backdrop;
	# the other seven rows remain concept material, not playable stage claims.
	stage_concepts=slot_or("stage_concept_board","res://art/concept/eight_stage_retro_pixel_concepts_20261106.png")
	for i in range(4):creatures.append(slot_or("v09_enemy_"+str(i),"res://art/v09/enemy-"+str(i)+".png"))
	# Per-character reference ships (ported from the v09 playtest branch):
	# cropped sheets under art/active/ships/ via ArtCatalog.reference_ship.
	# Any null entry keeps the shared-atlas rendering in ship().
	ship_variants=[
		ArtCatalog.reference_ship(0),
		ArtCatalog.reference_ship(1),
		ArtCatalog.reference_ship(2)
	]
	vertical_ship_variants=[
		ArtCatalog.reference_ship(0,true),
		ArtCatalog.reference_ship(1,true),
		ArtCatalog.reference_ship(2,true)
	]

func update(dt):
	for e in blasts:e.age+=dt
	blasts=blasts.filter(func(e):return e.age<e.life)
	for h in hits:h.age+=dt
	hits=hits.filter(func(h):return h.age<.16)
	for c in confirms:c.age+=dt
	confirms=confirms.filter(func(c):return c.age<.62)
	for pl in pillars:pl.age+=dt
	pillars=pillars.filter(func(pl):return pl.age<.45)

func pillar(pos,kind):
	# V15: a short light pillar marks a pickup so collection reads at a glance.
	if pillars.size()<12:pillars.append({"pos":pos,"kind":kind,"age":0.0})

func hit(pos):
	if hits.size()<45:hits.append({"pos":pos,"age":0.0})

func confirm(pos,combo):
	# A compact reward echo distinguishes a destroyed organism from a hit spark.
	if confirms.size()<18:confirms.append({"pos":pos,"combo":combo,"age":0.0})

func explode(pos,amount):
	var size=2 if amount>=80 else (1 if amount>=28 else 0)
	if blasts.size()<24:blasts.append({"pos":pos,"size":size,"age":0.0,"life":[.7,1.1,2.7][size]})

func bio_edges(g):
	# Living stage dressing, first pass: the playfield's upper and lower
	# edges are soft membranes that swell and recede, with glow nodes that
	# pulse like organs. Draw-only; no collision or gameplay effect.
	if not g.bio_route: return
	var t=g.clock
	for side in range(2):
		var base=37.0 if side==0 else 323.0
		var dir=1.0 if side==0 else -1.0
		var pts=PackedVector2Array()
		pts.append(Vector2(-4, base-dir*22))
		for j in range(33):
			var swell=7+5*sin(t*.7+j*.55+side*2.1)+3*sin(t*1.7+j*1.3)
			pts.append(Vector2(j*20.0-4, base+dir*swell))
		pts.append(Vector2(644, base-dir*22))
		g.draw_colored_polygon(pts,Color("1c0a16",.85))
		# The membrane lip is stepped pixels, not a smooth string -
		# same language as the rest of the backdrop.
		for j in range(33):
			var swell=7+5*sin(t*.7+j*.55+side*2.1)+3*sin(t*1.7+j*1.3)
			var ly=round((base+dir*swell)/2.0)*2.0
			g.draw_rect(Rect2(j*20.0-4,ly-1,20,2),Color(.62,.26,.34,.5))
		for k in range(4):
			var nx=fposmod(k*173.0+side*61-g.travel*.35,680)-20
			var swell=7+5*sin(t*.7+(nx+4)/20.0*.55+side*2.1)+3*sin(t*1.7+(nx+4)/20.0*1.3)
			var pulse=.5+.5*sin(t*2.2+k*1.9+side)
			var ny=round((base+dir*swell)/2.0)*2.0
			g.draw_rect(Rect2(nx-3,ny-3,6,6),Color(.85,.3,.36,.16+.2*pulse))
			g.draw_rect(Rect2(nx-1,ny-1,2,2),Color(1,.55,.5,.5+.4*pulse))

func sky_rect(g,r,col,lite,dark,top,body):
	# One rect of a silhouette, shaded by height: light at the top,
	# dark at the base, with a checker-dithered boundary between
	# steps so shapes carry real tonal modelling instead of a flat
	# fill (user note 2026-11-24: the detailing still felt weak).
	var t=(r.position.y-top)/maxf(1.0,body)
	var c=col
	if t<0.27:
		c=lite
	elif t<0.33:
		c=lite if int(r.position.x/2.0)%2==0 else col
	elif t<0.69:
		c=col
	elif t<0.75:
		c=col if int(r.position.x/2.0)%2==0 else dark
	else:
		c=dark
	g.draw_rect(r,c)

func draw_skyline(g,base_y,depth,col,seed_off):
	# Organic silhouettes for the bio-space region (stage 1 is a
	# living space zone, NOT a city), on a fine 18px segment grid,
	# each form shaded in three steps with dithered boundaries.
	var off=g.travel*depth
	var seg=18.0
	var shift=int(floor(off/seg))
	var lite=Color(minf(1.0,col.r+.13),minf(1.0,col.g+.14),minf(1.0,col.b+.17),col.a)
	var dark=Color(col.r*.5,col.g*.5,col.b*.58,col.a)
	for cx in range(-1,38):
		var wi=cx+shift
		var wx=cx*seg-fposmod(off,seg)
		var hsh=(wi*73+seed_off*131)%7
		var hgt=[52.0,80.0,64.0,100.0,56.0,88.0,68.0][hsh]
		var top=base_y-hgt
		var body=base_y-top
		if hsh==0:
			# A great living dome, 3px steps.
			sky_rect(g,Rect2(wx+6,top,6,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+3,top+3,12,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+1,top+6,16,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx,top+9,18,body-9),col,lite,dark,top,body)
		elif hsh==1:
			# A rib arch: thin legs, a finely stepped arc.
			sky_rect(g,Rect2(wx,top+8,3,body-8),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+15,top+8,3,body-8),col,lite,dark,top,body)
			var arc=[5,2,0,0,2,5]
			for k in range(6):
				sky_rect(g,Rect2(wx+k*3,top+arc[k],3,3),col,lite,dark,top,body)
		elif hsh==2:
			# A spine stack of many thin vertebrae.
			var rows=9
			for r in range(rows):
				var w=11.0 if r%2==0 else 7.0
				sky_rect(g,Rect2(wx+(18-w)/2,top+r*(body/rows),w,body/rows-1),col,lite,dark,top,body)
		elif hsh==3:
			# A membrane fin, narrowing 2px a row.
			var rows=9
			for r in range(rows):
				var w=maxf(2.0,16.0-r*1.8)
				sky_rect(g,Rect2(wx+1,base_y-(r+1)*(body/rows),w,body/rows-1),col,lite,dark,top,body)
		elif hsh==4:
			# Twin bulbs.
			sky_rect(g,Rect2(wx+2,top+5,5,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx,top+8,9,body-8),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+11,top+11,5,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+9,top+14,9,body-14),col,lite,dark,top,body)
		elif hsh==5:
			# A cocoon pod on a stalk.
			sky_rect(g,Rect2(wx+8,top+11,2,body-11),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+5,top,8,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+3,top+3,12,5),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx+5,top+8,8,3),col,lite,dark,top,body)
		else:
			# A low living mound.
			sky_rect(g,Rect2(wx+4,top+4,10,3),col,lite,dark,top,body)
			sky_rect(g,Rect2(wx,top+7,18,body-7),col,lite,dark,top,body)
		# Living speckle and a glow node on the shaded body.
		var spk=Color(minf(1.0,lite.r+.10),minf(1.0,lite.g+.11),minf(1.0,lite.b+.13),col.a)
		for sp in range(3):
			var px2=wx+float((wi*31+sp*47)%14+2)
			var py2=top+6.0+float((wi*17+sp*29)%int(maxf(10.0,body-12.0)))
			g.draw_rect(Rect2(px2,py2,2,2),spk)
		if hsh%3==0:
			g.draw_rect(Rect2(wx+8,top+body*.45,2,2),Color(1,.62,.6,.55+.35*sin(g.clock*2.0+wi)))

func flesh_surf(wx2):
	return floor((306.0+5.0*sin(wx2*0.013)+3.0*sin(wx2*0.031+1.7))/2.0)*2.0

func draw_flesh_terrain(g):
	# Living terrain masses for the bio-space region: an undulating
	# crimson flesh floor with a lit rim, nodules and fine speckle,
	# plus organic masses hanging from above in stretches - dense
	# organic terrain instead of flat silhouettes over empty space
	# (direction from the user's arcade reference, 2026-11-23; the
	# art itself is original and procedural).
	var base=Color("3d1424")
	var deep=Color("260a16")
	var lite=Color("5f2436")
	var rim=Color("b5502f")
	var hot=Color("e8793f")
	for cx in range(0,161):
		var x=cx*4.0
		var wx2=x+g.travel*0.9
		var surf=flesh_surf(wx2)
		g.draw_rect(Rect2(x,surf,4,360-surf),base)
		if cx%2==0:
			g.draw_rect(Rect2(x,surf+13,2,3),deep)
			g.draw_rect(Rect2(x+2,surf+14,2,2),deep)
		g.draw_rect(Rect2(x,surf+16,4,360-surf-16),deep)
		g.draw_rect(Rect2(x,surf,4,2),rim)
		if int(wx2/4.0)%9==0:
			g.draw_rect(Rect2(x,surf,4,2),hot)
		# A woven scale pattern across the whole mass, not just
		# sparse speckle: alternating light and dark motes every row.
		for row in range(7):
			var yy=surf+6.0+row*7.0
			if yy>=354.0:
				break
			var off2=2.0 if row%2 else 0.0
			if (cx+row)%2==0:
				g.draw_rect(Rect2(x+off2,yy,2,2),lite)
			if (cx+row)%3==1:
				g.draw_rect(Rect2(x+2.0-off2,yy+3.0,2,2),Color("170410"))
	for sg in range(-1,25):
		var wx3=sg*28.0-fposmod(g.travel*0.9,28.0)
		var idx=sg+int(floor(g.travel*0.9/28.0))
		if idx%6!=2:
			continue
		var surf2=flesh_surf(wx3+10.0+g.travel*0.9)
		g.draw_rect(Rect2(wx3+6,surf2-4,16,4),base)
		g.draw_rect(Rect2(wx3+9,surf2-7,10,3),base)
		g.draw_rect(Rect2(wx3+6,surf2-4,16,2),rim)
		g.draw_rect(Rect2(wx3+12,surf2-7,4,2),hot)
	for sg in range(-1,14):
		var wx5=sg*48.0-fposmod(g.travel*0.9,48.0)
		var idx5=sg+int(floor(g.travel*0.9/48.0))
		if idx5%7==3:
			var cs=flesh_surf(wx5+6.0+g.travel*0.9)
			for k in range(5):
				g.draw_rect(Rect2(wx5+4.0+float((k*7)%9),cs+2.0+k*3.0,2,2),Color(1,.55,.3,.75))
	for sg in range(-1,11):
		var wx4=sg*64.0-fposmod(g.travel*0.55,64.0)
		var idx=sg+int(floor(g.travel*0.55/64.0))
		if idx%3!=1:
			continue
		var dep=18.0+float((idx*37)%22)
		for cx in range(16):
			var t=cx/15.0
			var dd=floor(dep*(0.55+0.45*sin(t*PI))/2.0)*2.0
			g.draw_rect(Rect2(wx4+cx*4,64,4,dd),Color("2a0d18"))
			g.draw_rect(Rect2(wx4+cx*4,64+dd-2,4,2),Color("8a3a2a"))
			if cx%4==1:
				g.draw_rect(Rect2(wx4+cx*4+1,64+dd*0.4,2,2),Color("4a1a28"))

func background(g):
	# One pixel-art language for the whole backdrop (user note
	# 2026-11-23): flat colour bands, dithered seams, snapped stars,
	# a chunky moon and rect-built skylines. No photographic texture,
	# no painted board strip, no smooth vector strands.
	g.draw_rect(Rect2(0,0,640,360),Color("070b1d"))
	var bands=[Color("0a1128"),Color("0e1734"),Color("13204a"),Color("182a5c")]
	for bi in range(4):
		g.draw_rect(Rect2(0,36+bi*54,640,54),bands[bi])
		if bi>0:
			for dx in range(0,640,4):
				if (dx/4+bi)%2==0: g.draw_rect(Rect2(dx,36+bi*54-2,2,2),bands[bi])
				if (dx/4+bi)%4==1: g.draw_rect(Rect2(dx,36+bi*54-5,2,2),bands[bi])
	for i in range(110):
		var sx=float((i*97)%632+4)
		var sy=float(40+(i*57)%190)
		var tw=.45+.55*(sin(g.clock*(0.6+fposmod(i*.37,1.0))+i*1.7)*.5+.5)
		var scol=Color(.8,.85,1,.25+.5*tw) if i%5 else Color(1,.9,.8,.3+.5*tw)
		var ss=2.0 if i%3==0 else 1.0
		g.draw_rect(Rect2(sx,sy,ss,ss),scol)
	var moonx=520.0-fposmod(g.travel*.02,760.0)
	if moonx>-90:
		for ry in range(30):
			var t=(ry-14.5)/15.0
			var w=int(24.0*sqrt(maxf(0.0,1.0-t*t)))
			g.draw_rect(Rect2(moonx-w,84+ry*2,w*2,2),Color("c9d4ea"))
			g.draw_rect(Rect2(moonx+w-6,84+ry*2,6,2),Color("9aa7c4"))
		g.draw_rect(Rect2(moonx-12,96,4,4),Color("aeb9d2"))
		g.draw_rect(Rect2(moonx+4,116,6,6),Color("aeb9d2"))
		g.draw_rect(Rect2(moonx-2,130,4,4),Color("aeb9d2"))
	draw_skyline(g,300.0,.12,Color("141d3d"),1)
	draw_skyline(g,330.0,.30,Color("0a1026"),2)
	if g.travel<500 and not g.vertical.active: draw_flesh_terrain(g)
	for i in range(24):
		var x=fposmod(i*139-g.travel*.25,700)-30
		var y=fposmod(i*47+(g.clock*11 if g.vertical.active else sin(g.clock*.6+i)*5),290)+40
		g.draw_line(Vector2(x,y),Vector2(x+2,y-1),Color(.6,.43,.49,.35))
	# Drifting spores and petal motes at two depths: the field itself feels
	# alive and volumetric instead of a flat scrolling backdrop. Positions are
	# a pure function of the index and the clock, so there is no RNG state.
	for i in range(30):
		var depth=.35 if i%2==0 else .62
		var mx=fposmod(i*173.3-g.travel*depth+sin(g.clock*.5+i*1.7)*6,700)-30
		var my=fposmod(i*61.7+g.clock*5.0*depth+sin(g.clock*.8+i)*4,300)+30
		var mote=Color(1,.78,.8,.13+.1*depth) if i%3==0 else Color(.75,.9,1,.11+.1*depth)
		g.draw_rect(Rect2(floor(mx/2)*2,floor(my/2)*2,2,2),mote)
	bio_edges(g)
	if g.mode=="menu":return
	if g.vertical.active:
		for side in [0,1]:
			for j in range(7):
				var y=fposmod(j*67+g.vertical.age*46,470)-65
				g.draw_texture_rect(creatures[3],Rect2(-18 if side==0 else 612,y,48,60),false,Color(.28,.32,.45,1))
	elif g.travel>=500:
		# The living cave as flat pixel silhouette: 4px columns with
		# snapped heights and a hard rim light - the same language as
		# the sky, instead of a photographic texture on a smooth curve.
		for x in range(0,640,4):
			var top=round(g.bio.ceiling(x,g.travel,g.clock)/4.0)*4.0
			var bottom=round(g.bio.floor_y(x,g.travel,g.clock)/4.0)*4.0
			g.draw_rect(Rect2(x,36,4,maxf(0.0,top-36)),Color("160d20"))
			g.draw_rect(Rect2(x,top-2,4,2),Color("a46b76"))
			g.draw_rect(Rect2(x,bottom,4,maxf(0.0,340-bottom)),Color("160d20"))
			g.draw_rect(Rect2(x,bottom,4,2),Color("b17c83"))
			if (x/4)%3==0:
				g.draw_rect(Rect2(x+2,38.0+float((x*7)%int(maxf(8.0,top-46.0))),2,2),Color("3a1a2c"))
				var fyy=bottom+6.0+float((x*11)%int(maxf(8.0,332.0-bottom)))
				if fyy<338.0: g.draw_rect(Rect2(x+2,fyy,2,2),Color("3a1a2c"))

func fitted_texture_size(tex:Texture2D,bounds:Vector2)->Vector2:
	var native=tex.get_size()
	return native*minf(bounds.x/native.x,bounds.y/native.y)

func ship(g,p,index,rotation=0.0,scale_factor=1.0):
	var direction=p.get("motion",Vector2.ZERO)
	var state=1 if direction.y<-.2 else (2 if direction.y>.2 else (3 if direction.x>.2 else 0))
	if p.get("cool",0)>.085 and state==0:state=4
	if p.get("digest",0)>0 or p.get("burst",0)>0:state=5
	var tint=g.COLORS[p.color]
	# Idle hover: the craft breathes on its thrusters instead of hanging
	# frozen between inputs - a slow bob and a whisper of roll. Draw-only,
	# same rule as the enemy sway: p.pos and the hitbox never move.
	var hover=Vector2(sin(g.clock*1.3+index*2.4)*1.2,sin(g.clock*2.1+index*2.1)*1.8)
	g.draw_set_transform((p.pos+hover).round(),rotation+sin(g.clock*1.7+index)*.03,Vector2.ONE*scale_factor)
	var character=clampi(int(p.get("character",index)),0,2)
	var vertical_view=g.vertical.active
	var variant: Texture2D=null
	if ship_variants.size()==3:
		variant=vertical_ship_variants[character] if vertical_view else ship_variants[character]
	if variant!=null:
		# Reference-ship rendering (v09 branch method): the cropped sheet is
		# fitted into a 56x29 box, banked by vertical motion, and rotated
		# -90 degrees in vertical sections where the _v art takes over.
		var modulation=Color(.68,.81,1,.65) if p.get("inv",0)>0 and int(g.clock*12)%2==0 else Color.WHITE
		var in_flight=g.mode=="play" or g.mode=="pause"
		var vmotion: Vector2=p.get("motion",Vector2.ZERO)
		var vrot=-PI/2 if vertical_view else 0.0
		var local_motion=vmotion.rotated(-vrot)
		var ship_size=fitted_texture_size(variant,Vector2(56,29))
		var bank=clampf(local_motion.y*.06,-.06,.06) if in_flight else 0.0
		g.draw_set_transform((p.pos+hover).round(),vrot+bank+sin(g.clock*1.7+index)*.02,Vector2.ONE*scale_factor)
		if in_flight:
			var nozzle=Vector2(-ship_size.x*.44,0)
			var flen=6.0+floorf(fposmod(g.clock*27,3))*1.5+maxf(0.0,local_motion.x)*7.0
			g.draw_colored_polygon(PackedVector2Array([nozzle+Vector2(0,-3),nozzle-Vector2(flen,0),nozzle+Vector2(0,3)]),Color(tint,.64*modulation.a))
			g.draw_line(nozzle,nozzle-Vector2(flen*.65,0),Color("fff4d8",.88*modulation.a),1)
		g.draw_texture_rect(variant,Rect2(-ship_size*.5,ship_size),false,modulation)
		if in_flight and p.get("cool",0)>.105:
			g.draw_line(Vector2(27,0),Vector2(33,0),Color("fff4db"),1)
		if character==0 and p.get("elapsed",99)<1.5:
			g.draw_arc(Vector2.ZERO,20,-2.4,-.7,10,Color("ffd7e8",.8),2)
		if character==1:
			for lv in range(mini(5,1+int(p.get("experience",0)/3))):
				g.draw_line(Vector2(-10+lv*5,17),Vector2(-7+lv*5,17),Color("9fe8ff",.85),2)
		if character==2:
			var swirl=p.get("digest",0)
			if swirl>0:
				for s in range(mini(10,int(ceil(swirl*8.0)))):
					var a=g.clock*3+s*TAU/10
					g.draw_rect(Rect2(Vector2(cos(a),sin(a))*15-Vector2.ONE,Vector2(2,2)),Color("f7d080",.8))
		g.draw_rect(Rect2(-2,-2,4,4),Color("15162c",.7))
		g.draw_rect(Rect2(-1,-1,2,2),Color("fff9e8"))
		g.draw_set_transform(Vector2.ZERO)
		if in_flight and scale_factor==1:
			g.text_at(str(index+1),p.pos+Vector2(-3,-24),g.COLORS[index])
		return
	for side in [-1,1]:
		var length=10+int(g.clock*24)%3*3+int(direction.x>0)*7
		g.draw_colored_polygon(PackedVector2Array([Vector2(-23,side*7-2),Vector2(-26-length,side*7),Vector2(-23,side*7+3)]),Color("375778"))
		g.draw_line(Vector2(-24,side*7),Vector2(-24-length*.7,side*7),tint,2)
		g.draw_line(Vector2(-24,side*7),Vector2(-29,side*7),Color("fff3d5"),1)
	var modulation=Color(.55,.78,1,.7) if p.get("inv",0)>0 and int(g.clock*12)%2==0 else Color.WHITE
	g.draw_texture_rect_region(atlas,Rect2(-28,-18,56,36),Rect2(state*56,0,56,36),modulation)
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
	var tex=creatures[1 if technique=="fan" or technique=="orbit" else 0]
	var opening=clampf((.65-e.cool)/.65,0,1)
	# A short, exact firing lane tells the player where this organism's next
	# pattern will travel. It uses the same target and angle rules as game.gd,
	# including the deliberately narrow fan gap; this is a readability aid, not
	# an extra attack or a damage change.
	if opening>.08 and not g.players.is_empty():
		var target=g.players[g.wave_id%g.players.size()].pos
		var offsets=[-.2,0,.2] if technique=="fan" else ([0] if technique=="dive" else [-.11,.11])
		var telegraph_color={"fan":Color("ffbd78"),"weave":Color("cfa2ff"),"dive":Color("ff8f88"),"orbit":Color("9ee7ef")}.get(technique,Color("ffe2a3"))
		var lane_length=18+opening*48
		for offset in offsets:
			var lane=(target-e.pos).normalized().rotated(offset)
			g.draw_line(e.pos+lane*8,e.pos+lane*lane_length,Color(telegraph_color,.13+opening*.48),1)
		if technique=="dive" and opening>.46:
			# P02: for the final 0.35s the needle line is shown as one long
			# white aim line - the burst that follows is locked to it.
			var aim=(target-e.pos).normalized()
			g.draw_line(e.pos+aim*10,e.pos+aim*210,Color(1,1,1,.45+.3*sin(g.clock*22.0)),1)
		if opening>.54:g.draw_arc(e.pos,10+opening*7,0,TAU,18,Color(telegraph_color,.35+opening*.4),1)
	# Bank into the vertical movement like a flying creature leaning into its
	# curve. The old position-coupled wobble (tilt + 5Hz squash pulse) made
	# every enemy tremble constantly; banking is smooth and purposeful.
	var vertical=g.vertical.active
	# In vertical sections the hull is already rotated 90 degrees; banking
	# on the fast descent axis made organisms tremble unpleasantly, so the
	# bank is dropped there, the sway is damped and the breathing scale is
	# kept uniform (it otherwise stretches along the rotated axis).
	var bank=0.0 if vertical else clampf((e.pos.y-e.get("prev_y",e.pos.y))*.22,-.35,.35)
	var tilt=(PI/2 if vertical else 0.0)+bank
	# Idle sway: each organism drifts on its own slow ellipse, so the swarm
	# reads as living things holding position, not sprites on rails. This is
	# draw-only - e.pos (and therefore every hitbox) never moves. A diving
	# enemy stills itself as its burst approaches, which sharpens the P02
	# telegraph: the quiet before the strike is visible.
	var age=e.get("age",0.0)
	var phase=e.get("phase",0.0)
	if phase==0.0:phase=fposmod(e.pos.x*.37+e.pos.y*.91,TAU)
	var sway_amp={"weave":4.5,"orbit":3.0,"fan":2.2}.get(technique,2.8)
	if technique=="dive":sway_amp=lerpf(2.6,.4,opening)
	var sway=Vector2(sin(age*.9+phase)*sway_amp,cos(age*1.13+phase*1.7)*sway_amp*.7)
	if vertical: sway*=.45
	var escale=Vector2.ONE*(1+sin(age*1.3+phase)*.015) if vertical else Vector2(1,1+sin(age*1.3+phase)*.02)
	escale*=float(e.get("bscale",1.0))
	# Technique tints give each behaviour a readable colour family, and the
	# vertical route shifts cooler/darker so it does not read as the same
	# horizontal images merely rotated.
	var tint={"weave":Color(1.05,.9,1.1),"dive":Color(1.1,.95,.85),"orbit":Color(.9,1.05,1.05),"fan":Color(1.08,1.0,.85)}.get(technique,Color.WHITE)
	if vertical: tint*=Color(.85,.9,1.05)
	g.draw_set_transform((e.pos+sway).round(),tilt,escale)
	g.draw_texture(tex,-tex.get_size()*.5,Color(1,.7,.65) if e.get("flash",0)>0 else tint)
	if opening>0:g.draw_arc(Vector2(-tex.get_width()*.31,0),4+opening*7,PI*.55,PI*1.45,12,Color("fff0b7"),1)
	if technique=="weave":g.draw_arc(Vector2(3,0),12,-PI*.6,PI*.6,10,Color("e6b6a0"),1)
	elif technique=="orbit":g.draw_arc(Vector2.ZERO,15,0,TAU,12,Color("b8d7dd"),1)
	g.draw_set_transform(Vector2.ZERO)
	if float(e.get("frozen",0.0))>0:
		# Frozen solid: a pale ice shell over the organism.
		g.draw_arc(e.pos,20,0,TAU,14,Color("bfe9ff",.85),2)
		g.draw_arc(e.pos,14,0,TAU,10,Color("e8f7ff",.5),1)
		g.draw_line(e.pos+Vector2(-13,-13),e.pos+Vector2(13,13),Color("bfe9ff",.45),1)
		g.draw_line(e.pos+Vector2(13,-13),e.pos+Vector2(-13,13),Color("bfe9ff",.45),1)
	if e.hp<=3 and g.players.any(func(p):return p.character==2 and p.down==0 and p.pos.distance_to(e.pos)<85):
		g.draw_arc(e.pos,27,PI*.65,PI*1.35,10,Color("d4b576"),1)
	if int(e.get("subboss",0))>0:
		# Boss-tier organisms carry a labelled HP bar (mini / mid).
		var frac=clampf(float(e.hp)/maxf(1.0,float(e.get("max_hp",e.hp))),0,1)
		var bw=64.0
		var by=e.pos.y-30.0*float(e.get("bscale",1.0))-12
		g.draw_rect(Rect2(e.pos.x-bw/2,by,bw,5),Color(0,0,0,.55))
		g.draw_rect(Rect2(e.pos.x-bw/2,by,bw*frac,5),Color("ff668e") if int(e.subboss)==1 else Color("ffce63"))
		g.japanese("小ボス" if int(e.subboss)==1 else "中ボス",Vector2(e.pos.x-15,by-4),10,Color(1,1,1,.9))

func projectile(g,b,hostile=false):
	g.draw_set_transform(b.pos.round(),b.get("vel",Vector2.RIGHT).angle())
	if hostile:
		var kind=str(b.get("kind","petal"))
		var tex: Texture2D = g.bullet_enemy_tex
		if kind=="needle": tex=g.bullet_needle_tex
		elif kind=="eye": tex=g.bullet_eye_tex
		elif kind=="ring": tex=g.bullet_ring_tex
		if tex != null:
			if kind=="ring":
				# Ring bullets carry the P05 pattern; draw them larger so the
				# expanding wheel reads at a glance.
				g.draw_texture_rect(tex, Rect2(-10, -10, 20, 20), false)
			else:
				g.draw_texture(tex, -tex.get_size() / 2)
		elif kind=="needle":
			g.draw_line(Vector2(-9,0),Vector2(7,0),Color("dfe9f2"),2)
			g.draw_line(Vector2(-9,0),Vector2(7,0),Color("fff8d8"),1)
		elif kind=="eye":
			g.draw_circle(Vector2.ZERO,b.r+1,Color("111026"))
			g.draw_circle(Vector2.ZERO,b.r,Color("c61e34"))
			g.draw_circle(Vector2(1,0),2,Color("fff4ee"))
		elif kind=="ring":
			g.draw_arc(Vector2.ZERO,b.r+2,0,TAU,12,Color("e22a52"),2)
			g.draw_circle(Vector2.ZERO,1.5,Color("ffd678"))
		else:
			g.draw_line(Vector2(-b.r-5,0),Vector2(-b.r,0),Color("ae4c55"),2)
			g.draw_circle(Vector2.ZERO,b.r+1,Color("111026"))
			g.draw_circle(Vector2.ZERO,b.r,Color("ffbd78"))
			g.draw_circle(Vector2(1,0),maxf(1,b.r-2),Color("fff8d8"))
	else:
		var p=g.players[b.owner]
		# Each pilot's fire carries a hint of their own colour (user
		# note 2026-11-23); the relay colour still dominates, so the
		# boss colour-matching stays readable at a glance.
		var col=g.COLORS[b.color].lerp([Color("ff7d9c"),Color("9fe8ff"),Color("ffce63")][p.character],.45)
		if b.get("kind","")=="wave":
			g.draw_circle(Vector2.ZERO,5,Color(col,.30))
			g.draw_circle(Vector2.ZERO,3,col)
			g.draw_circle(Vector2(1,0),1.5,Color("fff8d7"))
		elif b.get("kind","")=="ripple":
			g.draw_arc(Vector2.ZERO,float(b.get("br",8.0)),0,TAU,18,Color("bfe9ff",.85),2)
			g.draw_arc(Vector2.ZERO,float(b.get("br",8.0))*.6,0,TAU,14,Color(col,.7),1)
			g.draw_circle(Vector2.ZERO,1.5,Color("fff8d7"))
		elif p.character==1:
			g.draw_line(Vector2(-13,0),Vector2(6,0),Color(col,.35),5)
			g.draw_line(Vector2(-10,0),Vector2(6,0),col,2)
			g.draw_line(Vector2(-4,0),Vector2(5,0),Color("fff8d7"),1)
		elif g.bullet_player_tex != null:
			g.draw_texture(g.bullet_player_tex, -g.bullet_player_tex.get_size() / 2, col)
		elif p.character==2 and p.learned!="none":
			g.draw_arc(Vector2(-3,0),4,-PI*.7,PI*.7,8,col,2)
			g.draw_line(Vector2(-4,0),Vector2(5,0),Color("fff8d7"),1)
		else:
			g.draw_colored_polygon(PackedVector2Array([Vector2(-12,0),Vector2(-2,-3),Vector2(7,0),Vector2(-2,3)]),Color(col,.7))
			g.draw_line(Vector2(-4,0),Vector2(5,0),Color("fff8d7"),1)
	g.draw_set_transform(Vector2.ZERO)

func boss(g):
	var p=g.boss.pos
	var anticipation=clampf((.65-g.boss.cool)/.65,0,1)
	# Show the actual fan lanes shortly before release.  This is intentionally
	# drawn from the same formula as update_boss(), so the warning teaches the
	# safe gaps instead of adding another, misleading visual pattern.
	if anticipation>.08:
		var phase=1 if not g.bio_route or not g.bio.exposed() else (3 if g.boss.hp<g.boss.max*.5 else 2)
		var muzzle=p+Vector2(-35,0)
		var alpha=.10+anticipation*.42
		if phase>=2 and (g.boss.volleys+1)%4==0:
			# P05: the next volley is a ring expansion, not a fan - warn with a
			# growing crimson circle instead of fan lanes.
			g.draw_arc(p,20+anticipation*26,0,TAU,36,Color(1,.36,.44,alpha+.15),2)
			g.draw_arc(p,12+anticipation*14,0,TAU,28,Color(1,.72,.6,alpha),1)
		else:
			# P01: fan lanes use the exact update_boss formula, fan_bonus incl.
			var fan=(7 if phase==3 else 5)+(int(g.stage_def()["fan_bonus"]) if phase>=2 else 0)
			for j in range(fan):
				var angle=PI+(j-(fan-1)*.5)*.24+sin(g.boss.age)*.15
				var lane=Vector2.from_angle(angle)
				g.draw_line(muzzle+lane*8,muzzle+lane*(34+anticipation*58),Color(1,.58,.46,alpha),1)
			if anticipation>.55:
				g.draw_arc(muzzle,8+anticipation*8,0,TAU,20,Color(1,.82,.57,alpha),1)
	if int(g.boss.get("rings",0))>0:
		# A ring sequence is live: keep a pulsing halo on the boss.
		g.draw_arc(p,30+sin(g.clock*9.0)*3,0,TAU,36,Color(1,.4,.48,.5),2)
	# The whole body bobs on a slow breath. Telegraph lanes above keep the
	# true position; only the flesh moves, and by less than 3 pixels.
	var bob=Vector2(0,sin(g.clock*.7)*2.5)
	for side in [-1,1]:
		var pts=PackedVector2Array()
		for j in range(12):pts.append(p+bob+Vector2(55-j*9,side*(38+sin(j*.24+g.clock*1.8)*13+anticipation*j*1.3)))
		g.draw_polyline(pts,Color("301d34"),9)
		g.draw_polyline(pts,Color("a65a70"),3)
		g.draw_polyline(pts,Color("ecc2a2"),1)
	g.draw_texture_rect(creatures[2],Rect2(p+bob+Vector2(-40,-77),Vector2(164,154+sin(g.clock*2.8)*3)),false,Color(1,.7,.7) if g.boss.flash>0 else Color.WHITE)
	var core=g.COLORS[g.boss.color] if g.bio.exposed() else Color("542d48")
	g.draw_circle(p+bob,18,Color("0b1023"))
	g.draw_arc(p+bob,18,0,TAU,28,Color("c28d78"),2)
	g.draw_circle(p+bob,12+sin(g.clock*2.8),core)
	if g.bio.exposed():g.draw_arc(p+bob,15+anticipation*4,0,TAU,24,Color("fff5c7"),1)
	for i in range(g.bio.armor.size()):
		var a=g.bio.part_pos(g,i)
		if g.bio.armor[i]>0:
			g.draw_texture(creatures[3],a-Vector2(27,27))
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
	for pl in pillars:
		# V15 pickup pillar: a coloured beam shoots up from the collection point.
		var k = pl.age / .45
		var col = Color(1, .45, .55) if pl.kind == 0 else (Color(1, .8, .35) if pl.kind == 2 else Color(.45, .8, 1))
		var hgt = 42.0 * (1 - k * .25)
		for w in range(3):
			var width = [11, 6, 3][w]
			g.draw_rect(Rect2(pl.pos + Vector2(-width / 2.0, -hgt), Vector2(width, hgt)), Color(col, [.10, .22, .45][w] * (1 - k)))
		g.draw_arc(pl.pos, 5 + k * 9, 0, TAU, 20, Color(col, .7 * (1 - k)), 1)
	for h in hits:
		if g.fx_spark_tex != null:
			# V02 hit spark: a four-point star that pops and fades in 0.16s.
			var k = h.age / .16
			g.draw_set_transform(h.pos, h.age * 2.2, Vector2.ONE * (0.7 + k * 0.9))
			g.draw_texture(g.fx_spark_tex, -g.fx_spark_tex.get_size() / 2, Color(1, 1, 1, 1 - k))
			g.draw_set_transform(Vector2.ZERO)
		else:
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
				if g.fx_petal_tex != null:
					# V01 sange: crimson petals scatter and spin instead of blobs.
					# Petal size/alpha follow the petal's own age, not the old blob
					# radius: tied to r they shrank to ~3px and vanished mid-burst.
					var fade = clampf(1.3 - age / (.45 + e.size * .2), 0.0, 1.0)
					g.draw_set_transform(center, i * 2.399 + age * 5.0, Vector2.ONE * clampf(1.9 - age * 1.1, 1.0, 1.9))
					g.draw_texture(g.fx_petal_tex, -g.fx_petal_tex.get_size() / 2, Color(1, 1, 1, fade))
					g.draw_set_transform(Vector2.ZERO)
				else:
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

func membrane_draw(g):
	# Living gate: a vertical membrane wall spanning the route, drawn as an
	# undulating band with veins and one glowing core (its only weak point).
	var m=g.membrane
	var x=float(m.x)
	var t=g.clock
	var left=PackedVector2Array()
	var right=PackedVector2Array()
	for j in range(18):
		var y=40+j*16.5
		var wob=sin(y*.05+t*2.2)*6
		left.append(Vector2(x-13+wob,y))
		right.append(Vector2(x+13+wob,y))
	var band=PackedVector2Array()
	band.append_array(left)
	for j in range(17,-1,-1): band.append(right[j])
	g.draw_colored_polygon(band,Color("2a0d18",.94))
	g.draw_polyline(left,Color(.72,.3,.37,.65),2)
	g.draw_polyline(right,Color(.72,.3,.37,.65),2)
	for v in range(3):
		var vein=PackedVector2Array()
		for j in range(18):
			var y=40+j*16.5
			vein.append(Vector2(x+sin(y*.05+t*2.2)*6+sin(y*.11+v*2.1+t)*5,y))
		g.draw_polyline(vein,Color(.55,.2,.3,.35),1)
	var core=g.membrane_core()
	var frac=clampf(float(m.hp)/float(m.max),0,1)
	var pulse=.5+.5*sin(t*3.2)
	g.draw_circle(core,21+3*pulse,Color(.9,.3,.3,.14+.12*pulse))
	g.draw_circle(core,15,Color("57182b") if frac<.5 else Color("7d2138"))
	g.draw_circle(core,8,Color(1,.62,.45) if float(m.get("flash",0))>0 else Color(1,.45,.4))
	g.draw_circle(core,3.5,Color("ffe9c9"))
	if frac<.5:
		for c in range(3):
			var a=c*2.2+.6
			g.draw_line(core+Vector2.from_angle(a)*6,core+Vector2.from_angle(a)*14,Color(.1,.02,.05,.8),1)
	g.draw_arc(core,25,-PI/2,-PI/2+TAU*frac,28,Color(1,.62,.5,.85),2)

func draw(g):
	background(g)
	if not g.membrane.is_empty(): membrane_draw(g)
	if g.mode=="controls":g.draw_controls();return
	if g.mode=="menu":g.draw_menu();return
	if g.mode=="select":g.draw_select_screen();return
	if g.gate>0:g.draw_gate()
	for o in g.bio.organs:
		g.draw_texture(creatures[3],o.pos-Vector2(27,27))
		if o.cool<.6:g.draw_arc(o.pos,25,0,TAU,24,Color("ffd0a0"),1)
	for e in g.enemies:enemy(g,e)
	for b in g.bullets:projectile(g,b)
	for b in g.shots:projectile(g,b,true)
	for item in g.pickups:
		var item_tex = g.item_hp_tex if item.kind==0 else g.item_energy_tex
		if item_tex != null:
			g.draw_texture(item_tex, item.pos - item_tex.get_size() / 2)
		else:
			g.draw_arc(item.pos,7,0,TAU,12,g.COLORS[item.kind*2],1)
			g.text_at("+" if item.kind==0 else "E",item.pos-Vector2(2,3))
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
		if float(p.get("beam",0.0))>0:
			var nose=p.pos+Vector2(20,0)
			var endx=660.0
			for e in g.enemies:
				if e.hp>0 and e.pos.x>p.pos.x and absf(e.pos.y-p.pos.y)<16: endx=minf(endx,e.pos.x-8)
			g.draw_line(nose,Vector2(endx,p.pos.y),Color(g.COLORS[p.color].lerp(Color("9fe8ff"),.45),.35),7)
			g.draw_line(nose,Vector2(endx,p.pos.y),Color(g.COLORS[p.color].lerp(Color("9fe8ff"),.45),.8),3)
			g.draw_line(nose,Vector2(endx,p.pos.y),Color("ffffff"),1)
		if int(p.get("options",0))>0:
			var op=p.get("option_pos",p.pos+Vector2(-16,20))
			g.draw_circle(op,5,Color(g.COLORS[p.color],.9))
			g.draw_circle(op,2.2,Color("fff8d7"))
			g.draw_arc(op,7,0,TAU,12,Color(g.COLORS[p.color],.5),1)
	effects(g)
	hud(g)
	if g.notice_time>0:
		# tell() messages (predation, omikuji, gates, warnings) must
		# render in v09 mode too - they were legacy-only, so every
		# in-game announcement was silently invisible until now.
		g.draw_rect(Rect2(0,47,640,19),Color(0.02,.04,.1,.85))
		g.japanese(g.notice,Vector2(320-g.notice.length()*5,61),10,g.COLORS[2])
	# Stage title card: centered, fades in and out once at the
	# start of the stage (user note 2026-11-23).
	if g.title_card_in_game and g.mode=="play" and g.elapsed<3.0:
		var ta=clampf(g.elapsed/0.6,0.0,1.0)*clampf((3.0-g.elapsed)/0.8,0.0,1.0)
		var sname=g.briefing_progress.stage_name(g.current_stage)
		var label="STAGE "+str(g.current_stage)
		g.text_at(label,Vector2(320-label.length()*9,118),Color(1,1,1,ta),3)
		var kw=sname.length()*17*3
		g.draw_pixel_kanji(sname,Vector2(320-kw/2,146),3,Color("f0ddd0",ta))
		g.draw_line(Vector2(320-kw/2,196),Vector2(320+kw/2,196),Color("ffce63",ta*.8),2)
	for i in range(g.count):
		var kl=g.kuu_lines[i]
		if kl.t>0:
			# Kuu speaks in a framed message window under her pilot's
			# card: double frame with a name plate set into the rim.
			var kx=12+i*155
			var ka=minf(1.0,kl.t)
			g.draw_rect(Rect2(kx,68,148,17),Color(0.03,.05,.12,.88*ka))
			g.draw_rect(Rect2(kx,68,148,17),Color("8b7f9e",.85*ka),false,1)
			g.draw_rect(Rect2(kx+2,70,144,13),Color("e8b7d4",.35*ka),false,1)
			g.draw_rect(Rect2(kx+4,64,26,9),Color("3a2438",ka))
			g.draw_rect(Rect2(kx+4,64,26,9),Color("e8b7d4",.7*ka),false,1)
			g.japanese("クゥ",Vector2(kx+8,72),8,Color("e8b7d4",ka))
			g.japanese(kl.text,Vector2(kx+6,82),9,Color("f1e3d2",ka))
	if g.vertical.active and (g.vertical.age<2 or g.vertical.age>g.vertical.duration-2):
		g.japanese("進路転換：上へ射撃" if g.vertical.age<2 else "進路転換：右へ射撃",Vector2(217,177),17,Color("f1dfbe"))
	if g.mode=="pause":
		g.draw_rect(Rect2(0,100,640,150),Color(0,.02,.06,.9))
		g.centered("PAUSED / START TO RESUME",160,g.WHITE,2)
		g.japanese("F10 振動調整 / F12 閃光調整 / Q タイトル",Vector2(160,210),12)
	elif g.mode in ["clear","over"]:g.draw_result()

func hud(g):
	# The play HUD uses the same framed, warm-metal language as the sortie card:
	# pilots read left-to-right, while score and reserves are deliberately isolated.
	g.draw_rect(Rect2(0,0,640,47),Color("070d1d"))
	g.draw_rect(Rect2(7,3,626,43),Color("0e1930"))
	g.draw_rect(Rect2(7,3,626,43),Color("6d576b"),false,1)
	g.draw_line(Vector2(12,45),Vector2(628,45),Color("b08075"),1)
	for i in range(g.count):
		var p=g.players[i]
		var x=12+i*155
		g.draw_rect(Rect2(x,6,148,19),Color("16233f"))
		g.draw_rect(Rect2(x,25,148,19),Color("0c1526"))
		g.draw_rect(Rect2(x,6,148,38),Color(g.COLORS[i],.72),false,1)
		g.draw_rect(Rect2(x+2,8,144,34),Color(0,0,0,.35),false,1)
		g.draw_rect(Rect2(x+3,7,142,1),Color(1,1,1,.14))
		g.draw_rect(Rect2(x,6,3,38),g.COLORS[i])
		g.text_at("P"+str(i+1),Vector2(x+9,11),g.COLORS[i])
		g.japanese(g.PILOT_NAMES[p.character],Vector2(x+31,18),12,Color("f1e3d2"))
		g.japanese("HULL",Vector2(x+9,31),8,Color("9f9bb0"))
		for j in range(4):
			g.draw_rect(Rect2(x+38+j*8,26,5,4),g.COLORS[i] if j<p.hp else Color("34364c"))
			if j<p.hp: g.draw_rect(Rect2(x+38+j*8,26,5,1),Color(1,1,1,.5))
		g.draw_rect(Rect2(x+75,26,42,4),Color("34364c"))
		g.draw_rect(Rect2(x+75,26,p.charge*.42,4),g.COLORS[i])
		for tk in range(1,4): g.draw_rect(Rect2(x+75+tk*10,26,1,4),Color("0c1526"))
		if p.charge>0: g.draw_rect(Rect2(x+75+maxf(0.0,p.charge*.42-3),26,3,4),Color(1,1,1,.65))
		g.text_at("LV"+str(g.Abilities.level(p)+1),Vector2(x+118,8),Color("ffe9b0"))
		g.draw_circle(Vector2(x+126,28),3,g.COLORS[p.color])
		if p.charge>=100:
			g.text_at("B",Vector2(x+136,24),Color("fff2cb"))
		# Live stat line (user note 2026-11-22): luck / analysis /
		# digestion readable at a glance, not an 8px footnote.
		if p.character==0:
			var title=g.Abilities.luck_title(p)
			g.japanese("運気"+str(int(p.luck))+" "+title,Vector2(x+75,43),9,Color("ffce63") if title=="大吉" else (Color("ff668e") if title=="凶" else Color("b6a9b6")))
		elif p.character==1:
			g.japanese("解析"+str(int(p.get("analysis_charge",0)))+"%",Vector2(x+75,43),9,Color("9fe8ff"))
		else:
			g.japanese(g.Abilities.label(p,g.elapsed),Vector2(x+75,43),9,Color("f5c777") if p.learned!="none" or p.digest>0 else Color("b6a9b6"))
			if p.digest>0:
				var frac=1.0-p.digest/maxf(0.01,p.digest_total)
				g.draw_rect(Rect2(x+128,40,16,4),Color("34364c"))
				g.draw_rect(Rect2(x+128,40,frac*16,4),Color("f5c777"))
	# Score card stays static even when player cards change between 1–3P.
	g.draw_rect(Rect2(480,6,148,19),Color("1d1c33"))
	g.draw_rect(Rect2(480,25,148,19),Color("12101f"))
	g.draw_rect(Rect2(480,6,148,38),Color("8b6971"),false,1)
	g.draw_rect(Rect2(482,8,144,34),Color(0,0,0,.35),false,1)
	g.japanese("SCORE",Vector2(490,18),9,Color("aa9eaa"))
	g.text_at("%07d"%g.score,Vector2(544,13),Color("fff0d3"))
	g.japanese("予備機",Vector2(490,35),10,Color("b8aab1"))
	g.text_at("x"+str(g.reserves),Vector2(548,30),Color("f5c777"))
	g.draw_rect(Rect2(0,337,640,23),Color("070d1d"))
	g.draw_rect(Rect2(8,340,624,16),Color("0e1930"))
	g.draw_rect(Rect2(8,340,624,16),Color("594d62"),false,1)
	g.draw_rect(Rect2(286,346,150,3),Color("34364c"))
	g.draw_rect(Rect2(286,346,minf(150,g.travel/4800.0*150),3),Color("d57b73"))
	g.japanese("X 色  /  B 固有技  /  START 停止",Vector2(454,352),9,Color("aaa2b5"))

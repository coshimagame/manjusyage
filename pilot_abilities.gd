extends RefCounted

# ABILITY-001: numerical tuning is provisional, canon describes the behavior.
static func initialize(p, character):
	p.character=character
	p.experience=0
	p.learned="none"
	p.digest=0.0
	p.digest_total=1.2
	p.pending_technique="none"
	p.fusion_flash=0.0

static func level(p):
	return mini(3,int(p.experience/8))

static func damage(p, time):
	var growth=level(p)
	if p.character==0:
		var phase=fposmod(time,8.0)
		if phase<1.5: return 2.4+growth*.7
		if phase<3.0: return .55+growth*1.0
		return 1.0+growth*.8
	if p.character==1: return 1.0+growth*1.3
	return 1.0+growth*.2

static func label(p,time):
	if p.character==0:
		var phase=fposmod(time,8.0)
		return "高出力" if phase<1.5 else ("反動" if phase<3 else ("増幅予告" if phase>6.5 else "安定"))
	if p.character==1: return "解析 Lv"+str(level(p)+1)
	return "消化中" if p.digest>0 else ("捕食待ち" if p.learned=="none" else "習得："+("拡散" if p.learned=="fan" else "狙い撃ち"))

static func digest(p,dt):
	if p.digest<=0: return
	p.digest=maxf(0,p.digest-dt)
	p.fusion_flash=maxf(0,p.get("fusion_flash",0.0)-dt)
	if p.digest==0:
		p.learned=p.pending_technique
		p.experience+=8
		p.fusion_flash=.7

static func eat(g,p) -> bool:
	if p.digest>0 or p.charge<40: return false
	for e in g.enemies:
		if e.hp>0 and e.hp<=3 and p.pos.distance_to(e.pos)<85:
			p.charge-=40
			p.pending_technique=e.get("technique","aimed")
			p.digest_total=1.2
			p.digest=p.digest_total
			if g.get("mafio_archive")!=null: g.mafio_archive.capture(e)
			e.hp=0
			g.explode(e.pos,Color("ffdf86"),18)
			g.sfx("consume_v09" if g.art_v09 else "pickup")
			return true
	return false

static func velocities(p,forward,targets):
	if p.character!=2 or p.learned=="none": return [forward*390]
	if p.learned=="fan": return [forward.rotated(-.15)*390,forward*390,forward.rotated(.15)*390]
	# Current Red Echo organisms: each capture yields a distinct, readable spread.
	if p.learned=="weave": return [forward.rotated(-.18)*350,forward.rotated(.18)*350]
	if p.learned=="dive": return [forward*480]
	if p.learned=="orbit": return [forward.rotated(-.32)*300,forward*330,forward.rotated(.32)*300]
	# These captured patterns only change the player's original projectile spread.
	# They do not claim unimplemented effects such as penetration or homing.
	if p.learned=="petal": return [forward.rotated(-.28)*350,forward.rotated(-.12)*380,forward*400,forward.rotated(.12)*380,forward.rotated(.28)*350]
	if p.learned=="seed": return [forward.rotated(-.22)*320,forward*390,forward.rotated(.22)*320]
	if p.learned=="halo": return [forward.rotated(-.45)*260,forward.rotated(-.2)*310,forward*360,forward.rotated(.2)*310,forward.rotated(.45)*260]
	if p.learned=="beam": return [forward*520]
	if p.learned=="pierce": return [forward*450] # 弾速のみ。貫通判定は未実装。
	var nearest=null
	var distance=10000.0
	for e in targets:
		var delta=e.pos-p.pos
		if e.hp>0 and delta.dot(forward)>0 and delta.length()<distance:
			distance=delta.length(); nearest=e
	return [(nearest.pos-p.pos).normalized()*390] if nearest!=null else [forward*390]

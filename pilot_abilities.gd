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
	p.luck=50
	p.fortune_history=[]
	p.analysis_charge=0
	p.analysis_uses=0

static func level(p):
	return mini(3,int(p.experience/8))

# C-065: Cormii fortune. Omikuji redraws luck (5-100, may go down);
# normal shots never drain it; only a charged shot consumes 8 points.
static func draw_omikuji(p, value):
	var before=int(p.get("luck",50))
	var after=clampi(int(value),5,100)
	p.luck=after
	var record={"before":before,"after":after,"delta":after-before}
	if p.get("fortune_history")==null: p.fortune_history=[]
	p.fortune_history.append(record)
	return record

static func chance_profile(p, roll):
	var t=clampf(float(p.get("luck",50))/100.0,0.0,1.0)
	var jackpot_chance=lerpf(.08,.46,t)
	var low_chance=lerpf(.36,.06,t)
	var grade="normal"
	if roll>=1.0-jackpot_chance: grade="jackpot"
	elif roll<low_chance: grade="low"
	return {"grade":grade,"jackpot_chance":jackpot_chance,"low_chance":low_chance}

static func consume_charged_luck(p):
	p.luck=maxi(0,int(p.get("luck",50))-8)
	return p.luck

static func luck_title(p):
	var luck=int(p.get("luck",50))
	if luck>=80: return "大吉"
	if luck>=60: return "中吉"
	if luck>=40: return "吉"
	if luck>=20: return "末吉"
	return "凶"

static func damage(p, time, roll=-1.0):
	var growth=level(p)
	if p.character==0:
		var phase=fposmod(time,8.0)
		var base=1.0+growth*.8
		if phase<1.5: base=2.4+growth*.7
		elif phase<3.0: base=.55+growth*1.0
		if roll>=0.0:
			var grade=chance_profile(p,roll).grade
			if grade=="jackpot": return maxf(base,2.2+growth*.7)
			if grade=="low": return .55+growth*.5
		return base
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
		# Digestion finished: the temporary equipment is spent.
		p.learned="none"
		p.pending_technique="none"
		p.experience+=8
		p.fusion_flash=.7

static func eat(g,p) -> bool:
	if p.digest>0 or p.charge<40: return false
	for e in g.enemies:
		if e.hp>0 and e.hp<=3 and int(e.get("subboss",0))==0 and p.pos.distance_to(e.pos)<85:
			p.charge-=40
			p.pending_technique=e.get("technique","aimed")
			# Current rules: the captured pattern is equipped immediately,
			# and digestion restores regular fire when it completes.
			p.learned=p.pending_technique
			p.digest_total=1.2
			p.digest=p.digest_total
			if g.get("mafio_archive")!=null: g.mafio_archive.capture(e)
			e.hp=0
			g.explode(e.pos,Color("ffdf86"),30)
			g.sfx("consume_v09" if g.art_v09 else "pickup")
			# Success must be unmistakable (user note 2026-11-22): a gold
			# pillar rises on Mafio and a tell names the captured technique.
			if g.art_v09: g.visual.pillar(p.pos,2)
			var tech_names={"fan":"拡散","weave":"蛇行","dive":"突撃","orbit":"周回","aimed":"狙撃"}
			g.kuu_say(g.players.find(p),"捕食成功：『" + str(tech_names.get(p.learned,"")) + "』習得",3.5)
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

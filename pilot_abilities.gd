extends RefCounted

# ABILITY-001: numerical tuning is provisional, canon describes the behavior.
static func initialize(p, character):
	p.character=character
	p.experience=0
	p.learned="none"
	p.digest=0.0
	p.digest_total=1.0
	p.shot_hold=0.0
	p.analysis_charge=0 # Separate Jiyoza scanner gauge; only scan crystals fill it.
	p.analysis_uses=0 # Max twice per stage.
	p.pending_technique="none"
	# Purely visual cue; it never alters a weapon or enemy hitbox.
	p.fusion_flash=0.0
	p.luck=50 # Cormii: fortune % shown as current omen, not guaranteed damage.
	p.fortune_history=[] # Session-only log; Stage 6 diary is a later feature.
	p.last_power_grade="normal"

static func level(p):
	return mini(3,int(p.experience/8))

# Current luck changes the chance of weak and jackpot volleys; it never
# guarantees an outcome. A charged attack inherits this random roll.
# Fortune is NOT permanent and does not use the old cumulative stability tiers.
static func chance_profile(p, roll: float) -> Dictionary:
	var fortune=clampf(float(p.get("luck",50))/100.0,0.0,1.0)
	var unlucky=lerpf(.36,.06,fortune)
	var jackpot=lerpf(.08,.46,fortune)
	if roll<unlucky: return {"power":.55,"grade":"low"}
	if roll>=1.0-jackpot: return {"power":3.0,"grade":"jackpot"}
	return {"power":1.0,"grade":"normal"}

static func draw_omikuji(p, result: int) -> Dictionary:
	var before=clampi(int(p.get("luck",50)),0,100)
	var after=clampi(result,0,100)
	p.luck=after
	p.fortune_history.append({"event":"おみくじ","before":before,"after":after})
	if p.fortune_history.size()>8: p.fortune_history.pop_front()
	return {"before":before,"after":after,"delta":after-before}

static func consume_charged_luck(p) -> int:
	# One fixed 8-point decline per fired charge shot, regardless of damage.
	var before=clampi(int(p.get("luck",50)),0,100)
	p.luck=maxi(0,before-8)
	p.fortune_history.append({"event":"溜め撃ち","before":before,"after":int(p.luck)})
	if p.fortune_history.size()>8: p.fortune_history.pop_front()
	return int(p.luck)

static func luck_title(p) -> String:
	var value=int(p.get("luck",50))
	if value>=85: return "大吉"
	if value>=65: return "中吉"
	if value>=45: return "吉"
	if value>=25: return "末吉"
	return "凶"

static func damage(p, time, roll: float=.5):
	var growth=level(p)
	if p.character==0:
		var outcome=chance_profile(p,roll)
		p.last_power_grade=outcome.grade
		return float(outcome.power)*(1.0+growth*.75)
	if p.character==1: return 1.0+growth*1.3
	return 1.0+growth*.2

static func label(p,time):
	if p.character==0:
		return "運気 "+str(int(p.get("luck",50)))+"% / "+luck_title(p)
	if p.character==1: return "解析 Lv"+str(level(p)+1)
	return ("一時装備："+("拡散" if p.learned=="fan" else "狙い撃ち")+" "+str(snappedf(p.digest,.1))+"秒") if p.digest>0 else "通常武器"

# Captured enemy ability is ACTIVE during digestion, then returns to
# normal shots when the enemy-specific digestion timer ends.
static func digest(p,dt):
	if p.digest<=0: return
	p.digest=maxf(0,p.digest-dt)
	if p.digest<=0:
		p.learned="none"
		p.pending_technique="none"
		p.experience+=8
		p.fusion_flash=.72

static func digestion_seconds(enemy) -> float:
	# Each enemy can override this with digest_seconds when introduced.
	var variations={"aimed":8.0,"fan":5.5,"pierce":5.0,"pulse":6.5,"curve":7.0,
		"delay":7.5,"petal":5.5,"seed":4.5,"phase":7.5,"bend":6.5,
		"predict":8.0,"echo":6.0,"halo":9.0,"beam":4.0,"boomerang":6.5,
		"return":5.5,"sync":8.5,"shield":7.0}
	return clampf(float(enemy.get("digest_seconds",variations.get(str(enemy.get("technique","aimed")),6.0))),2.0,20.0)

static func eat(g,p) -> bool:
	if p.digest>0 or p.charge<40: return false
	for e in g.enemies:
		if e.hp>0 and e.hp<=3 and p.pos.distance_to(e.pos)<85:
			p.charge-=40
			p.pending_technique=e.get("technique","aimed")
			p.learned=p.pending_technique # Equipped immediately on capture.
			p.digest_total=digestion_seconds(e)
			# Record which enemy body Mafio actually swallowed, not merely killed.
			g.mafio_archive.capture(e)
			p.digest=p.digest_total
			p.fusion_flash=.9 # Captured a technique: first luminous convergence
			e.hp=0
			g.explode(e.pos,Color("ffdf86"),18)
			g.sfx("pickup")
			return true
	return false

static func velocities(p,forward,targets):
	if p.character!=2 or p.learned=="none": return [forward*390]
	# Experimental captured-weapon patterns. All return shot velocities only;
	# collision, penetration and status effects remain the caller's responsibility.
	# Existing P-001 aimed and P-002 fan behavior is preserved.
	if p.learned=="fan": return [forward.rotated(-.15)*390,forward*390,forward.rotated(.15)*390]
	if p.learned=="petal": return [forward.rotated(-.28)*350,forward.rotated(-.12)*380,forward*400,forward.rotated(.12)*380,forward.rotated(.28)*350]
	if p.learned=="seed": return [forward.rotated(-.22)*320,forward*390,forward.rotated(.22)*320]
	if p.learned=="halo": return [forward.rotated(-.45)*260,forward.rotated(-.2)*310,forward*360,forward.rotated(.2)*310,forward.rotated(.45)*260]
	if p.learned=="beam": return [forward*520]
	if p.learned=="pierce": return [forward*450] # Speed only; piercing requires projectile hit handling.
	var nearest=null
	var distance=10000.0
	for e in targets:
		var delta=e.pos-p.pos
		if e.hp>0 and delta.dot(forward)>0 and delta.length()<distance:
			distance=delta.length(); nearest=e
	return [(nearest.pos-p.pos).normalized()*390] if nearest!=null else [forward*390]

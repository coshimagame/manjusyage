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
	p.stability=0 # Cormii-only stabilization cores, stage-local (0..3)
	p.last_power_grade="normal"

static func level(p):
	return mini(3,int(p.experience/8))

# Cormii's power is rolled once PER shot volley, not time-cycled.
# Each core narrows low/high extremes but never removes the jackpot.
# All numbers are playtest prototypes; future network simulation should
# share/serialize the deterministic RNG seed, not call this on each client.
static func chance_profile(p, roll: float) -> Dictionary:
	var level_stability=clampi(int(p.get("stability",0)),0,3)
	var low_chance=[.25,.13,.06,.02][level_stability]
	var normal_end=[.80,.79,.80,.80][level_stability]
	var low_power=[.45,.75,.95,1.10][level_stability]
	var standard_power=[1.00,1.08,1.20,1.30][level_stability]
	var jackpot_power=[3.00,2.65,2.25,2.00][level_stability]
	if roll<low_chance: return {"power":low_power,"grade":"low"}
	if roll<normal_end: return {"power":standard_power,"grade":"normal"}
	return {"power":jackpot_power,"grade":"jackpot"}

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
		var stable=clampi(int(p.get("stability",0)),0,3)
		return "確率安定 "+str(stable)+"/3" if stable>0 else "確率変動"
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
	if p.learned=="fan": return [forward.rotated(-.15)*390,forward*390,forward.rotated(.15)*390]
	var nearest=null
	var distance=10000.0
	for e in targets:
		var delta=e.pos-p.pos
		if e.hp>0 and delta.dot(forward)>0 and delta.length()<distance:
			distance=delta.length(); nearest=e
	return [(nearest.pos-p.pos).normalized()*390] if nearest!=null else [forward*390]

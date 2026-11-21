extends RefCounted
# STAGE-001 (light, 2026-11-20 user request): data-driven stage parameters so
# all 8 stages are playable end to end. Stage 1 values reproduce the original
# hand-tuned run exactly (length 4800, gates at 1400/3000, wave gap 2.5,
# boss HP x1.0). Later stages vary length, wave pace, enemy speed/HP, a
# signature technique, vertical-section presence, boss HP/armour and fan size.
# Names live in briefing_progress.NAMES; this file is balance only, not canon.
const DEFS = {
	1: {"length": 4800.0, "wave_gap": 2.5, "speed_mul": 1.0, "hp_bonus": 0, "boss_hp_mul": 1.0, "fan_bonus": 0, "armor_bonus": 0, "signature": "", "vertical": true},
	2: {"length": 4400.0, "wave_gap": 2.3, "speed_mul": 1.05, "hp_bonus": 0, "boss_hp_mul": 1.1, "fan_bonus": 0, "armor_bonus": 2, "signature": "weave", "vertical": false},
	3: {"length": 5000.0, "wave_gap": 2.4, "speed_mul": 1.0, "hp_bonus": 1, "boss_hp_mul": 1.2, "fan_bonus": 0, "armor_bonus": 4, "signature": "orbit", "vertical": true},
	4: {"length": 4600.0, "wave_gap": 2.1, "speed_mul": 1.12, "hp_bonus": 1, "boss_hp_mul": 1.3, "fan_bonus": 1, "armor_bonus": 6, "signature": "dive", "vertical": false},
	5: {"length": 5200.0, "wave_gap": 2.2, "speed_mul": 1.08, "hp_bonus": 1, "boss_hp_mul": 1.45, "fan_bonus": 1, "armor_bonus": 8, "signature": "fan", "vertical": true},
	6: {"length": 4800.0, "wave_gap": 2.0, "speed_mul": 1.18, "hp_bonus": 2, "boss_hp_mul": 1.6, "fan_bonus": 1, "armor_bonus": 10, "signature": "weave", "vertical": false},
	7: {"length": 5200.0, "wave_gap": 1.9, "speed_mul": 1.15, "hp_bonus": 2, "boss_hp_mul": 1.6, "fan_bonus": 2, "armor_bonus": 10, "signature": "orbit", "vertical": true},
	8: {"length": 5200.0, "wave_gap": 1.8, "speed_mul": 1.25, "hp_bonus": 2, "boss_hp_mul": 1.7, "fan_bonus": 2, "armor_bonus": 10, "signature": "dive", "vertical": true}
}

static func def_for(stage: int) -> Dictionary:
	return DEFS[clampi(stage, 1, 8)]

# Scroll-pace profiles (anti-monotony): [progress, speed multiplier] points,
# linearly interpolated. The stage breathes - calm drift, a rush, a lull,
# then a final push - instead of one constant scroll speed. Profiles are
# tuned to average ~1.0 so overall clear times stay close to the old runs.
const DEFAULT_PACE = [[0.0, 1.0], [0.3, 0.72], [0.5, 1.32], [0.72, 0.92], [0.88, 1.22], [1.0, 1.05]]
const PACE_OVERRIDES = {
	3: [[0.0, 0.9], [0.35, 0.66], [0.6, 1.18], [0.8, 0.85], [1.0, 1.1]],
	5: [[0.0, 1.05], [0.25, 0.8], [0.45, 1.45], [0.65, 0.95], [0.85, 1.35], [1.0, 1.1]]
}

static func pace_at(stage: int, progress: float) -> float:
	var pts = PACE_OVERRIDES.get(clampi(stage, 1, 8), DEFAULT_PACE)
	var t = clampf(progress, 0.0, 1.0)
	for i in range(pts.size() - 1):
		var a = pts[i]
		var b = pts[i + 1]
		if t <= float(b[0]):
			var span = maxf(0.0001, float(b[0]) - float(a[0]))
			return lerpf(float(a[1]), float(b[1]), (t - float(a[0])) / span)
	return float(pts[pts.size() - 1][1])

extends RefCounted
## Five-step weapon progression rules. No character art or save files are modified.
## This is an isolated gameplay component; integration with game.gd is pending.
const MIN_LEVEL := 1
const MAX_LEVEL := 5

static func new_loadout() -> Dictionary:
	return {"normal": MIN_LEVEL, "mu_special": MIN_LEVEL, "mu_unlocked": false}

static func gain_level(loadout: Dictionary, kind: String) -> Dictionary:
	var result := loadout.duplicate(true)
	if kind != "normal" and kind != "mu_special":
		return result
	if kind == "mu_special" and not bool(result.get("mu_unlocked", false)):
		return result
	result[kind] = mini(MAX_LEVEL, maxi(MIN_LEVEL, int(result.get(kind, MIN_LEVEL))) + 1)
	return result

static func unlock_mu(loadout: Dictionary) -> Dictionary:
	var result := loadout.duplicate(true)
	result["mu_unlocked"] = true
	result["mu_special"] = maxi(MIN_LEVEL, int(result.get("mu_special", MIN_LEVEL)))
	return result

static func on_ship_lost(loadout: Dictionary, difficulty: int) -> Dictionary:
	var result := loadout.duplicate(true)
	# Provisional mapping: easiest -1, normal -2, hardest resets to Lv1.
	var loss := clampi(difficulty, 1, 5)
	for kind in ["normal", "mu_special"]:
		result[kind] = maxi(MIN_LEVEL, int(result.get(kind, MIN_LEVEL)) - loss)
	# Ownership survives loss of one ship.
	return result

static func fusion_ready(loadout: Dictionary) -> bool:
	return bool(loadout.get("mu_unlocked", false)) and int(loadout.get("normal", 1)) >= MAX_LEVEL and int(loadout.get("mu_special", 1)) >= MAX_LEVEL

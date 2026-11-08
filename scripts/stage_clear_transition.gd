extends RefCounted
class_name StageClearTransition

# Reusable, side-effect-free contract between real stage-clear and intermission.
# Provisional implementation; does not change canon, saves or approved art.
const LAST_STAGE := 8
const PILOT_IDS := ["cormii", "jiyoza", "mafio"]

static func make_payload(stage_number: int, selected_pilots: Array, score: int, worldline: int = 1) -> Dictionary:
	if stage_number < 1 or stage_number > LAST_STAGE:
		return {}
	if selected_pilots.is_empty() or selected_pilots.size() > 3:
		return {}
	var unique_pilots: Array[String] = []
	for pilot in selected_pilots:
		var id := str(pilot)
		if not PILOT_IDS.has(id) or unique_pilots.has(id):
			return {}
		unique_pilots.append(id)
	if worldline < 1:
		return {}
	return {
		"version": 1,
		"cleared_stage": stage_number,
		"next_stage": stage_number + 1 if stage_number < LAST_STAGE else 0,
		"destination": "intermission" if stage_number < LAST_STAGE else "ending",
		"pilots": unique_pilots,
		"score": maxi(0, score),
		"worldline": worldline,
	}

static func is_valid(payload: Dictionary) -> bool:
	if int(payload.get("version", 0)) != 1:
		return false
	var stage := int(payload.get("cleared_stage", 0))
	var pilots = payload.get("pilots", [])
	if not pilots is Array:
		return false
	var expected := make_payload(stage, pilots, int(payload.get("score", -1)), int(payload.get("worldline", 0)))
	return not expected.is_empty() and int(payload.get("next_stage", -1)) == int(expected.next_stage) and str(payload.get("destination", "")) == str(expected.destination) and int(payload.get("score", -1)) >= 0

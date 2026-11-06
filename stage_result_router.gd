extends RefCounted
## Pure transition decisions for the stage-result screen.
## Does not alter saves or enter unimplemented stages by itself.
const FINAL_STAGE := 8

static func available_actions(stage: int, next_stage_implemented: bool) -> Array[String]:
	var actions: Array[String] = ["retry", "save", "title"]
	if stage < 1 or stage > FINAL_STAGE:
		return []
	if stage == FINAL_STAGE:
		actions.insert(0, "ending")
	elif next_stage_implemented:
		actions.insert(0, "next")
	else:
		actions.insert(0, "briefing")
	return actions

static func destination(stage: int, action: String, next_stage_implemented: bool) -> Dictionary:
	var actions := available_actions(stage, next_stage_implemented)
	if not actions.has(action):
		return {}
	match action:
		"retry":
			return {"kind": "stage", "stage": stage}
		"next":
			return {"kind": "stage", "stage": stage + 1}
		"briefing":
			return {"kind": "briefing", "stage": stage + 1, "playable": false}
		"ending":
			return {"kind": "ending", "stage": FINAL_STAGE}
		"save":
			return {"kind": "save", "stage": stage}
		"title":
			return {"kind": "title"}
	return {}

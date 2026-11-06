extends RefCounted
## Stage-clear -> intermission -> next sortie state bridge.
## Does not replace existing result or dialogue UI; the caller owns scene changes.
## This helper is intentionally independent of draft PR #49/#53/#54.
const FIRST_STAGE := 1
const LAST_STAGE := 8
const MAX_PLAYERS := 3

static func next_stage(stage: int) -> int:
	if stage < FIRST_STAGE or stage >= LAST_STAGE:
		return -1
	return stage + 1

static func make_pending(stage: int, worldline: int, player_count: int) -> Dictionary:
	if stage < FIRST_STAGE or stage >= LAST_STAGE:
		return {}
	if worldline < 1 or player_count < 1 or player_count > MAX_PLAYERS:
		return {}
	return {
		"version": 1,
		"completed_stage": stage,
		"next_stage": stage + 1,
		"worldline": worldline,
		"player_count": player_count,
		"event_key": "intermission_%02d_loop_%02d" % [stage, worldline],
		"seen": false
	}

static func valid_pending(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var data: Dictionary = value
	for key in ["version", "completed_stage", "next_stage", "worldline", "player_count", "event_key", "seen"]:
		if not data.has(key):
			return false
	if typeof(data["version"]) != TYPE_INT or data["version"] != 1:
		return false
	for key in ["completed_stage", "next_stage", "worldline", "player_count"]:
		if typeof(data[key]) != TYPE_INT:
			return false
	if typeof(data["event_key"]) != TYPE_STRING or typeof(data["seen"]) != TYPE_BOOL:
		return false
	var expected := make_pending(data["completed_stage"], data["worldline"], data["player_count"])
	return not expected.is_empty() and data["next_stage"] == expected["next_stage"] and data["event_key"] == expected["event_key"]

static func mark_seen(value: Variant) -> Dictionary:
	if not valid_pending(value):
		return {}
	var result: Dictionary = value.duplicate(true)
	result["seen"] = true
	return result

static func sortie_stage(value: Variant) -> int:
	if not valid_pending(value) or not value["seen"]:
		return -1
	return value["next_stage"]

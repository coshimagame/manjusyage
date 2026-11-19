extends RefCounted
## Read-only, defensive loader for the stage_progress.cfg checkpoint.
## Does not alter the existing score, control, or audio save files.

const SAVE_PATH := "user://stage_progress.cfg"
const MAX_STAGE := 8
const MAX_PLAYERS := 3

static func read_checkpoint(path: String = SAVE_PATH) -> Dictionary:
	var defaults := {
		"unlocked_stage": 1,
		"last_cleared_stage": 0,
		"party_size": 1,
		"pilot_ids": [0],
		"has_save": false
	}
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return defaults
	var unlocked := clampi(int(config.get_value("progress", "unlocked_stage", 1)), 1, MAX_STAGE)
	var cleared := clampi(int(config.get_value("progress", "last_cleared_stage", 0)), 0, unlocked - 1)
	var party_size := clampi(int(config.get_value("progress", "party_size", 1)), 1, MAX_PLAYERS)
	var raw_ids: Variant = config.get_value("progress", "pilot_ids", [0])
	var ids: Array[int] = []
	if raw_ids is Array:
		for raw_id in raw_ids:
			if not (raw_id is int or raw_id is float):
				continue
			var pilot_id := int(raw_id)
			if pilot_id >= 0 and pilot_id < MAX_PLAYERS and not ids.has(pilot_id):
				ids.append(pilot_id)
			if ids.size() >= party_size:
				break
	if ids.is_empty():
		ids.append(0)
	defaults["unlocked_stage"] = unlocked
	defaults["last_cleared_stage"] = cleared
	defaults["party_size"] = mini(party_size, ids.size())
	defaults["pilot_ids"] = ids
	defaults["has_save"] = true
	return defaults

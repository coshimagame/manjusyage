extends RefCounted
## Stage transition helper for MANJUSHAGE (prototype, not yet connected to game.gd).
## Stores only stage progression, never overwrites the existing score save.
const SAVE_PATH := "user://stage_progress.cfg"
const PILOTS := ["コルミィ", "ジヨーザ", "マフィオ"]

static func normalize_pilots(raw: Array) -> Array[String]:
	var result: Array[String] = []
	for pilot in raw:
		var name := str(pilot)
		if name in PILOTS and not name in result and result.size() < 3:
			result.append(name)
	if result.is_empty():
		result.append(PILOTS[0])
	return result

static func read_checkpoint() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return {"next_stage": 1, "cleared_stage": 0, "pilots": [PILOTS[0]]}
	var cleared := clampi(int(cfg.get_value("progress", "cleared_stage", 0)), 0, 8)
	var next_stage := clampi(int(cfg.get_value("progress", "next_stage", cleared + 1)), 1, 8)
	var saved_pilots = cfg.get_value("progress", "pilots", [PILOTS[0]])
	if not saved_pilots is Array:
		saved_pilots = [PILOTS[0]]
	return {"next_stage": next_stage, "cleared_stage": cleared, "pilots": normalize_pilots(saved_pilots)}

static func record_clear(stage: int, pilots: Array) -> Error:
	if stage < 1 or stage > 8:
		return ERR_INVALID_PARAMETER
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	var previous := clampi(int(cfg.get_value("progress", "cleared_stage", 0)), 0, 8)
	var cleared := maxi(previous, stage)
	cfg.set_value("progress", "cleared_stage", cleared)
	cfg.set_value("progress", "next_stage", mini(cleared + 1, 8))
	cfg.set_value("progress", "pilots", normalize_pilots(pilots))
	return cfg.save(SAVE_PATH)

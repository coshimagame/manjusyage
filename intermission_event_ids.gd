extends RefCounted
class_name ManjushageIntermissionEvents

# Provisional dialogue only. Event IDs and save-safe routing; no canon promotion.
const EVENT_PREFIX := "intermission.stage."
const MAX_STAGE := 8

static func event_id(stage_number: int, loop_number: int = 1) -> String:
	if stage_number < 1 or stage_number >= MAX_STAGE or loop_number < 1:
		return ""
	return "%s%02d.loop.%02d" % [EVENT_PREFIX, stage_number, loop_number]

static func is_valid_id(value: String) -> bool:
	if not value.begins_with(EVENT_PREFIX):
		return false
	var parts := value.trim_prefix(EVENT_PREFIX).split(".loop.")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return false
	var stage_number := int(parts[0])
	var loop_number := int(parts[1])
	return event_id(stage_number, loop_number) == value

static func next_stage(stage_number: int) -> int:
	if stage_number < 1 or stage_number >= MAX_STAGE:
		return -1
	return stage_number + 1

static func save_record(stage_number: int, loop_number: int = 1) -> Dictionary:
	var id := event_id(stage_number, loop_number)
	if id.is_empty():
		return {}
	return {"schema": 1, "event_id": id, "stage_cleared": stage_number, "loop": loop_number}

static func can_resume(record: Dictionary) -> bool:
	if int(record.get("schema", 0)) != 1:
		return false
	var stage_number := int(record.get("stage_cleared", 0))
	var loop_number := int(record.get("loop", 0))
	return is_valid_id(str(record.get("event_id", ""))) and event_id(stage_number, loop_number) == str(record.get("event_id", ""))

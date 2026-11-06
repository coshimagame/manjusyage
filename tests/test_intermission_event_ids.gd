extends SceneTree
# Headless: godot --headless --path . --script res://tests/test_intermission_event_ids.gd
const Events = preload("res://intermission_event_ids.gd")
var failures := 0

func _initialize() -> void:
	for stage in range(1, 8):
		for loop_number in [1, 2, 4, 10]:
			var id := Events.event_id(stage, loop_number)
			_check(id == "intermission.stage.%02d.loop.%02d" % [stage, loop_number], "stable event ID")
			_check(Events.is_valid_id(id), "round-trip ID")
			_check(Events.next_stage(stage) == stage + 1, "next stage")
			var record := Events.save_record(stage, loop_number)
			_check(Events.can_resume(record), "valid save record")
			record["loop"] = loop_number + 1
			_check(not Events.can_resume(record), "tampered save record")
	for invalid_stage in [-1, 0, 8, 9]:
		_check(Events.event_id(invalid_stage, 1).is_empty(), "invalid stage")
		_check(Events.save_record(invalid_stage).is_empty(), "invalid save")
		_check(Events.next_stage(invalid_stage) == -1, "invalid next stage")
	for invalid_id in ["", "intermission.stage.01.loop.00", "intermission.stage.08.loop.01", "intermission.stage.1.loop.01", "intermission.stage.01.loop.1", "intermission.stage.01.loop.01.extra", "intermission.stage.01.loop.-1"]:
		_check(not Events.is_valid_id(invalid_id), "reject invalid ID: " + invalid_id)
	_check(not Events.can_resume({}), "empty save")
	_check(not Events.can_resume({"schema": 2, "event_id": Events.event_id(1), "stage_cleared": 1, "loop": 1}), "future schema rejected")
	print("Intermission event tests: ", "PASS" if failures == 0 else "%d FAILURES" % failures)
	quit(0 if failures == 0 else 1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

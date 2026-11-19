extends SceneTree
## Run with: godot --headless --path . --script res://tests/test_stage_checkpoint_reader.gd
## Uses a temporary user:// file; never overwrites the player's stage_progress.cfg.

const Reader = preload("res://stage_checkpoint_reader.gd")
const TEST_PATH := "user://stage_checkpoint_reader_test.cfg"

func _initialize() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_stage", 99)
	cfg.set_value("progress", "last_cleared_stage", 99)
	cfg.set_value("progress", "party_size", 3)
	cfg.set_value("progress", "pilot_ids", [2, 2, 1, 0])
	if cfg.save(TEST_PATH) != OK:
		push_error("Unable to create checkpoint fixture")
		quit(1)
		return
	var data := Reader.read_checkpoint(TEST_PATH)
	var ok := data["has_save"] == true
	ok = ok and data["unlocked_stage"] == 8
	ok = ok and data["last_cleared_stage"] == 7
	ok = ok and data["party_size"] == 3
	ok = ok and data["pilot_ids"] == [2, 1, 0]
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var missing := Reader.read_checkpoint(TEST_PATH)
	ok = ok and missing["has_save"] == false
	ok = ok and missing["unlocked_stage"] == 1
	ok = ok and missing["pilot_ids"] == [0]
	if ok:
		print("CHECKPOINT READER TEST PASS")
		quit(0)
	else:
		push_error("CHECKPOINT READER TEST FAIL")
		quit(1)

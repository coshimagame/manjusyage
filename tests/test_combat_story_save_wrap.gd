extends SceneTree
## Regression: stage-8 wrap, preview save persistence and no duplicate intermission.
## Run with an isolated --user-data-dir/profile; production saves are untouched.
const BRIDGE = preload("res://scenes/combat_story_bridge.tscn")
const SAVE_PATH := "user://combat_story_preview.cfg"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var had_save := FileAccess.file_exists(SAVE_PATH)
	var original := PackedByteArray()
	if had_save:
		original = FileAccess.get_file_as_bytes(SAVE_PATH)
	var errors: Array[String] = []
	var bridge = BRIDGE.instantiate()
	root.add_child(bridge)
	await process_frame
	if not is_instance_valid(bridge.combat):
		errors.append("Combat did not instantiate")
	else:
		bridge.combat._set_stage(8)
		bridge.combat.stage_clear = true
		await process_frame
		if not bridge.awaiting_intermission or not is_instance_valid(bridge.overlay):
			errors.append("Stage 8 did not open the intermission")
		else:
			bridge.overlay.finished.emit()
			await process_frame
			if bridge.combat.stage != 1:
				errors.append("Stage 8 did not wrap to stage 1")
			var cfg := ConfigFile.new()
			if cfg.load(SAVE_PATH) != OK or int(cfg.get_value("progress", "stage", -1)) != 1:
				errors.append("Wrapped stage was not persisted")
			await process_frame
			if bridge.awaiting_intermission:
				errors.append("Intermission reopened after stage reset")
	bridge.queue_free()
	await process_frame
	# Verify saved stage loads on a fresh bridge instance.
	if errors.is_empty():
		var resumed = BRIDGE.instantiate()
		root.add_child(resumed)
		await process_frame
		if not is_instance_valid(resumed.combat) or resumed.combat.stage != 1:
			errors.append("Saved stage was not restored")
		resumed.queue_free()
		await process_frame
	# Always restore the exact preview save bytes, including on test failure.
	if had_save:
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f == null:
			errors.append("Failed to restore original preview save")
		else:
			f.store_buffer(original)
			f.close()
	else:
		if FileAccess.file_exists(SAVE_PATH):
			var err := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
			if err != OK:
				errors.append("Failed to remove temporary preview save")
	if errors.is_empty():
		print("PASS: stage-8 wrap, save persistence, clean reset")
		quit(0)
	else:
		for e in errors:
			push_error(e)
		quit(1)

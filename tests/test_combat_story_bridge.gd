extends SceneTree
## Run: godot --headless --path . --script res://tests/test_combat_story_bridge.gd
## Isolated preview save only; never touches production progress.
const BRIDGE = preload("res://scenes/combat_story_bridge.tscn")
const SAVE_PATH := "user://combat_story_preview.cfg"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var previous := FileAccess.file_exists(SAVE_PATH)
	var backup := PackedByteArray()
	if previous:
		backup = FileAccess.get_file_as_bytes(SAVE_PATH)
	var bridge := BRIDGE.instantiate()
	root.add_child(bridge)
	await process_frame
	var failures: Array[String] = []
	if bridge.combat == null:
		failures.append("Combat scene did not instantiate")
	else:
		bridge.combat._set_stage(1)
		bridge.combat.stage_clear = true
		await process_frame
		if not bridge.awaiting_intermission:
			failures.append("Stage clear did not start intermission")
		if bridge.combat.process_mode != Node.PROCESS_MODE_DISABLED:
			failures.append("Combat was not paused during intermission")
		if not is_instance_valid(bridge.overlay):
			failures.append("Intermission overlay missing")
		else:
			bridge.overlay.finished.emit()
			await process_frame
			if bridge.awaiting_intermission:
				failures.append("Intermission did not finish")
			if bridge.combat.stage != 2:
				failures.append("Next stage was not selected")
			if bridge.combat.process_mode != Node.PROCESS_MODE_INHERIT:
				failures.append("Combat did not resume")
	bridge.queue_free()
	await process_frame
	# Restore the exact pre-test preview save, if any.
	if previous:
		var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if file == null:
			failures.append("Could not restore preview save")
		else:
			file.store_buffer(backup)
			file.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if failures.is_empty():
		print("PASS: combat -> intermission -> next stage")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

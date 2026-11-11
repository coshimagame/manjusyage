extends SceneTree
## Stage 2 wave regression; run with Godot 4.6:
## godot --headless --path . --script res://tests/test_stage2_wave_regression.gd
## Does not touch player saves. Standalone prototype only.
const STAGE := preload("res://scenes/stage2_combat_prototype.tscn")
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func _run() -> void:
	var stage := STAGE.instantiate()
	root.add_child(stage)
	await process_frame
	stage.spawn_timer = 100.0
	stage.enemies.clear()
	stage.shots.clear()
	stage.enemies.append({"pos": Vector2(210, 180), "hp": 2})
	stage.shots.append(Vector2(210, 180))
	stage._process(0.0)
	_check(stage.enemies.size() == 1, "two-HP enemy survives first shot")
	if stage.enemies.size() == 1:
		_check(int(stage.enemies[0]["hp"]) == 1, "first shot persists one remaining HP")
	_check(stage.wave_kills == 0, "first shot does not increment kill counter")
	stage.shots.append(Vector2(210, 180))
	stage._process(0.0)
	_check(stage.enemies.is_empty(), "second shot removes enemy")
	_check(stage.wave_kills == 1, "kill counter increments once")
	stage.queue_free()
	await process_frame

	stage = STAGE.instantiate()
	root.add_child(stage)
	await process_frame
	stage.spawn_timer = 100.0
	stage.enemies.clear()
	stage.shots.clear()
	stage.pilot = Vector2(210, 180)
	stage.enemies.append({"pos": Vector2(210, 180), "hp": 1})
	stage.shots.append(Vector2(210, 180))
	stage._process(0.0)
	_check(stage.hp == 4, "defeated overlapping enemy does not damage pilot")
	_check(stage.enemies.is_empty(), "overlapping defeated enemy removed")
	stage.queue_free()
	await process_frame

	stage = STAGE.instantiate()
	root.add_child(stage)
	await process_frame
	stage.spawn_timer = 100.0
	stage.enemies.clear()
	stage.wave_kills = 14
	stage.enemies.append({"pos": Vector2(210, 180), "hp": 1})
	stage.shots.append(Vector2(210, 180))
	stage._process(0.0)
	_check(stage.phase == "boss", "15th kill enters boss phase")
	_check(stage.boss_warning > 0.0, "boss warning starts on transition")
	_check(stage.enemies.is_empty(), "wave enemies cleared on boss transition")
	stage.queue_free()
	print("Stage-2 wave regression: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)

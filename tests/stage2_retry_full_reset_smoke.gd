extends SceneTree
# Run: godot --headless --path . --script res://tests/stage2_retry_full_reset_smoke.gd
# No user save data is read or written.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed = load("res://prototypes/stage2_playable.tscn")
	if packed == null:
		push_error("Stage 2 scene missing")
		quit(1)
		return
	var stage = packed.instantiate()
	root.add_child(stage)
	await process_frame
	stage.state = "gameover"
	stage.ship = Vector2(200, 250)
	stage.enemy_pos = Vector2(535, 270)
	stage.enemy_phase = 2.0
	stage.elapsed = 45.0
	stage.hp = 0
	stage.hit_grace = 0.8
	stage.touch_id = 3
	stage.touch_move = Vector2(240, 300)
	stage.fire_touch_id = 4
	stage.touch_fire = true
	stage.shots = [Vector2(100, 100)]
	stage.hostile = [Vector2(200, 200)]
	stage._restart()
	var errors: Array[String] = []
	if stage.state != "playing" or stage.hp != 5 or stage.hit_grace != 0.0:
		errors.append("Retry must reset gameplay state")
	if stage.enemy_pos != Vector2(535, 180) or stage.enemy_phase != 0.0 or stage.elapsed != 0.0:
		errors.append("Retry must reset boss position and elapsed time")
	if stage.touch_id != -1 or stage.fire_touch_id != -1 or stage.touch_move != Vector2.ZERO or stage.touch_fire:
		errors.append("Retry must clear touch state")
	if not stage.shots.is_empty() or not stage.hostile.is_empty():
		errors.append("Retry must clear projectiles")
	stage.queue_free()
	if errors.is_empty():
		print("PASS: stage 2 retry resets battle and touch state")
		quit(0)
	else:
		for issue in errors:
			push_error(issue)
		quit(1)

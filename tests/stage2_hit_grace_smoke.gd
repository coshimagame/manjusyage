extends SceneTree
# Headless scene-level regression. Never writes user:// saves.
# godot --headless --path . --script res://tests/stage2_hit_grace_smoke.gd

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
	stage.ship = Vector2(90, 180)
	stage.hostile = [Vector2(90, 180), Vector2(90, 180)]
	stage.enemy_cooldown = 999.0
	stage.hp = 5
	stage._process(0.016)
	var errors: Array[String] = []
	if stage.hp != 4:
		errors.append("Overlapping bullets must cause only one hit")
	if stage.hit_grace <= 0.0:
		errors.append("Hit grace must start after collision")
	stage.hostile = [stage.ship]
	stage._process(0.016)
	if stage.hp != 4:
		errors.append("Hit during grace must not drain HP")
	stage.state = "gameover"
	stage._restart()
	if stage.hit_grace != 0.0 or stage.hp != 5 or stage.state != "playing":
		errors.append("Retry must reset grace, HP and state")
	stage.queue_free()
	if errors.is_empty():
		print("PASS: Stage 2 hit grace and retry reset")
		quit(0)
	else:
		for error in errors:
			push_error(error)
		quit(1)

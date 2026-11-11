extends SceneTree
## Headless regression smoke test for the standalone stage-2 prototype.
## Run: godot --headless --path . --script res://tests/test_stage2_combat_smoke.gd
## No player save is read or written. Requires Godot 4.6.
const STAGE := preload("res://scenes/stage2_combat_prototype.tscn")
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, description: String) -> void:
	if not ok:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func _run() -> void:
	var stage := STAGE.instantiate()
	root.add_child(stage)
	await process_frame
	_check(stage.phase == "wave" and stage.hp == 4, "initial wave and HP")
	stage.invulnerable = 0.0
	stage._hit()
	_check(stage.hp == 3 and stage.invulnerable > 0.0, "hit removes one HP and starts invulnerability")
	stage._hit()
	_check(stage.hp == 3, "invulnerability prevents repeat damage")
	stage.hp = 1
	stage.invulnerable = 0.0
	stage._hit()
	_check(stage.phase == "lost" and stage.hp == 0, "fatal hit ends game")
	stage.invulnerable = 0.0
	stage._hit()
	_check(stage.hp == 0 and stage.phase == "lost", "terminal loss cannot receive extra damage")
	stage.queue_free()
	await process_frame

	stage = STAGE.instantiate()
	root.add_child(stage)
	await process_frame
	stage.phase = "boss"
	stage.boss_hp = 1
	stage.shots.append(Vector2(530, 180))
	stage._process(0.0)
	_check(stage.phase == "won", "boss hit transitions to victory")
	_check(stage.shots.is_empty() and stage.enemy_shots.is_empty(), "victory clears projectiles")
	stage.hp = 2
	stage.invulnerable = 0.0
	stage._hit()
	_check(stage.hp == 2 and stage.phase == "won", "terminal victory ignores damage")
	stage.queue_free()
	print("Stage-2 regression: %d failure(s)" % failures)
	quit(1 if failures > 0 else 0)

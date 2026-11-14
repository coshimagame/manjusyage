extends SceneTree
## Run: godot --headless --path . --script res://tests/stage2_terminal_smoke.gd
## Isolated state-machine regression; not a substitute for human play testing.
const SCENE = preload("res://prototypes/stage2_playable.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var stage = SCENE.instantiate()
	root.add_child(stage)
	await process_frame
	var clears := [0]
	var retries := [0]
	stage.stage_cleared.connect(func(): clears[0] += 1)
	stage.retry_requested.connect(func(): retries[0] += 1)
	# A fatal shot must end combat once and must not process hostile collisions.
	stage.enemy_hp = 1
	stage.shots.append(stage.enemy_pos)
	stage.hostile.append(stage.ship)
	stage._process(0.016)
	if stage.state != "clear" or clears[0] != 1 or stage.hp != 5:
		_fail("clear must emit once and stop hostile damage")
		return
	stage._process(0.016)
	if clears[0] != 1:
		_fail("clear signal emitted more than once")
		return
	# Retry restores all mutable combat state.
	stage._restart()
	if stage.state != "playing" or stage.enemy_hp != 30 or stage.hp != 5 or retries[0] != 1:
		_fail("retry did not restore combat state")
		return
	if not stage.shots.is_empty() or not stage.hostile.is_empty() or stage.invulnerability != 0.0:
		_fail("retry left projectile or invulnerability state")
		return
	# Multiple overlapping bullets must consume only one HP during invulnerability.
	stage.hostile.append(stage.ship)
	stage.hostile.append(stage.ship)
	stage._process(0.016)
	if stage.hp != 4 or stage.invulnerability <= 0.0:
		_fail("overlapping hostile bullets bypassed invulnerability")
		return
	stage._restart()
	stage.hp = 1
	stage.hostile.append(stage.ship)
	stage._process(0.016)
	if stage.state != "gameover" or stage.hp != 0:
		_fail("fatal hit did not end the stage")
		return
	print("PASS stage2_terminal_smoke")
	stage.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL stage2_terminal_smoke: " + message)
	quit(1)

extends SceneTree
## Godot 4.6 headless smoke test for the actual Stage 2 scene.
## Run: godot --headless --path . --script res://tests/stage2_scene_lifecycle_smoke.gd
## Does not touch user:// saves, approved art, or existing audio.

const STAGE_SCENE := preload("res://prototypes/stage2_playable.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var stage := STAGE_SCENE.instantiate()
	root.add_child(stage)
	await process_frame
	if not _check(stage.state == "playing", "initial playing state"):
		return
	if not _check(stage.hp > 0 and stage.enemy_hp > 0, "initial HP"):
		return
	var clear_count := [0]
	stage.stage_cleared.connect(func(): clear_count[0] += 1)
	stage.enemy_hp = 1
	stage.shots.clear()
	stage.shots.append(stage.enemy_pos)
	await process_frame
	if not _check(stage.state == "clear", "boss defeat enters clear state"):
		return
	if not _check(clear_count[0] == 1, "clear signal emitted once"):
		return
	await process_frame
	if not _check(clear_count[0] == 1, "clear signal not repeated"):
		return
	stage._restart()
	if not _check(stage.state == "playing" and stage.hp > 0 and stage.enemy_hp > 0, "restart resets combat"):
		return
	if not _check(stage.shots.is_empty() and stage.hostile.is_empty(), "restart clears projectiles"):
		return
	stage.hp = 1
	stage.hostile.append(stage.ship)
	await process_frame
	if not _check(stage.state == "gameover", "fatal collision enters gameover"):
		return
	stage.queue_free()
	print("PASS stage2_scene_lifecycle_smoke")
	quit(0)

func _check(ok: bool, description: String) -> bool:
	if ok:
		print("PASS ", description)
		return true
	push_error("FAIL " + description)
	quit(1)
	return false

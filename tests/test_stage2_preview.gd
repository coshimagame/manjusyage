extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var preview = load("res://prototypes/stage2_playable.tscn").instantiate()
	root.add_child(preview)
	preview.set_process(false)
	assert(preview.BOSS_ART is Texture2D)
	assert(Rect2(Vector2.ZERO,preview.BOSS_ART.get_size()).encloses(preview.BOSS_REGION))
	preview.hostile.append(preview.ship)
	preview.hostile.append(preview.ship)
	preview._process(.01)
	assert(preview.hp==4 and preview.hit_grace>0)
	preview.enemy_hp=1
	preview.shots.append(preview.enemy_pos)
	preview._process(.01)
	assert(preview.state=="clear")
	preview._restart()
	assert(preview.state=="playing" and preview.enemy_hp==30 and preview.hp==5)
	assert(preview.hit_grace==0 and preview.shots.is_empty() and preview.hostile.is_empty())
	preview.queue_free()
	await process_frame
	print("STAGE 2 PREVIEW PASS: BB02 crop, overlapping hit protection, boss clear and retry")
	quit()

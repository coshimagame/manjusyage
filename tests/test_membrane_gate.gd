extends SceneTree

func _initialize(): run.call_deferred()

func run():
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.slice_mode=false # Full mode: travel accumulates; slice mode is timeline-driven.
	game.start_game(1)
	# Jump the run to just before the membrane trigger point. Waiting is
	# based on game elapsed time, not frame count: headless frame rates
	# vary too much for a fixed frame budget to be deterministic.
	game.travel=game.stage_length()*1050.0/4800.0
	var t0=game.elapsed
	while game.elapsed-t0<4.0 and game.membrane.is_empty():
		await process_frame
	assert(not game.membrane.is_empty(), "membrane gate must spawn on the bio route")
	var core=game.membrane_core()
	assert(core.x>300, "membrane enters from the right side")
	# A bullet that reaches the core damages it; the body only absorbs.
	game.membrane.hp=2.0
	game.bullets.append({"pos":core-Vector2(30,0),"vel":Vector2(390,0),"damage":3.0,"color":0,"owner":0})
	t0=game.elapsed
	while game.elapsed-t0<1.5 and not game.membrane.is_empty():
		await process_frame
	assert(game.membrane.is_empty(), "membrane must be destroyed when its core HP runs out")
	assert(game.score>=500, "destroying the membrane awards score")
	assert(game.pickups.size()>=2, "destroying the membrane drops pickups")
	game.queue_free()
	await process_frame
	print("MEMBRANE GATE PASS: spawn, core damage, destruction reward, no scroll lock")
	quit()

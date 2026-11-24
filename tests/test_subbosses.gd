extends SceneTree
# Three-tier bosses: mini at ~35%, mid at ~70%, rewards and wave pause.

func _initialize(): run.call_deferred()

func run():
	var g = load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.slice_mode = false
	g.count = 1
	g.start_game(1)
	g.players[0].inv = 1000.0 # Combat outcomes are not what this test measures.
	g.gates_done = 2 # Isolate from the relay gates for this check.
	g.membrane_done = true
	# Mini-boss at 35%.
	g.travel = g.stage_length() * 0.36
	for i in range(20): g._process(0.05)
	assert(g.subboss_mini_done, "mini-boss flag must be set")
	var mini = null
	for e in g.enemies:
		if int(e.get("subboss", 0)) == 1: mini = e
	assert(mini != null, "mini-boss must be on the field")
	assert(g.subboss_active(), "subboss_active must see the mini-boss")
	assert(float(mini.hit_r) > 19.0, "mini-boss needs a boss-sized hitbox")
	# Waves pause while it lives: step time and count non-subboss spawns.
	var regular = 0
	for i in range(60): g._process(0.05)
	for e in g.enemies:
		if int(e.get("subboss", 0)) == 0: regular += 1
	assert(regular == 0, "no regular waves may spawn during a subboss")
	# Kill it: bonus score and guaranteed drops.
	var score0 = g.score
	var pickups0 = g.pickups.size()
	mini.hp = 0
	g._process(0.05)
	assert(g.score >= score0 + 500, "mini-boss kill must pay the bonus")
	assert(g.pickups.size() >= pickups0 + 2, "mini-boss must drop two pickups")
	assert(not g.subboss_active(), "mini-boss must be gone after the kill")
	# Mid-boss at 70% (past the vertical section, which owns 65%).
	g.vertical.done = true
	g.travel = g.stage_length() * 0.71
	for i in range(20): g._process(0.05)
	assert(g.subboss_mid_done, "mid-boss flag must be set")
	var mid = null
	for e in g.enemies:
		if int(e.get("subboss", 0)) == 2: mid = e
	assert(mid != null, "mid-boss must be on the field")
	assert(float(mid.max_hp) > float(mini.max_hp), "mid-boss must outlast the mini")
	# Growth: 13 seconds alive grows it once.
	for i in range(260): g._process(0.05)
	assert(int(mid.get("growth", 0)) >= 1, "mid-boss must grow while alive")
	var score1 = g.score
	mid.hp = 0
	g._process(0.05)
	assert(g.score >= score1 + 1500, "mid-boss kill must pay the bigger bonus")
	print("SUBBOSSES PASS: mini/mid spawn at route marks, waves pause, growth, rewards")
	quit()

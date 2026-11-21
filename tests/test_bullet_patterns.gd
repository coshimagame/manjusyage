extends SceneTree
# P02 silver needle line + P05 crimson ring expansion (VFX P0 patterns).
func _initialize(): run.call_deferred()

func run():
	var g = load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.slice_mode = false
	g.start_game(1)
	# --- P02: a dive enemy locks its aim and looses exactly 3 needles. ---
	g.enemies.clear()
	g.shots.clear()
	g.enemies.append({"pos": Vector2(500, 180), "base": 180.0, "age": 0.0, "phase": 0.0, "amplitude": 30.0, "speed": 30.0, "cool": 0.01, "hp": 5, "technique": "dive", "flash": 0.0})
	for i in range(10): g.update_game(0.05)
	var needles = g.shots.filter(func(s): return s.get("kind", "") == "needle")
	assert(needles.size() == 3, "P02 burst must fire exactly 3 needles, got " + str(needles.size()))
	for s in needles:
		assert(absf(s.vel.length() - 120.0) < 0.1, "P02 needles share the locked fast line")
		assert(s.vel == needles[0].vel, "P02 needles must share one locked direction")
	# --- P05: every 4th exposed-phase volley becomes 3 rings of 14. ---
	g.enemies.clear()
	g.shots.clear()
	g.begin_boss()
	g.bio.armor = [0, 0] # core exposed -> phase >= 2 (after begin_boss resets it)
	g.boss.hp = g.boss.max * 0.9 # phase 2, above the aimed-eye threshold
	g.boss.volleys = 3
	g.boss.cool = 0.0
	g.update_boss(0.016)
	assert(int(g.boss.get("rings", 0)) == 3, "P05 must schedule 3 rings")
	assert(g.shots.is_empty(), "P05 volley replaces the fan, no immediate shots")
	var steps = 0
	while int(g.boss.get("rings", 0)) > 0 and steps < 60:
		g.update_boss(0.1)
		steps += 1
	var rings = g.shots.filter(func(s): return s.get("kind", "") == "ring")
	assert(rings.size() == 42, "P05 must release 3 rings x 14 bullets, got " + str(rings.size()))
	for s in rings: assert(absf(s.vel.length() - 55.0) < 0.1)
	print("BULLET PATTERNS PASS: P02 locked 3-needle burst, P05 3x14 ring expansion")
	quit(0)

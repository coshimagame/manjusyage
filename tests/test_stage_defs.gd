extends SceneTree
# STAGE-001: all 8 stages defined, launchable, and parameterised.
# Run with Godot 4.6: godot --headless --path . --script tests/test_stage_defs.gd
const StageDefs = preload("res://stage_defs.gd")

func _initialize(): run.call_deferred()

func run():
	# Stage 1 must reproduce the original run exactly.
	var d1 = StageDefs.def_for(1)
	assert(float(d1["length"]) == 4800.0 and float(d1["wave_gap"]) == 2.5)
	assert(float(d1["boss_hp_mul"]) == 1.0 and int(d1["hp_bonus"]) == 0 and int(d1["armor_bonus"]) == 0)
	for s in range(1, 9):
		var d = StageDefs.def_for(s)
		assert(float(d["length"]) > 0 and float(d["wave_gap"]) > 0)
		assert(float(d["boss_hp_mul"]) >= 1.0)
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.briefing_progress.save_path = "user://test_stage_defs.cfg"
	game.briefing_progress.highest_unlocked = 8
	game.slice_mode = false # Full runs only: slice mode is the stage-1 short demo.
	game.count = 1
	for s in range(1, 9):
		assert(game.briefing_progress.can_launch(s))
		game.start_game(s)
		assert(game.mode == "play" and game.current_stage == s)
		assert(abs(game.stage_length() - float(StageDefs.def_for(s)["length"])) < 0.01)
		game.spawn_wave()
		var want_hp = 2 + int(game.count > 1) + int(StageDefs.def_for(s)["hp_bonus"])
		assert(int(game.enemies[0]["hp"]) == want_hp)
		game.begin_boss()
		var want_boss = (65.0 + game.count * 35) * float(StageDefs.def_for(s)["boss_hp_mul"])
		assert(abs(float(game.boss["hp"]) - want_boss) < 0.01)
		game.boss = {}
		game.finish(true)
		assert(bool(game.briefing_progress.cleared.get(s, false)))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_stage_defs.cfg"))
	# Scroll-pace profiles: calm and rush sections exist, endpoints sane, and
	# the average stays near 1.0 so clear times do not drift far.
	assert(absf(StageDefs.pace_at(1, 0.0) - 1.0) < 0.01)
	assert(StageDefs.pace_at(1, 0.3) < 0.8 and StageDefs.pace_at(1, 0.5) > 1.25)
	assert(StageDefs.pace_at(5, 0.45) > 1.4 and StageDefs.pace_at(3, 0.35) < 0.7)
	for s in range(1, 9):
		var total = 0.0
		for i in range(101): total += StageDefs.pace_at(s, i / 100.0)
		var avg = total / 101.0
		assert(avg > 0.9 and avg < 1.12, "pace average must stay near 1.0")
	print("STAGE DEFS PASS: 8 stages defined, launchable, parameterised, clear progression, pace profiles")
	quit(0)

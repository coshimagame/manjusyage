extends SceneTree
# Godot 4.6: godot --headless --path . --script tests/test_jiyoza_analysis.gd
func _initialize(): run.call_deferred()

func run():
	var game=load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.bio_route=true
	game.pilot_offset=1
	game.count=1
	game.enemy_analysis.save_path="user://test_jiyoza_analysis_isolated.cfg"
	game.enemy_analysis.observed.clear()
	game.start_game()
	var pilot=game.players[0]
	assert(pilot.character==1)
	assert(pilot.analysis_charge==0 and pilot.analysis_uses==0)
	game.spawn_wave() # First appearance: aimed pattern is immune.
	assert(not game.enemies[0].analysis_eligible)
	pilot.analysis_charge=100
	game.special_analysis(pilot)
	assert(pilot.analysis_charge==100 and pilot.analysis_uses==0)
	assert(game.enemies[0].hp>0)
	game.spawn_wave() # First appearance: fan pattern is immune.
	game.spawn_wave() # Previously encountered aimed pattern is now eligible.
	assert(game.enemies[-1].analysis_eligible)
	var known=game.enemies[-1]
	var unknown=game.enemies[0]
	game.shots=[
		{"pos":Vector2(200,100),"vel":Vector2.ZERO,"r":3,"analysis_eligible":false,"source_id":"first"},
		{"pos":Vector2(220,100),"vel":Vector2.ZERO,"r":3,"analysis_eligible":true,"source_id":"known"},
		{"pos":Vector2(240,100),"vel":Vector2.ZERO,"r":4,"source_id":"boss"}
	]
	game.special_analysis(pilot)
	assert(pilot.analysis_uses==1 and pilot.analysis_charge==0)
	assert(known.hp<=0 and unknown.hp>0)
	assert(game.shots.size()==2)
	assert(not game.shots[0].get("analysis_eligible",false))
	assert(not game.shots[1].get("analysis_eligible",false))
	game.enemies.clear()
	pilot.analysis_charge=100
	game.boss={"pos":Vector2(530,180),"hp":100.0}
	var hp=game.boss.hp
	game.special_analysis(pilot)
	assert(pilot.analysis_charge==100 and pilot.analysis_uses==1)
	assert(game.boss.hp==hp)
	# No third use, even if the gauge was filled by a developer cheat.
	pilot.analysis_uses=2
	game.enemies.append({"pos":Vector2(350,150),"hp":3,"analysis_eligible":true})
	game.special_analysis(pilot)
	assert(game.enemies[-1].hp==3 and pilot.analysis_uses==2)
	var test_path=game.enemy_analysis.save_path
	game.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_path))
	print("JIYOZA ANALYSIS PASS: first-sighting and boss immunity, bullet-source filtering, item gauge and two-use cap")
	quit(0)

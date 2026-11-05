extends SceneTree
# Run: godot --headless --path . --script res://tests/test_three_pilot_gimmicks.gd
const Abilities = preload("res://pilot_abilities.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	var c := {"charge":100.0}
	Abilities.initialize(c,0)
	var omen=Abilities.draw_omikuji(c,90)
	if int(c.luck)!=90 or int(omen.before)!=50: failures.append("Cormii omikuji reroll")
	if str(Abilities.chance_profile(c,0.99).grade)!="jackpot": failures.append("Cormii jackpot chance")
	if int(Abilities.consume_charged_luck(c))!=82: failures.append("Cormii charged luck drain")
	var j := {"charge":100.0}
	Abilities.initialize(j,1)
	if int(j.analysis_charge)!=0 or int(j.analysis_uses)!=0: failures.append("Jiyoza independent scanner initialization")
	var m := {"charge":100.0}
	Abilities.initialize(m,2)
	m.learned="fan"
	m.digest=1.0
	m.digest_total=1.0
	var fan=Abilities.velocities(m,Vector2.RIGHT,[])
	if fan.size()!=3: failures.append("Mafio captured fan volley")
	Abilities.digest(m,1.1)
	if m.learned!="none" or int(m.experience)!=8: failures.append("Mafio digestion and growth")
	var enemy := {"technique":"halo"}
	if not is_equal_approx(Abilities.digestion_seconds(enemy),9.0): failures.append("Mafio technique duration")
	if failures.is_empty():
		print("PASS: three pilot gimmicks")
		quit(0)
	else:
		for failure in failures: push_error(failure)
		quit(1)

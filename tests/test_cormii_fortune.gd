extends SceneTree
# Godot 4.6: godot --headless --path . --script tests/test_cormii_fortune.gd
const Abilities=preload("res://pilot_abilities.gd")

func _initialize():
	var pilot={}
	Abilities.initialize(pilot,0)
	assert(pilot.luck==50)
	assert(pilot.fortune_history.is_empty())

	var result=Abilities.draw_omikuji(pilot,95)
	assert(result.before==50 and result.after==95 and pilot.luck==95)
	# At high luck, a roll around 60% is a jackpot.
	assert(Abilities.chance_profile(pilot,.60).grade=="jackpot")
	assert(Abilities.chance_profile(pilot,.01).grade=="low") # Never guaranteed!

	result=Abilities.draw_omikuji(pilot,15)
	assert(result.delta==-80 and pilot.luck==15)
	assert(Abilities.chance_profile(pilot,.60).grade=="normal")
	assert(Abilities.chance_profile(pilot,.20).grade=="low")

	# Firing a charge spends 8 luck points even on a weak result.
	Abilities.damage(pilot,0.0,.10)
	assert(pilot.luck==15) # Simple rolls do not drain the fortune.
	assert(Abilities.consume_charged_luck(pilot)==7)
	assert(Abilities.consume_charged_luck(pilot)==0)
	assert(Abilities.consume_charged_luck(pilot)==0)
	Abilities.draw_omikuji(pilot,100)
	assert(Abilities.luck_title(pilot)=="大吉")
	assert(pilot.luck==100)
	assert(Abilities.consume_charged_luck(pilot)==92)
	assert(pilot.fortune_history.size()<=8)
	print("CORMII FORTUNE PASS: immediate reroll, possible downgrade, probabilistic fire, charge-only decay")
	quit(0)

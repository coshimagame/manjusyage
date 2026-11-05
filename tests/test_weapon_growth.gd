extends SceneTree
const Growth = preload("res://weapon_growth.gd")

func _initialize() -> void:
	var a = Growth.new_loadout()
	assert(a.normal == 1 and a.mu_special == 1)
	assert(Growth.gain_level(a, "mu_special").mu_special == 1)
	a = Growth.unlock_mu(a)
	for i in range(4):
		a = Growth.gain_level(a, "normal")
		a = Growth.gain_level(a, "mu_special")
	assert(Growth.fusion_ready(a))
	var b = Growth.on_ship_lost(a, 5)
	assert(b.normal == 1 and b.mu_special == 1 and b.mu_unlocked)
	assert(not Growth.fusion_ready(b))
	assert(a.normal == 5) # input never mutated
	var c = Growth.on_ship_lost(a, 2)
	assert(c.normal == 3 and c.mu_special == 3)
	print("WEAPON_GROWTH_TEST_OK")
	quit()

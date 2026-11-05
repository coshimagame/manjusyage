extends SceneTree
# Run with: godot --headless --path . --script res://tests/test_mafio_shot_patterns.gd
const Abilities = preload("res://pilot_abilities.gd")

func _initialize() -> void:
	var pilot = {"character": 2, "learned": "none", "pos": Vector2.ZERO}
	var forward = Vector2.RIGHT
	var cases = {"none": 1, "fan": 3, "petal": 5, "seed": 3, "halo": 5, "beam": 1, "pierce": 1}
	for technique in cases:
		pilot.learned = technique
		var shots: Array = Abilities.velocities(pilot, forward, [])
		assert(shots.size() == cases[technique], "Incorrect volley count for " + technique)
		for velocity in shots:
			assert(velocity is Vector2 and velocity.length() > 0.0, "Invalid velocity for " + technique)
			assert(velocity.dot(forward) > 0.0, "Backward shot for " + technique)
	pilot.learned = "aimed"
	var target = {"pos": Vector2(200, 100), "hp": 3}
	var aimed: Array = Abilities.velocities(pilot, forward, [target])
	assert(aimed.size() == 1)
	assert(aimed[0].y > 0.0, "Aimed shot should track target")
	print("PASS: Mafio captured-shot patterns")
	quit(0)

extends SceneTree
# Run: godot --headless --path . --script res://tests/test_stage_clear_transition.gd
# Isolated pure logic test: no user:// writes, no existing game state changed.
const Transition = preload("res://scripts/stage_clear_transition.gd")
var failures: Array[String] = []

func _initialize() -> void:
	_check("stage 1 routes to intermission", Transition.make_payload(1, ["cormii"], 120, 1).get("destination") == "intermission")
	_check("stage 1 advances to 2", Transition.make_payload(1, ["cormii"], 120, 1).get("next_stage") == 2)
	_check("stage 8 routes to ending", Transition.make_payload(8, ["jiyoza", "mafio"], 0, 4).get("destination") == "ending")
	_check("stage 8 has no next stage", Transition.make_payload(8, ["jiyoza"], 0).get("next_stage") == 0)
	_check("three distinct pilots valid", Transition.is_valid(Transition.make_payload(3, ["cormii", "jiyoza", "mafio"], 10)))
	_check("duplicate pilots rejected", Transition.make_payload(1, ["mafio", "mafio"], 0).is_empty())
	_check("unknown pilot rejected", Transition.make_payload(1, ["unknown"], 0).is_empty())
	_check("zero pilots rejected", Transition.make_payload(1, [], 0).is_empty())
	_check("stage zero rejected", Transition.make_payload(0, ["cormii"], 0).is_empty())
	_check("stage nine rejected", Transition.make_payload(9, ["cormii"], 0).is_empty())
	_check("invalid worldline rejected", Transition.make_payload(1, ["cormii"], 0, 0).is_empty())
	_check("negative score clamped", Transition.make_payload(1, ["cormii"], -2).get("score") == 0)
	var altered: Dictionary = Transition.make_payload(1, ["cormii"], 10)
	altered["next_stage"] = 7
	_check("tampered destination rejected", not Transition.is_valid(altered))
	if failures.is_empty():
		print("PASS: stage clear transition 13 cases")
		quit(0)
	else:
		for failure in failures:
			push_error("FAIL: " + failure)
		quit(1)

func _check(label: String, condition: bool) -> void:
	if not condition:
		failures.append(label)

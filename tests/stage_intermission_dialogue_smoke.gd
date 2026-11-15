extends SceneTree
## Godot 4.6: godot --headless --path . --script res://tests/stage_intermission_dialogue_smoke.gd
const Dialogue = preload("res://ui/stage_intermission_dialogue.gd")

func _initialize() -> void:
	for players in [1, 2, 3]:
		var payload: Dictionary = Dialogue.build(1, 1, players)
		assert(payload.next_stage == 2)
		assert(payload.active_players == players)
		assert(payload.provisional == true)
		assert(payload.lines.size() == 6)
		var ids: Dictionary = {}
		for line in payload.lines:
			assert(line.id != "")
			assert(line.text != "")
			assert(not ids.has(line.id))
			ids[line.id] = true
	var loop_payload: Dictionary = Dialogue.build(1, 2, 1)
	assert(loop_payload.lines.size() == 7)
	assert(loop_payload.lines[-1].id == "S1_POST_KUU_LOOP")
	var other: Dictionary = Dialogue.build(2)
	assert(other.lines.is_empty())
	print("stage_intermission_dialogue_smoke: PASS")
	quit(0)

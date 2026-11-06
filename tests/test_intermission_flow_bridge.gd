extends SceneTree
## Run: godot --headless --path . --script res://tests/test_intermission_flow_bridge.gd
const Bridge = preload("res://intermission_flow_bridge.gd")
var failures := 0
func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error("FAIL: " + description)
    else:
        print("PASS: " + description)
func _initialize() -> void:
    check(Bridge.next_stage(1) == 2, "first stage advances")
    check(Bridge.next_stage(7) == 8, "seventh stage advances")
    check(Bridge.next_stage(8) == -1, "final stage has no next stage")
    check(Bridge.make_pending(8, 1, 1).is_empty(), "final stage cannot queue next sortie")
    check(Bridge.make_pending(1, 1, 0).is_empty(), "zero players rejected")
    check(Bridge.make_pending(1, 1, 4).is_empty(), "four players rejected")
    check(Bridge.make_pending(1, 0, 1).is_empty(), "invalid worldline rejected")
    for players in range(1, 4):
        for stage in range(1, 8):
            var pending := Bridge.make_pending(stage, 2, players)
            check(Bridge.valid_pending(pending), "valid stage %d, %d players" % [stage, players])
            check(Bridge.sortie_stage(pending) == -1, "cannot skip unseen intermission")
            var seen := Bridge.mark_seen(pending)
            check(Bridge.sortie_stage(seen) == stage + 1, "next stage after viewing")
            check(pending["seen"] == false, "original state not mutated")
            var tampered := pending.duplicate(true)
            tampered["next_stage"] = 8
            if stage != 7:
                check(not Bridge.valid_pending(tampered), "tampered stage rejected")
    print("INTERMISSION BRIDGE TEST failures: ", failures)
    quit(1 if failures > 0 else 0)

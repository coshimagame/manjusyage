extends SceneTree
## Headless regression test for Stage 2 integration.
## Run: godot --headless --path . --script res://tests/stage02_regression.gd
## This intentionally detects missing fixes from draft PRs; it does not change gameplay.
const COMBAT = preload("res://scripts/stage02_combat.gd")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error("FAIL: " + label)
    else:
        print("PASS: " + label)

func _run() -> void:
    var combat: Node2D = COMBAT.new()
    root.add_child(combat)
    await process_frame
    combat.player_pos = Vector2(500, 300)
    combat.hp = 1
    combat.kills = 7
    combat.invulnerable = 2.0
    combat.game_over = true
    combat._load_stage()
    _check(combat.player_pos == Vector2(100, 180), "retry restores player spawn")
    _check(combat.hp == 5, "retry restores HP")
    _check(combat.kills == 0, "retry clears kills")
    _check(is_zero_approx(combat.invulnerable), "retry clears invulnerability")
    _check(not combat.game_over, "retry clears game-over state")
    # Exercise the actual keyboard entry points, not only the reset helper.
    combat.player_pos = Vector2(420, 260)
    combat.hp = 2
    combat.game_over = true
    var retry := InputEventKey.new()
    retry.keycode = KEY_R
    retry.pressed = true
    combat._unhandled_key_input(retry)
    _check(combat.hp == 5 and not combat.game_over and combat.player_pos == Vector2(100, 180), "R key retries from game over")
    combat.hp = 1
    combat.invulnerable = 0.9
    var previous_orientation: bool = combat.vertical
    var orientation := InputEventKey.new()
    orientation.keycode = KEY_TAB
    orientation.pressed = true
    combat._unhandled_key_input(orientation)
    _check(combat.vertical != previous_orientation, "TAB toggles orientation")
    _check(combat.hp == 5 and is_zero_approx(combat.invulnerable), "TAB resets attempt state")
    combat._spawn(11)
    _check(combat.enemies.size() == 1 and combat.enemies[0].slot == 11, "boss spawn is retained")
    combat.queue_free()
    if failures.is_empty():
        print("Stage 2 regression checks passed")
        quit(0)
    else:
        print("Stage 2 regression checks failed: ", failures)
        quit(1)

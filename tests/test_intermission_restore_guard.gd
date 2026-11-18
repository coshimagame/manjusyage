extends SceneTree
# Run with: godot --headless --path . --script res://tests/test_intermission_restore_guard.gd
const Overlay = preload("res://intermission_overlay.gd")
var transitions := 0

func _initialize() -> void:
    call_deferred("_run")

func _on_completed(_stage: int) -> void:
    transitions += 1

func _run() -> void:
    var overlay = Overlay.new()
    root.add_child(overlay)
    overlay.completed.connect(_on_completed)
    overlay.configure(1, 0, 2)
    var before = overlay.snapshot()
    var invalid = before.duplicate(true)
    invalid["line_index"] = 3
    invalid["finished"] = false
    assert(not overlay.restore_snapshot(invalid), "unfinished terminal checkpoint must be rejected")
    assert(overlay.snapshot() == before, "invalid checkpoint must not mutate state")
    assert(transitions == 0, "invalid restore must never emit a transition")
    var valid = before.duplicate(true)
    valid["line_index"] = 2
    assert(overlay.restore_snapshot(valid), "valid in-progress checkpoint should restore")
    assert(transitions == 0, "valid restore must not advance stage")
    valid["line_index"] = 3
    valid["finished"] = true
    assert(overlay.restore_snapshot(valid), "finished checkpoint should restore")
    assert(not overlay.visible, "finished overlay must remain hidden")
    assert(transitions == 0, "finished restore must not emit a transition")
    overlay.queue_free()
    print("PASS: intermission restore guard")
    quit(0)

extends SceneTree
## Verify failed writes never grant stage unlocks in memory.
## godot --headless --path . --script res://tests/test_stage_save_atomicity.gd
const Progress = preload("res://briefing_progress.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, label: String) -> void:
    if not value:
        failures += 1
        push_error("FAIL: " + label)
    else:
        print("PASS: " + label)

func _run() -> void:
    var p = Progress.new()
    p.save_path = "user://missing_test_directory/should_not_exist/progress.cfg"
    check(not p.mark_cleared(1), "Failed save reports failure")
    check(p.highest_unlocked == 1, "Failed save does not unlock stage 2")
    check(not p.cleared.has(1), "Failed save does not mark stage 1 cleared")
    var path := "user://test_stage_save_atomicity.cfg"
    var absolute := ProjectSettings.globalize_path(path)
    DirAccess.remove_absolute(absolute)
    p.save_path = path
    check(p.mark_cleared(1), "Writable save records stage 1 completion")
    check(p.highest_unlocked == 2, "Successful save unlocks stage 2")
    check(p.mark_cleared(1), "Duplicate completion is idempotent")
    var restored = Progress.new()
    restored.save_path = path
    restored.load_data()
    check(restored.highest_unlocked == 2, "Saved stage unlock survives reload")
    DirAccess.remove_absolute(absolute)
    print("Stage save atomicity: %d failure(s)" % failures)
    quit(1 if failures > 0 else 0)

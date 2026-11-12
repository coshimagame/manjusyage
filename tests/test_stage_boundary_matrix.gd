extends SceneTree
## Regression matrix for briefing stage boundaries and inaccessible clears.
## Godot 4.6: godot --headless --path . --script res://tests/test_stage_boundary_matrix.gd
const Progress = preload("res://briefing_progress.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if not ok:
        failures += 1
        push_error("FAIL: " + label)
    else:
        print("PASS: " + label)

func _run() -> void:
    var path := "user://test_stage_boundary_matrix.cfg"
    var absolute := ProjectSettings.globalize_path(path)
    DirAccess.remove_absolute(absolute)
    var progress = Progress.new()
    progress.save_path = path
    progress.load_data()
    for stage in [-100, -1, 0, 3, 8, 9, 100]:
        var before := progress.highest_unlocked
        progress.mark_cleared(stage)
        check(progress.highest_unlocked == before, "Inaccessible stage %d cannot advance progress" % stage)
        check(not progress.can_launch(stage), "Inaccessible stage %d cannot launch" % stage)
    check(progress.can_launch(1), "Stage 1 remains playable")
    progress.mark_cleared(1)
    check(progress.can_launch(2), "Stage 2 becomes playable after stage 1")
    progress.mark_cleared(3)
    check(progress.highest_unlocked == 2, "Stage 3 placeholder cannot advance progress")
    progress.mark_cleared(2)
    check(progress.highest_unlocked == 3, "Stage 2 unlocks stage 3 briefing")
    for stage in range(3, 9):
        check(progress.can_select(stage) == (stage == 3), "Only unlocked briefing stage is selectable: %d" % stage)
        check(not progress.can_launch(stage), "Unimplemented combat remains blocked: %d" % stage)
    var restored = Progress.new()
    restored.save_path = path
    restored.load_data()
    check(restored.highest_unlocked == 3, "Stage boundary survives reload")
    check(not restored.can_launch(3), "Stage 3 stays blocked after reload")
    DirAccess.remove_absolute(absolute)
    print("Stage boundary matrix: %d failure(s)" % failures)
    quit(1 if failures > 0 else 0)

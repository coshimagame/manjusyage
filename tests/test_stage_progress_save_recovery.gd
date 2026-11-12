extends SceneTree
## Save/load regression for stage progression, isolated from normal player data.
## Run with Godot 4.6: godot --headless --path . --script res://tests/test_stage_progress_save_recovery.gd
const Progress = preload("res://briefing_progress.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error("FAIL: " + message)
    else:
        print("PASS: " + message)

func _run() -> void:
    var path := "user://test_stage_progress_save_recovery.cfg"
    var absolute := ProjectSettings.globalize_path(path)
    DirAccess.remove_absolute(absolute)
    var p = Progress.new()
    p.save_path = path
    p.load_data()
    check(p.highest_unlocked == 1, "Fresh isolated profile starts at stage 1")
    p.mark_cleared(1)
    check(FileAccess.file_exists(path), "Stage clear writes isolated save")
    p.mark_cleared(1)
    check(p.highest_unlocked == 2, "Repeated stage 1 clear never skips stage 2")
    var restored = Progress.new()
    restored.save_path = path
    restored.load_data()
    check(restored.can_launch(2), "Stage 2 can launch after reload")
    check(not restored.can_launch(3), "Stage 3 cannot launch before or after reload")
    restored.mark_cleared(2)
    var again = Progress.new()
    again.save_path = path
    again.load_data()
    check(again.highest_unlocked == 3, "Stage 2 completion persists stage 3 briefing")
    check(not again.can_launch(3), "Unimplemented stage 3 combat stays unavailable")
    # A truncated save must never crash loading or grant a future stage.
    var cfg := ConfigFile.new()
    cfg.set_value("stage", "highest_unlocked", 0)
    check(cfg.save(path) == OK, "Isolated malformed-index fixture saved")
    var recovered = Progress.new()
    recovered.save_path = path
    recovered.load_data()
    check(recovered.highest_unlocked == 1, "Out-of-range low save index is clamped")
    check(not recovered.can_launch(2), "Invalid save cannot unlock stage 2")
    DirAccess.remove_absolute(absolute)
    print("Stage save recovery regression: ", failures, " failure(s)")
    quit(1 if failures > 0 else 0)

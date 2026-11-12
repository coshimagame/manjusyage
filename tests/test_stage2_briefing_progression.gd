extends SceneTree
## Stage 1 -> stage 2 unlock and stage 2 -> stage 3 locked-combat regression.
## Run: godot --headless --path . --script res://tests/test_stage2_briefing_progression.gd
## Uses a separate user:// path; never touches the player's actual save.
const BriefingProgress = preload("res://briefing_progress.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, description: String) -> void:
    if value:
        print("PASS: ", description)
    else:
        failures += 1
        push_error("FAIL: " + description)

func _run() -> void:
    var progress = BriefingProgress.new()
    progress.save_path = "user://test_stage2_briefing_progression.cfg"
    var absolute_path := ProjectSettings.globalize_path(progress.save_path)
    DirAccess.remove_absolute(absolute_path)
    progress.load_data()
    check(progress.highest_unlocked == 1, "New game starts at stage 1")
    check(progress.can_launch(1), "Stage 1 playable")
    check(not progress.can_launch(2), "Stage 2 locked before stage 1 clear")
    progress.mark_cleared(2)
    check(progress.highest_unlocked == 1, "Locked stage cannot be cleared to skip progression")
    progress.mark_cleared(1)
    check(progress.highest_unlocked == 2, "Stage 1 unlocks stage 2")
    check(progress.next_briefing_stage() == 2, "Stage 1 leads to stage 2 briefing")
    check(progress.can_launch(2), "Unlocked stage 2 training playable")
    var restored = BriefingProgress.new()
    restored.save_path = progress.save_path
    restored.load_data()
    check(restored.cleared.get(1, false), "Stage 1 clear persists")
    check(restored.can_launch(2), "Stage 2 availability persists")
    restored.mark_cleared(2)
    check(restored.highest_unlocked == 3, "Stage 2 clear unlocks stage 3 briefing")
    check(restored.next_briefing_stage() == 3, "Stage 2 leads to stage 3 briefing")
    check(restored.can_select(3), "Stage 3 can be selected")
    check(not restored.can_launch(3), "Stage 3 combat remains locked until implemented")
    restored.mark_cleared(3)
    check(restored.highest_unlocked == 3, "Unimplemented stage cannot unlock stage 4")
    restored.mark_cleared(9)
    check(restored.highest_unlocked == 3, "Out-of-range clear cannot unlock progress")
    check(not restored.can_launch(9), "Out-of-range stage cannot launch")
    check(not restored.can_select(0), "Stage zero cannot be selected")
    check(not restored.can_select(9), "Stage nine cannot be selected")
    check(restored.stage_name(0) == "不明なステージ", "Stage zero does not masquerade as stage one")
    check(restored.stage_name(9) == "不明なステージ", "Stage nine does not masquerade as stage eight")
    DirAccess.remove_absolute(absolute_path)
    print("Stage progression regression: ", failures, " failure(s)")
    quit(1 if failures > 0 else 0)

extends SceneTree
## Headless regression for the provisional stage interlude.
## Run: godot --headless --path . --script res://tests/test_interlude_playback.gd
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
    var scene: PackedScene = load("res://interlude_preview.tscn")
    check(scene != null, "Interlude scene loads")
    if scene == null:
        quit(1)
        return
    var interlude = scene.instantiate()
    interlude.next_scene = "" # Never leave the test scene.
    root.add_child(interlude)
    await process_frame
    check(interlude.line_index == 0, "Starts on first dialogue")
    check(interlude.speaker_label.text == "クゥ", "First speaker shown")
    interlude._advance()
    check(interlude.dialogue_label.visible_characters == -1, "First press reveals whole line")
    interlude._advance()
    check(interlude.line_index == 1, "Second press advances exactly once")
    interlude._toggle_log()
    check(interlude.log_visible and interlude.log_label.visible, "Log opens")
    interlude._advance()
    check(not interlude.log_visible and interlude.line_index == 1, "Advance closes log without skipping")
    var completion_count := [0]
    interlude.completed.connect(func(): completion_count[0] += 1)
    interlude._finish()
    interlude._finish()
    check(completion_count[0] == 1, "Completion emitted only once")
    check(interlude.finished, "Finished state prevents further input")
    print("Interlude regression: ", failures, " failure(s)")
    quit(1 if failures > 0 else 0)

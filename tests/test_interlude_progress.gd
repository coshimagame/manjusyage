extends SceneTree
# Godot 4.6: godot --headless --path . --script tests/test_interlude_progress.gd
# Tests in-memory cursor restoration; does not touch the player's save files.
const Interlude = preload("res://interlude_preview.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var original := Interlude.new()
    original.lines = [
        {"speaker": "クゥ", "text": "確認"},
        {"speaker": "ムゥ", "text": "整備中"},
        {"speaker": "コルミィ", "text": "出撃"}
    ]
    root.add_child(original)
    await process_frame
    original._advance()
    original._advance()
    original.dialogue_label.visible_characters = 2
    var saved := original.export_progress()
    assert(saved["line_index"] == 1)
    assert(saved["furthest_seen_index"] == 1)
    assert(saved["visible_characters"] == 2)
    var restored := Interlude.new()
    restored.lines = original.lines.duplicate(true)
    restored.restore_progress(saved) # Before _ready().
    root.add_child(restored)
    await process_frame
    assert(restored.line_index == 1)
    assert(restored.furthest_seen_index == 1)
    assert(restored.dialogue_label.visible_characters == 2)
    assert(restored.visible_characters_float == 2.0)
    # _advance() uses -1 as the fully revealed sentinel; save the real length.
    restored.dialogue_label.visible_characters = -1
    var fully_revealed := restored.export_progress()
    assert(fully_revealed["visible_characters"] == restored.dialogue_label.get_total_character_count())
    var replay := Interlude.new()
    replay.lines = restored.lines.duplicate(true)
    replay.restore_progress(fully_revealed)
    root.add_child(replay)
    await process_frame
    assert(replay.dialogue_label.visible_characters == replay.dialogue_label.get_total_character_count())
    replay.queue_free()
    restored._rewind()
    assert(restored.line_index == 0)
    assert(restored.furthest_seen_index == 1)
    restored.restore_progress({"line_index": 999, "furthest_seen_index": 999, "visible_characters": 999})
    assert(restored.line_index == 2)
    assert(restored.dialogue_label.visible_characters <= restored.dialogue_label.get_total_character_count())
    original.queue_free()
    restored.queue_free()
    print("INTERLUDE PROGRESS PASS: roundtrip, early restore, rewind, clamp")
    quit(0)

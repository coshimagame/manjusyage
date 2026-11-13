extends SceneTree
# Read-only import/smoke audit. Run with:
# godot --headless --path . --script res://tests/test_vertical_slice_resources.gd
# This does not claim that a human has played the game.

const REQUIRED = [
    "res://project.godot",
    "res://prologue.tscn",
    "res://game.gd",
    "res://main.tscn",
]
const OPTIONAL = [
    "res://art/active/ship_cormii.png",
    "res://art/active/ship_jiyoza.png",
    "res://art/active/ship_mafio.png",
    "res://art/ui/character_system_ui_20261106.png",
    "res://prototypes/stage2_combat.gd",
    "res://prototypes/stage_clear_intermission.tscn",
]

func _initialize() -> void:
    var failures: Array[String] = []
    for path in REQUIRED:
        if not FileAccess.file_exists(path):
            failures.append("Missing required: " + path)
        else:
            print("PRESENT: ", path)
    for path in OPTIONAL:
        print(("PRESENT: " if FileAccess.file_exists(path) else "NOT IN MAIN / OPTIONAL: "), path)
    for path in ["res://prologue.tscn", "res://main.tscn"]:
        if FileAccess.file_exists(path):
            var scene = load(path)
            if not (scene is PackedScene):
                failures.append("Cannot load PackedScene: " + path)
            else:
                print("LOAD OK: ", path)
    if failures.is_empty():
        print("RESOURCE AUDIT PASS (not a gameplay or export test)")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

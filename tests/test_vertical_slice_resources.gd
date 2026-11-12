extends SceneTree
# Run after Godot 4.6 import:
# godot --headless --path . --script res://tests/test_vertical_slice_resources.gd
# This checks import/parse and required scene dependencies, not gameplay completion.
const REQUIRED_SCENES := [
    "res://prologue.tscn",
    "res://main.tscn",
    "res://interlude_preview.tscn"
]
const REQUIRED_SCRIPTS := [
    "res://game.gd",
    "res://prologue.gd",
    "res://interlude_preview.gd",
    "res://interlude_flow.gd"
]

func _initialize() -> void:
    call_deferred("_check")

func _check() -> void:
    var failures: Array[String] = []
    var configured_main := str(ProjectSettings.get_setting("application/run/main_scene", ""))
    if configured_main.is_empty():
        failures.append("application/run/main_scene is empty")
    elif not ResourceLoader.exists(configured_main):
        failures.append("Configured main scene missing: " + configured_main)
    for path in REQUIRED_SCENES:
        if not ResourceLoader.exists(path):
            failures.append("Missing scene: " + path)
            continue
        var packed := load(path) as PackedScene
        if packed == null:
            failures.append("Cannot load scene: " + path)
            continue
        var instance := packed.instantiate()
        if instance == null:
            failures.append("Cannot instantiate scene: " + path)
        else:
            instance.free()
    for path in REQUIRED_SCRIPTS:
        if not ResourceLoader.exists(path):
            failures.append("Missing script: " + path)
        elif load(path) == null:
            failures.append("Cannot load script: " + path)
    if failures.is_empty():
        print("VERTICAL SLICE RESOURCE SMOKE PASS (not a gameplay test)")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        print("VERTICAL SLICE RESOURCE SMOKE FAIL: ", failures.size(), " issue(s)")
        quit(1)

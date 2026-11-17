extends SceneTree
# Godot 4.6: godot --headless --path . --script tests/test_stage1_entrypoint_smoke.gd
# Run with a disposable user-data directory/profile. This test does not start gameplay.
# Fail with an explicit nonzero exit code rather than silently passing missing resources.
func _initialize() -> void:
    var failures: Array[String] = []
    var required := [
        "res://project.godot",
        "res://prologue.tscn",
        "res://prologue.gd",
        "res://game.gd",
        "res://pilot_abilities.gd",
        "res://mafio_archive.gd",
        "res://vertical_passage.gd",
        "res://biological_stage.gd",
        "res://visual_v09.gd"
    ]
    for path in required:
        if not FileAccess.file_exists(path):
            failures.append("Missing: " + path)
    if failures.is_empty():
        var scene := load("res://prologue.tscn") as PackedScene
        if scene == null:
            failures.append("Cannot load main scene")
        else:
            var root := scene.instantiate()
            if root == null or not root is Node2D:
                failures.append("Main scene root must be Node2D")
            if root != null:
                root.free()
        var game_script := load("res://game.gd") as Script
        if game_script == null or not game_script.can_instantiate():
            failures.append("Cannot instantiate game script")
        else:
            var game := game_script.new()
            if game == null or not game is Node2D:
                failures.append("Game root must be Node2D")
            if game != null:
                game.free()
    if failures.is_empty():
        print("STAGE1 ENTRYPOINT SMOKE PASS (load/instantiate only; gameplay NOT tested)")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

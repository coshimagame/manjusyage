extends SceneTree
## Minimal Godot 4.6 import/scene-instantiation regression for the real entry flow.
## Run with: godot --headless --path . --script res://tests/main_scene_entry_smoke.gd
## Uses an isolated user-data directory when launched with --user-data-dir.

const SCENES: Array[String] = [
    "res://prologue.tscn",
    "res://game.tscn",
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var failures: Array[String] = []
    for path in SCENES:
        if not ResourceLoader.exists(path):
            failures.append("Missing scene: " + path)
            continue
        var packed := load(path) as PackedScene
        if packed == null:
            failures.append("Failed to load scene: " + path)
            continue
        var instance := packed.instantiate()
        if instance == null:
            failures.append("Failed to instantiate scene: " + path)
            continue
        root.add_child(instance)
        await process_frame
        await process_frame
        if not is_instance_valid(instance) or not instance.is_inside_tree():
            failures.append("Scene left tree unexpectedly: " + path)
        if is_instance_valid(instance):
            instance.queue_free()
        await process_frame
    if failures.is_empty():
        print("PASS: prologue and game scenes loaded and entered tree")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

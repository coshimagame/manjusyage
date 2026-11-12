extends SceneTree
# Godot 4.6 headless runtime smoke test, not a complete playthrough.
# Run after importing assets:
# godot --headless --path . --script res://tests/test_vertical_slice_runtime.gd
#
# Loads the actual entry scene and runs a short idle/physics loop.
# Uses a separate user-data directory when running CI to protect real saves.

const MAIN_SCENE := "res://prologue.tscn"
const FRAMES := 45

func _initialize() -> void:
    call_deferred("_run_smoke")

func _run_smoke() -> void:
    if not ResourceLoader.exists(MAIN_SCENE):
        push_error("Missing entry scene: " + MAIN_SCENE)
        quit(1)
        return
    var scene := load(MAIN_SCENE) as PackedScene
    if scene == null:
        push_error("Entry scene cannot be loaded")
        quit(1)
        return
    var instance := scene.instantiate()
    if instance == null:
        push_error("Entry scene cannot be instantiated")
        quit(1)
        return
    root.add_child(instance)
    for frame in range(FRAMES):
        await process_frame
        if not is_instance_valid(instance) or instance.is_queued_for_deletion():
            push_error("Entry scene disappeared before frame " + str(frame))
            quit(1)
            return
    print("VERTICAL SLICE RUNTIME SMOKE PASS: entry scene alive for ", FRAMES, " frames; no gameplay claim")
    instance.queue_free()
    quit(0)

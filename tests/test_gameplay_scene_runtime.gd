extends SceneTree
# Godot 4.6 gameplay scene smoke test. Does not claim a completed playthrough.
# Run with an isolated user-data profile after importing the project:
# godot --headless --path . --script res://tests/test_gameplay_scene_runtime.gd
#
# Unlike the prologue-only runtime smoke, this instantiates the actual combat scene.
# Do not alter real saves or rely on this test as controller/audio acceptance.

const GAME_SCENE := "res://main.tscn"
const FRAMES := 90

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not ResourceLoader.exists(GAME_SCENE):
        push_error("Gameplay scene missing: " + GAME_SCENE)
        quit(1)
        return
    var packed := load(GAME_SCENE) as PackedScene
    if packed == null:
        push_error("Gameplay scene cannot load")
        quit(1)
        return
    var instance := packed.instantiate()
    if instance == null:
        push_error("Gameplay scene cannot instantiate")
        quit(1)
        return
    root.add_child(instance)
    for frame in range(FRAMES):
        await process_frame
        if not is_instance_valid(instance) or instance.is_queued_for_deletion():
            push_error("Gameplay scene exited unexpectedly at frame " + str(frame))
            quit(1)
            return
    print("GAMEPLAY SCENE SMOKE PASS: ", FRAMES, " frames alive (not a playthrough)")
    instance.queue_free()
    quit(0)

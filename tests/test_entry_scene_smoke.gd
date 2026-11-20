extends SceneTree
# Release smoke check: validates that the configured entry scene can be loaded
# and instantiated without touching user:// saves or starting gameplay.
# Run: godot --headless --path . --script tests/test_entry_scene_smoke.gd

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene_path := str(ProjectSettings.get_setting("application/run/main_scene", ""))
    if scene_path.is_empty():
        push_error("FAIL: application/run/main_scene is not configured")
        quit(1)
        return
    if not ResourceLoader.exists(scene_path):
        push_error("FAIL: entry scene missing: " + scene_path)
        quit(1)
        return
    var packed := load(scene_path) as PackedScene
    if packed == null:
        push_error("FAIL: entry scene could not be loaded: " + scene_path)
        quit(1)
        return
    var instance := packed.instantiate()
    if instance == null:
        push_error("FAIL: entry scene could not be instantiated")
        quit(1)
        return
    instance.free()
    print("PASS: entry scene loads and instantiates: " + scene_path)
    print("NOTE: no scene entered tree; gameplay, audio, input and save remain untested")
    quit(0)

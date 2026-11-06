extends SceneTree
## Release smoke check: launch with godot --headless --path . --script res://tests/release_smoke.gd
## No game state or save files are modified.
const REQUIRED := [
    "res://project.godot",
    "res://prologue.tscn",
    "res://main.tscn",
    "res://game.gd",
    "res://prologue.gd",
    "res://art_catalog.gd",
    "res://art/active/ship_cormii.png",
    "res://art/active/ship_jiyoza.png",
    "res://art/active/ship_mafio.png",
    "res://audio/title.wav",
    "res://audio/shot.wav",
    "res://audio/hit.wav"
]
func _initialize() -> void:
    var failed := false
    for path in REQUIRED:
        if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
            push_error("RELEASE MISSING: " + path)
            failed = true
        else:
            print("RELEASE OK: " + path)
    for path in ["res://prologue.tscn", "res://main.tscn"]:
        if ResourceLoader.load(path) == null:
            push_error("RELEASE SCENE FAILED: " + path)
            failed = true
    if failed:
        print("RELEASE SMOKE: FAIL")
        quit(1)
    else:
        print("RELEASE SMOKE: PASS (resource presence and scene load only; not gameplay)")
        quit(0)

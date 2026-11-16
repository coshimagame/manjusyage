extends SceneTree
# Asset decoding regression for the shipped 640x360 Godot 4.6 project.
# Run: godot --headless --path . --script res://tests/asset_integrity_smoke.gd
# Does not modify any save or imported artwork.
const REQUIRED := [
    "res://art/ui/launch_button_v01.png",
    "res://art/ui/title_logo_extended_v01.png"
]
const OPTIONAL := [
    "res://art/ui/chat_ui_atlas_20261106.png",
    "res://art/ui/character_hub_ui_20261106.png",
    "res://art/ui/character_system_ui_20261106.png",
    "res://art/active/title_logo.png"
]

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var failures := 0
    for path in REQUIRED:
        if not _check_png(path, true):
            failures += 1
    for path in OPTIONAL:
        if FileAccess.file_exists(path) and not _check_png(path, false):
            failures += 1
    if failures > 0:
        push_error("Asset integrity smoke: %d invalid/missing required PNG(s)" % failures)
    else:
        print("Asset integrity smoke: PASS (optional missing art is allowed)")
    quit(1 if failures > 0 else 0)

func _check_png(path: String, required: bool) -> bool:
    if not FileAccess.file_exists(path):
        if required:
            push_error("Missing required UI PNG: " + path)
        else:
            print("Optional PNG absent: " + path)
        return not required
    var image := Image.load_from_file(path)
    if image == null or image.is_empty():
        push_error("Cannot decode PNG: " + path)
        return false
    if image.get_width() <= 0 or image.get_height() <= 0:
        push_error("Invalid PNG dimensions: " + path)
        return false
    if image.get_width() > 8192 or image.get_height() > 8192:
        push_error("Oversized PNG: " + path)
        return false
    print("PNG OK: %s (%dx%d)" % [path, image.get_width(), image.get_height()])
    return true

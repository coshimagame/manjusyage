extends SceneTree
# Run: godot --headless --path . --script res://tests/test_release_resources.gd
# Read-only release gate: protects approved art and music from silent omission.
const REQUIRED_SCENES = [
    "res://prologue.tscn",
    "res://game.tscn"
]
const REQUIRED_SCRIPTS = [
    "res://game.gd",
    "res://prologue.gd",
    "res://visual_v09.gd",
    "res://pilot_abilities.gd",
    "res://biological_stage.gd"
]
const REQUIRED_AUDIO = [
    "res://audio/title.wav",
    "res://audio/shot.wav",
    "res://audio/hit.wav",
    "res://audio/red_echo_v09.wav",
    "res://audio/red_echo_boss_v09.wav"
]
const OPTIONAL_ART = [
    "res://art/active/title_logo.png",
    "res://art/ui/launch_button_v01.png",
    "res://art/ui/character_hub_ui_20261106.png",
    "res://art/ui/character_system_ui_20261106.png"
]

func _initialize() -> void:
    var failures: Array[String] = []
    for path in REQUIRED_SCENES:
        if not ResourceLoader.exists(path):
            failures.append("Missing scene: " + path)
        elif load(path) == null:
            failures.append("Unusable scene: " + path)
    for path in REQUIRED_SCRIPTS:
        if not FileAccess.file_exists(path):
            failures.append("Missing script: " + path)
        elif load(path) == null:
            failures.append("Unusable script: " + path)
    for path in REQUIRED_AUDIO:
        if not FileAccess.file_exists(path):
            failures.append("Missing required sound: " + path)
        elif load(path) == null:
            failures.append("Unusable sound: " + path)
    for path in OPTIONAL_ART:
        if not FileAccess.file_exists(path):
            print("OPTIONAL ART NOT PACKAGED: ", path, " (keep fallback; do not invent approved art)")
        else:
            var img := Image.load_from_file(path)
            if img == null or img.is_empty():
                failures.append("Unreadable art: " + path)
            else:
                print("ART OK: ", path, " ", img.get_width(), "x", img.get_height())
    if failures.is_empty():
        print("RELEASE RESOURCE AUDIT PASS (not a gameplay or export test)")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        print("RELEASE RESOURCE AUDIT FAILED: ", failures.size(), " problem(s)")
        quit(1)

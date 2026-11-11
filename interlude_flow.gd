extends RefCounted
## Stage-clear bridge for the existing interlude scene.
## Example: InterludeFlow.launch(get_tree(), "res://stage2.tscn", dialogue)
## This does not mark dialogue as canon or mutate save data.
const INTERLUDE_SCENE: PackedScene = preload("res://interlude_preview.tscn")

static func launch(tree: SceneTree, destination: String, dialogue: Array[Dictionary]) -> bool:
    if tree == null or tree.root == null:
        push_error("InterludeFlow: scene tree is unavailable")
        return false
    if destination.is_empty() or not ResourceLoader.exists(destination, "PackedScene"):
        push_error("InterludeFlow: destination scene missing: " + destination)
        return false
    if dialogue.is_empty():
        push_error("InterludeFlow: dialogue must not be empty")
        return false
    for entry in dialogue:
        if not entry.has("speaker") or not entry.has("text"):
            push_error("InterludeFlow: each dialogue entry needs speaker and text")
            return false
    var interlude := INTERLUDE_SCENE.instantiate()
    interlude.next_scene = destination
    interlude.lines = dialogue.duplicate(true)
    # Deferred transition prevents removing a stage while its callback is active.
    tree.change_scene_to_packed.call_deferred(INTERLUDE_SCENE)
    # SceneTree.change_scene_to_packed creates another instance; instead,
    # set up the instance after transition on the next frame.
    _configure_after_transition.call_deferred(tree, destination, dialogue.duplicate(true))
    return true

static func _configure_after_transition(tree: SceneTree, destination: String, dialogue: Array[Dictionary]) -> void:
    await tree.process_frame
    var current := tree.current_scene
    if current == null or current.scene_file_path != "res://interlude_preview.tscn":
        push_error("InterludeFlow: interlude transition did not complete")
        return
    current.next_scene = destination
    current.lines = dialogue
    current.line_index = 0
    current._show_line()

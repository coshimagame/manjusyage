extends RefCounted
## Non-canon bridge: call from a stage-clear handler.
## const InterludeFlow = preload("res://interlude_flow.gd")
## InterludeFlow.launch(get_tree(), "res://next_stage.tscn", dialogue)
const INTERLUDE_SCENE: PackedScene = preload("res://interlude_preview.tscn")

static func launch(tree: SceneTree, destination: String, dialogue: Array[Dictionary]) -> bool:
    if tree == null or tree.root == null or tree.current_scene == null:
        push_error("InterludeFlow: no active stage")
        return false
    if destination.is_empty() or not ResourceLoader.exists(destination, "PackedScene"):
        push_error("InterludeFlow: missing destination: " + destination)
        return false
    if dialogue.is_empty():
        push_error("InterludeFlow: empty dialogue")
        return false
    for entry in dialogue:
        if not entry.has("speaker") or not entry.has("text") or str(entry["speaker"]).strip_edges().is_empty() or str(entry["text"]).strip_edges().is_empty():
            push_error("InterludeFlow: speaker/text required")
            return false
    if not ResourceLoader.exists("res://interlude_preview.tscn", "PackedScene"):
        push_error("InterludeFlow: missing interlude scene")
        return false
    var interlude := INTERLUDE_SCENE.instantiate()
    if interlude == null:
        push_error("InterludeFlow: failed to instantiate interlude")
        return false
    interlude.next_scene = destination
    interlude.lines = dialogue.duplicate(true)
    # Defer scene replacement to avoid freeing the current scene mid-signal.
    _swap.call_deferred(tree, interlude)
    return true

static func _swap(tree: SceneTree, interlude: Node) -> void:
    if tree == null or tree.root == null or tree.current_scene == null:
        interlude.free()
        return
    var old_scene := tree.current_scene
    # Set current_scene before _ready() may emit completion; keep scene ownership consistent.
    tree.root.add_child(interlude)
    tree.current_scene = interlude
    old_scene.queue_free()

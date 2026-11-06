extends Control
## Read-only in-game gallery for every existing repository PNG.
## Does not replace or approve any artwork.
const ROOTS := ["res://art", "res://docs/images", "res://docs/screenshots", "res://books"]
var scroll: ScrollContainer
var grid: GridContainer
func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var panel := VBoxContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(panel)
    var heading := Label.new()
    heading.text = "MANJUSHAGE | EXISTING ART GALLERY (unapproved artwork included)"
    panel.add_child(heading)
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_child(scroll)
    grid = GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 12)
    grid.add_theme_constant_override("v_separation", 12)
    scroll.add_child(grid)
    var paths: Array[String] = []
    for root in ROOTS:
        _collect(root, paths)
    paths.sort()
    for path in paths:
        _add_preview(path)
    if paths.is_empty():
        var empty := Label.new()
        empty.text = "No PNG files found in packaged project."
        grid.add_child(empty)
func _collect(folder: String, paths: Array[String]) -> void:
    var dir := DirAccess.open(folder)
    if dir == null:
        return
    dir.list_dir_begin()
    while true:
        var name := dir.get_next()
        if name.is_empty():
            break
        if name.begins_with("."):
            continue
        var path := folder.path_join(name)
        if dir.current_is_dir():
            _collect(path, paths)
        elif name.to_lower().ends_with(".png"):
            paths.append(path)
    dir.list_dir_end()
func _add_preview(path: String) -> void:
    var card := VBoxContainer.new()
    card.custom_minimum_size = Vector2(195, 150)
    grid.add_child(card)
    var texture := load(path) as Texture2D
    if texture != null:
        var preview := TextureRect.new()
        preview.texture = texture
        preview.custom_minimum_size = Vector2(180, 110)
        preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        card.add_child(preview)
    var label := Label.new()
    label.text = path.trim_prefix("res://")
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    card.add_child(label)

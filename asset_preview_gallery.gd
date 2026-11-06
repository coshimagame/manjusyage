extends Control
## Standalone in-engine visual inventory. Never modifies source images.
## Run: godot --path . res://asset_preview_gallery.tscn
const SEARCH_DIRS = ["res://art/active", "res://assets/reference/originals", "res://assets/ui", "res://docs/images"]
var entries: Array[String] = []
var selected := 0
var image_view: TextureRect
var status_label: Label
var item_list: ItemList

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var root := HBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    var sidebar := VBoxContainer.new()
    sidebar.custom_minimum_size = Vector2(220, 0)
    root.add_child(sidebar)
    var heading := Label.new()
    heading.text = "曼珠沙華 / 素材原本確認"
    sidebar.add_child(heading)
    var refresh := Button.new()
    refresh.text = "再読み込み"
    refresh.pressed.connect(_scan)
    sidebar.add_child(refresh)
    item_list = ItemList.new()
    item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
    item_list.item_selected.connect(_show_entry)
    sidebar.add_child(item_list)
    var right := VBoxContainer.new()
    right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_child(right)
    image_view = TextureRect.new()
    image_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    image_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    image_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    image_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right.add_child(image_view)
    status_label = Label.new()
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    right.add_child(status_label)
    _scan()

func _scan() -> void:
    entries.clear()
    item_list.clear()
    for folder in SEARCH_DIRS:
        _scan_dir(folder)
    entries.sort()
    for path in entries:
        item_list.add_item(path.trim_prefix("res://"))
    if entries.is_empty():
        image_view.texture = null
        status_label.text = "画像が見つかりません。原本は未転送の可能性があります。新規生成や代替画像への置換は行いません。"
    else:
        item_list.select(0)
        _show_entry(0)

func _scan_dir(folder: String) -> void:
    var dir := DirAccess.open(folder)
    if dir == null:
        return
    dir.list_dir_begin()
    var name := dir.get_next()
    while name != "":
        if not name.begins_with("."):
            var path := folder.path_join(name)
            if dir.current_is_dir():
                _scan_dir(path)
            elif name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
                entries.append(path)
        name = dir.get_next()
    dir.list_dir_end()

func _show_entry(index: int) -> void:
    if index < 0 or index >= entries.size():
        return
    selected = index
    var path := entries[index]
    var image := Image.new()
    var err := image.load(ProjectSettings.globalize_path(path))
    if err != OK:
        image_view.texture = null
        status_label.text = "読み込み失敗: " + path + " / error " + str(err)
        return
    image_view.texture = ImageTexture.create_from_image(image)
    status_label.text = "%d / %d  |  %s  |  %d × %d px\n原本の確認専用。人物名・表情・採用可否は画像と設定台帳を照合してください。" % [index + 1, entries.size(), path, image.get_width(), image.get_height()]

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo or entries.is_empty():
        return
    if event.keycode == KEY_RIGHT:
        selected = mini(selected + 1, entries.size() - 1)
    elif event.keycode == KEY_LEFT:
        selected = maxi(selected - 1, 0)
    else:
        return
    item_list.select(selected)
    item_list.ensure_current_is_visible()
    _show_entry(selected)
    get_viewport().set_input_as_handled()

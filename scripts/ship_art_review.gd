extends Control
## Review-only ship art inspection. Does not modify game assets or canon.
const SLOTS := ["ship_cormii", "ship_jiyoza", "ship_mafio"]
const NAMES := ["コルミィ", "ジヨーザ", "マフィオ"]
const ACCENTS := [Color("#f5a142"), Color("#5ac9ff"), Color("#c4a34b")]
var chosen := 0
var textures: Array[Texture2D] = []
var status: Label
var title: Label
var ship_view: TextureRect
var prev_button: Button
var next_button: Button

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var backdrop := ColorRect.new()
 backdrop.color = Color("#101321")
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(backdrop)
 var box := VBoxContainer.new()
 box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 box.add_theme_constant_override("separation", 12)
 add_child(box)
 title = Label.new()
 title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override("font_size", 22)
 box.add_child(title)
 var center := CenterContainer.new()
 center.size_flags_vertical = Control.SIZE_EXPAND_FILL
 box.add_child(center)
 ship_view = TextureRect.new()
 ship_view.custom_minimum_size = Vector2(240, 160)
 ship_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 ship_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 ship_view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 center.add_child(ship_view)
 status = Label.new()
 status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 box.add_child(status)
 var row := HBoxContainer.new()
 row.alignment = BoxContainer.ALIGNMENT_CENTER
 box.add_child(row)
 prev_button = Button.new()
 prev_button.text = "◀ 前の機体"
 prev_button.pressed.connect(_previous)
 row.add_child(prev_button)
 next_button = Button.new()
 next_button.text = "次の機体 ▶"
 next_button.pressed.connect(_next)
 row.add_child(next_button)
 textures.clear()
 for key in SLOTS:
  var path := "res://art/active/%s.png" % key
  textures.append(load(path) as Texture2D if ResourceLoader.exists(path, "Texture2D") else null)
 _refresh()

func _previous() -> void:
 chosen = (chosen + 2) % 3
 _refresh()

func _next() -> void:
 chosen = (chosen + 1) % 3
 _refresh()

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode in [KEY_LEFT, KEY_A]:
   _previous()
   get_viewport().set_input_as_handled()
  elif event.keycode in [KEY_RIGHT, KEY_D]:
   _next()
   get_viewport().set_input_as_handled()

func _refresh() -> void:
 title.text = "機体アート確認 / %s" % NAMES[chosen]
 title.add_theme_color_override("font_color", ACCENTS[chosen])
 ship_view.texture = textures[chosen]
 if textures[chosen] == null:
  status.text = "PNG未配置：art/active/%s.png\n※承認済み配色改訂案の原本を確認するまで代替デザインは表示しません。" % SLOTS[chosen]
 else:
  status.text = "配置済みPNG（承認状態は別途確認）：art/active/%s.png\n元画像・作者・採用可否を確認してから本編に反映してください。" % SLOTS[chosen]

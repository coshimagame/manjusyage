extends PanelContainer
## Runtime pilot status card. Portraits are injected by the caller; no approved art is replaced.
## This is a reusable UI component, not yet wired into game.gd.
class_name ManjushagePilotStatusCard

signal pilot_selected(pilot_index: int)

const PILOT_NAMES := ["コルミィ", "ジヨーザ", "マフィオ"]
const PILOT_COLORS := [
	Color("#ff6b54"), Color("#69c9ff"), Color("#f5cb66")
]

var pilot_index: int = 0
var portrait: Texture2D
var hp: int = 3
var max_hp: int = 3
var weapon_level: int = 1
var ability_percent: int = 0
var selectable: bool = false

var _portrait_rect: TextureRect
var _name_label: Label
var _hp_label: Label
var _weapon_label: Label
var _ability_label: Label
var _select_button: Button

func _ready() -> void:
	custom_minimum_size = Vector2(176, 132)
	var column := VBoxContainer.new()
	add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	_portrait_rect = TextureRect.new()
	_portrait_rect.custom_minimum_size = Vector2(56, 64)
	_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	top.add_child(_portrait_rect)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(details)
	_name_label = Label.new()
	details.add_child(_name_label)
	_hp_label = Label.new()
	details.add_child(_hp_label)
	_weapon_label = Label.new()
	details.add_child(_weapon_label)
	_ability_label = Label.new()
	details.add_child(_ability_label)
	_select_button = Button.new()
	_select_button.text = "出撃機に選択"
	_select_button.pressed.connect(func() -> void: pilot_selected.emit(pilot_index))
	column.add_child(_select_button)
	_refresh()

func configure(index: int, image: Texture2D = null, current_hp: int = 3, hp_limit: int = 3, weapon: int = 1, ability: int = 0, allow_select: bool = false) -> void:
	pilot_index = clampi(index, 0, PILOT_NAMES.size() - 1)
	portrait = image
	max_hp = maxi(1, hp_limit)
	hp = clampi(current_hp, 0, max_hp)
	weapon_level = clampi(weapon, 1, 5)
	ability_percent = clampi(ability, 0, 100)
	selectable = allow_select
	if is_node_ready():
		_refresh()

func _refresh() -> void:
	_name_label.text = PILOT_NAMES[pilot_index]
	_name_label.add_theme_color_override("font_color", PILOT_COLORS[pilot_index])
	_portrait_rect.texture = portrait
	_portrait_rect.visible = portrait != null
	_hp_label.text = "HP  %d / %d" % [hp, max_hp]
	_weapon_label.text = "WEAPON  Lv.%d" % weapon_level
	_ability_label.text = "ABILITY  %d%%" % ability_percent
	_select_button.visible = selectable

extends Control
## Standalone, keyboard-testable portrait preview. No canon dialogue or approved art is replaced.
const Bridge = preload("res://intermission_portrait_bridge.gd")
const Portraits = preload("res://control_room_portraits.tscn")
const PILOTS = ["コルミィ", "ジヨーザ", "マフィオ"]
var index := 0
var mu_speaking := true
var overlay: Control
var hint: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = Portraits.instantiate()
	add_child(overlay)
	hint = Label.new()
	hint.text = "LEFT/RIGHT: PILOT   SPACE: SPEAKER   ESC: CLOSE"
	hint.position = Vector2(28, 330)
	hint.add_theme_color_override("font_color", Color.WHITE)
	add_child(hint)
	_refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_LEFT:
			index = posmod(index - 1, PILOTS.size())
		KEY_RIGHT:
			index = (index + 1) % PILOTS.size()
		KEY_SPACE:
			mu_speaking = not mu_speaking
		KEY_ESCAPE:
			get_tree().quit()
		_:
			return
	_refresh()
	get_viewport().set_input_as_handled()

func _refresh() -> void:
	var pilot: String = PILOTS[index]
	var speaker := "ムゥ" if mu_speaking else pilot
	# Empty paths intentionally expose missing-art labels until approved PNGs are located.
	Bridge.apply_dialogue(overlay, speaker, pilot, "", "")

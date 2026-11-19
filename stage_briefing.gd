extends Control
## Optional stage briefing screen. No canon dialogue or approved portrait is replaced.
signal launch_requested(stage_number: int)
signal return_requested

@export_range(1, 8) var stage_number: int = 2
var _launch_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = Color("#090e20")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	center.add_child(layout)
	var heading := Label.new()
	heading.text = "MANJUSHAGE / BRIEFING"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(heading)
	var stage := Label.new()
	stage.text = "STAGE %02d / 08" % stage_number
	stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(stage)
	var placeholder := Label.new()
	placeholder.text = "管制通信終了。次の出撃準備へ。\n（仮表示・正式台詞ではありません）"
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(placeholder)
	_launch_button = Button.new()
	_launch_button.text = "出撃 / LAUNCH"
	_launch_button.pressed.connect(_on_launch)
	layout.add_child(_launch_button)
	var back := Button.new()
	back.text = "戻る / BACK"
	back.pressed.connect(func(): return_requested.emit())
	layout.add_child(back)
	_launch_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		return_requested.emit()

func _on_launch() -> void:
	launch_requested.emit(stage_number)

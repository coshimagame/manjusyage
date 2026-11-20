extends CanvasLayer
## Stage-clear choice overlay. Instantiate with StageClearGate.new(), add_child(),
## then call open(stage_number). Does not modify save data or existing scenes.
signal next_stage_requested
signal retry_requested
signal save_requested

var _panel: PanelContainer
var _title: Label
var _buttons: Array[Button] = []
var _stage_number := 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	visible = false
	_build_ui()

func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.06, 0.88)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(360, 220)
	center.add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	_panel.add_child(column)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 24)
	column.add_child(_title)
	var choices := [
		["NEXT STAGE", "next"],
		["RETRY", "retry"],
		["SAVE", "save"]
	]
	for choice in choices:
		var button := Button.new()
		button.text = choice[0]
		button.custom_minimum_size = Vector2(300, 42)
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_choose.bind(choice[1]))
		column.add_child(button)
		_buttons.append(button)

func open(stage_number: int) -> void:
	_stage_number = maxi(1, stage_number)
	_title.text = "STAGE %02d CLEAR" % _stage_number
	visible = true
	if not _buttons.is_empty():
		_buttons[0].grab_focus()

func close() -> void:
	visible = false

func _choose(action: String) -> void:
	match action:
		"next":
			next_stage_requested.emit()
		"retry":
			retry_requested.emit()
		"save":
			save_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()

extends Control
## Optional stage-clear bridge. Provisional UI; no new story canon.
## Run directly as a scene for review. Never modifies player saves.
const NEXT_SCENE := "res://stage2_prototype.tscn"
const RETURN_SCENE := "res://game.tscn"
var panel: PanelContainer
var message: Label
var next_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#090f22")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.custom_minimum_size = Vector2(440, 200)
	layout.position = Vector2(100, 75)
	add_child(layout)
	var heading := Label.new()
	heading.text = "STAGE CLEAR / 管制ブリーフィング"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(heading)
	var portraits := HBoxContainer.new()
	layout.add_child(portraits)
	var left := Label.new()
	left.text = "会話相手\n[正式画像未設定]"
	left.custom_minimum_size = Vector2(215, 75)
	left.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portraits.add_child(left)
	var right := Label.new()
	right.text = "ムゥ\n[正式画像未設定]"
	right.custom_minimum_size = Vector2(215, 75)
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portraits.add_child(right)
	message = Label.new()
	message.text = "第1面クリア。次の出撃準備へ。\n※仮表示：正式台詞ではありません"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(message)
	next_button = Button.new()
	next_button.text = "次のステージへ"
	next_button.pressed.connect(_go_next)
	layout.add_child(next_button)
	var back := Button.new()
	back.text = "タイトルへ戻る"
	back.pressed.connect(_go_back)
	layout.add_child(back)
	if not ResourceLoader.exists(NEXT_SCENE):
		next_button.disabled = true
		message.text = "第2面シーンは未統合です。\n依存PRの統合後に出撃できます。"
	next_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back()
		get_viewport().set_input_as_handled()

func _go_next() -> void:
	if ResourceLoader.exists(NEXT_SCENE):
		get_tree().change_scene_to_file(NEXT_SCENE)

func _go_back() -> void:
	if ResourceLoader.exists(RETURN_SCENE):
		get_tree().change_scene_to_file(RETURN_SCENE)

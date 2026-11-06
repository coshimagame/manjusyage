extends Control
## Standalone playable intermission preview. Temporary dialogue is NOT canon.
## Open res://intermission_preview.tscn with F6 in Godot 4.6.
const DialoguePanel = preload("res://intermission_dialogue_panel.tscn")
var dialogue: Control
var stage := 1
var loop_index := 1
var status_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#10172b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	status_label = Label.new()
	status_label.position = Vector2(24, 20)
	status_label.add_theme_font_size_override("font_size", 19)
	add_child(status_label)
	dialogue = DialoguePanel.instantiate()
	add_child(dialogue)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	_begin_intermission()

func _begin_intermission() -> void:
	status_label.text = "STAGE %02d CLEAR  /  LOOP %d  /  幕間プレビュー（仮台詞）" % [stage, loop_index]
	var lines: Array[Dictionary] = [
		{"id": "PREVIEW_%02d_MU" % stage, "speaker": "ムゥ", "text": "機体の調整は終わった。次も無事に帰ってこいよ。"},
		{"id": "PREVIEW_%02d_KUU" % stage, "speaker": "クゥ", "text": "次の境界から通信が届いています。"},
		{"id": "PREVIEW_%02d_PILOTS" % stage, "speaker": "コルミィ", "text": "よーし、やるっきゃない！"}
	]
	dialogue.begin(lines)

func _on_dialogue_finished() -> void:
	stage += 1
	if stage > 7:
		stage = 1
		loop_index += 1
	status_label.text = "STAGE %02d READY  /  ENTER・A：次の幕間へ" % (stage + 1)
	# No fabricated stage 2-8 gameplay: this preview only advances the narrative.

func _unhandled_input(event: InputEvent) -> void:
	if dialogue.active or not event.is_pressed():
		return
	if event is InputEventKey and not event.is_echo() and event.keycode in [KEY_ENTER, KEY_SPACE]:
		_begin_intermission()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A:
		_begin_intermission()
		get_viewport().set_input_as_handled()

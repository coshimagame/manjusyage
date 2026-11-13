extends Control
## Stage-clear transition panel. Reusable UI, deliberately not wired to stage 2
## until that stage has actual playable content. No story canon is introduced.
signal retry_requested
signal briefing_requested
signal title_requested

var stage_number: int = 1
var stage_cleared: bool = true
var next_stage_playable: bool = false
var _message: Label
var _next: Button
var _availability: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.018, 0.024, 0.07, 0.94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.custom_minimum_size = Vector2(360, 210)
	layout.position = Vector2(140, 75)
	layout.add_theme_constant_override("separation", 12)
	add_child(layout)
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(_message)
	_availability = Label.new()
	_availability.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_availability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(_availability)
	_next = Button.new()
	_next.pressed.connect(func(): briefing_requested.emit())
	layout.add_child(_next)
	var retry := Button.new()
	retry.text = "もう一度出撃 / RETRY"
	retry.pressed.connect(func(): retry_requested.emit())
	layout.add_child(retry)
	var title := Button.new()
	title.text = "タイトルへ / TITLE"
	title.pressed.connect(func(): title_requested.emit())
	layout.add_child(title)
	_refresh()
	retry.grab_focus()

func configure(cleared_stage: int, cleared: bool, has_next_battle: bool) -> void:
	stage_number = clampi(cleared_stage, 1, 8)
	stage_cleared = cleared
	next_stage_playable = has_next_battle
	if is_node_ready():
		_refresh()

func _refresh() -> void:
	_message.text = ("STAGE %02d CLEAR" if stage_cleared else "GAME OVER") % stage_number
	var has_next_stage := stage_number < 8
	_next.disabled = not stage_cleared or not has_next_stage
	if not stage_cleared:
		_next.text = "クリア後に開放 / LOCKED"
		_availability.text = "再出撃するかタイトルへ戻れます。"
	elif not has_next_stage:
		_next.text = "最終ステージ / FINAL"
		_availability.text = "次のステージはありません。"
	elif next_stage_playable:
		_next.text = "次のブリーフィングへ / BRIEFING"
		_availability.text = "次のステージはプレイ可能です。"
	else:
		_next.text = "準備室へ / BRIEFING"
		_availability.text = "次のステージは制作中です。戦闘には進めません。"
	_next.tooltip_text = _availability.text

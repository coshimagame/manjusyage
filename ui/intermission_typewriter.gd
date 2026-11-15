extends PanelContainer
## 幕間字幕コンポーネント。既存の台詞・立ち絵・セーブは変更しない。
## add_child() 後に start_dialogue([{ "speaker": "クゥ", "text": "..." }]) を呼ぶ。
signal dialogue_finished
signal line_changed(index: int, speaker: String)

@export_range(1.0, 120.0, 1.0) var characters_per_second: float = 28.0

var _lines: Array[Dictionary] = []
var _index: int = -1
var _shown: float = 0.0
var _complete: bool = true
var _speaker_label: Label
var _text_label: Label
var _log: Array[String] = []

func _ready() -> void:
	var column := VBoxContainer.new()
	add_child(column)
	_speaker_label = Label.new()
	column.add_child(_speaker_label)
	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(480, 72)
	column.add_child(_text_label)
	visible = false
	set_process(false)

func start_dialogue(lines: Array[Dictionary]) -> void:
	_lines = lines.duplicate(true)
	_log.clear()
	_index = -1
	_complete = true
	visible = true
	_advance()
	
func _process(delta: float) -> void:
	if _complete or _index < 0:
		return
	_shown += delta * characters_per_second
	var full_text := str(_lines[_index].get("text", ""))
	_text_label.visible_characters = mini(int(_shown), full_text.length())
	if _text_label.visible_characters >= full_text.length():
		_complete = true
		set_process(false)

func advance_or_reveal() -> void:
	if not visible:
		return
	if not _complete:
		_text_label.visible_characters = -1
		_complete = true
		set_process(false)
	else:
		_advance()

func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		visible = false
		set_process(false)
		dialogue_finished.emit()
		return
	var line: Dictionary = _lines[_index]
	var speaker := str(line.get("speaker", ""))
	var message := str(line.get("text", ""))
	_speaker_label.text = speaker
	_text_label.text = message
	_text_label.visible_characters = 0
	_log.append(speaker + "： " + message)
	_shown = 0.0
	_complete = message.is_empty()
	set_process(not _complete)
	line_changed.emit(_index, speaker)

func get_dialogue_log() -> Array[String]:
	return _log.duplicate()

func get_resume_index() -> int:
	return _index

func skip_dialogue() -> void:
	if not visible:
		return
	visible = false
	set_process(false)
	dialogue_finished.emit()

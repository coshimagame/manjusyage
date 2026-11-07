extends Control
## Independent stage-clear dialogue scene. Draft lines are NOT canon.
## Call begin(completed_stage, active_pilot_names) after adding to the tree.
signal intermission_finished(next_stage: int)

const DIALOGUE := [
 {"speaker":"クゥ","text":"通信はつながっています。みんな、無事ですね。"},
 {"speaker":"コルミィ","text":"よーし！ 次も、やるっきゃない！"},
 {"speaker":"ジヨーザ","text":"機体の記録を確認してから進もう。"},
 {"speaker":"マフィオ","text":"おなかすいた！ でも、まだ飛べるよ！"},
 {"speaker":"ムゥ","text":"ほうほう……三機とも、同じ癖が出るんだな。"}
]
var stage_number: int = 1
var active_pilots: Array[String] = ["コルミィ"]
var entries: Array[Dictionary] = []
var index: int = 0
var chars: float = 0.0
var log_open: bool = false
var done: bool = false
var history: Array[String] = []
var speaker: Label
var dialogue: RichTextLabel
var hint: Label

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var background := ColorRect.new()
 background.color = Color("#101322")
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(background)
 var panel := PanelContainer.new()
 panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
 panel.offset_top = -174
 panel.offset_bottom = -16
 panel.offset_left = 20
 panel.offset_right = -20
 add_child(panel)
 var stack := VBoxContainer.new()
 panel.add_child(stack)
 speaker = Label.new()
 stack.add_child(speaker)
 dialogue = RichTextLabel.new()
 dialogue.bbcode_enabled = false
 dialogue.scroll_active = true
 dialogue.custom_minimum_size.y = 90
 stack.add_child(dialogue)
 hint = Label.new()
 hint.text = "ENTER/SPACE: NEXT    L: LOG    ESC: SKIP"
 stack.add_child(hint)
 begin(stage_number,active_pilots)

func begin(completed_stage: int, pilots: Array[String]) -> void:
 stage_number = clampi(completed_stage,1,8)
 active_pilots = pilots.duplicate()
 entries.clear()
 for entry in DIALOGUE:
  if entry.speaker in ["クゥ","ムゥ"] or entry.speaker in active_pilots:
   entries.append(entry)
 index = 0
 chars = 0.0
 history.clear()
 log_open = false
 done = false
 if is_node_ready(): _show_current(false)

func _show_current(append_history: bool) -> void:
 if done: return
 if index >= entries.size():
  _finish()
  return
 var entry: Dictionary = entries[index]
 speaker.text = str(entry.speaker)
 dialogue.text = str(entry.text)
 dialogue.visible_characters = 0
 chars = 0.0
 if append_history:
  history.append("%s: %s" % [entry.speaker,entry.text])

func _finish() -> void:
 if done: return
 done = true
 intermission_finished.emit(stage_number+1 if stage_number < 8 else 0)

func _process(delta: float) -> void:
 if log_open or done: return
 chars = minf(chars + delta*28.0,float(dialogue.get_total_character_count()))
 dialogue.visible_characters = int(chars)

func _unhandled_key_input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo or done: return
 if event.keycode == KEY_ESCAPE:
  _finish()
 elif event.keycode == KEY_L:
  log_open = not log_open
  if log_open:
   speaker.text = "会話ログ"
   dialogue.text = "\n".join(history)
   dialogue.visible_characters = -1
  else:
   _show_current(false)
 elif event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE]:
  if log_open: return
  if chars < dialogue.get_total_character_count():
   chars = float(dialogue.get_total_character_count())
   dialogue.visible_characters = -1
  else:
   index += 1
   _show_current(true)

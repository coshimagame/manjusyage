extends Control
## Standalone, non-canon stage-clear intermission prototype.
## Call begin(stage_number, player_ids) from the result screen.
signal intermission_finished(next_stage: int)
const LINES := [
 {"speaker":"クゥ","text":"通信はつながっています。みんな、無事ですね。"},
 {"speaker":"コルミィ","text":"よーし！ 次も、やるっきゃない！"},
 {"speaker":"ジヨーザ","text":"機体の記録を確認してから進もう。"},
 {"speaker":"マフィオ","text":"おなかすいた！ でも、まだ飛べるよ！"},
 {"speaker":"ムゥ","text":"ほうほう……三機とも、同じ癖が出るんだな。"}
]
var stage_number := 1
var player_ids: Array[String] = ["コルミィ"]
var line_index := 0
var visible_chars := 0.0
var full_text := ""
var history: Array[String] = []
var show_log := false
var speaker_label: Label
var dialogue_label: Label
var hint_label: Label

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var backdrop := ColorRect.new()
 backdrop.color = Color("#101322")
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(backdrop)
 var panel := PanelContainer.new()
 panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
 panel.offset_top = -155
 panel.offset_bottom = -15
 panel.offset_left = 22
 panel.offset_right = -22
 add_child(panel)
 var stack := VBoxContainer.new()
 panel.add_child(stack)
 speaker_label = Label.new()
 stack.add_child(speaker_label)
 dialogue_label = Label.new()
 dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 dialogue_label.custom_minimum_size.y = 76
 stack.add_child(dialogue_label)
 hint_label = Label.new()
 hint_label.text = "ENTER/SPACE: NEXT   L: LOG   ESC: SKIP"
 stack.add_child(hint_label)
 begin(stage_number,player_ids)

func begin(completed_stage: int, active_players: Array[String]) -> void:
 stage_number = clampi(completed_stage,1,8)
 player_ids = active_players.duplicate()
 line_index = 0
 history.clear()
 show_log = false
 if is_node_ready(): _show_line()

func _available_lines() -> Array[Dictionary]:
 var result: Array[Dictionary] = []
 for entry in LINES:
  if entry.speaker in ["クゥ","ムゥ"] or entry.speaker in player_ids:
   result.append(entry)
 return result

func _show_line() -> void:
 var lines := _available_lines()
 if line_index >= lines.size():
  intermission_finished.emit(mini(stage_number+1,8))
  return
 var line: Dictionary = lines[line_index]
 speaker_label.text = str(line.speaker)
 full_text = str(line.text)
 dialogue_label.text = full_text
 dialogue_label.visible_characters = 0
 visible_chars = 0.0
 history.append("%s: %s" % [line.speaker,line.text])

func _process(delta: float) -> void:
 if show_log: return
 visible_chars = minf(visible_chars+delta*28.0,float(full_text.length()))
 dialogue_label.visible_characters = int(visible_chars)

func _unhandled_key_input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo: return
 if event.keycode == KEY_ESCAPE:
  intermission_finished.emit(mini(stage_number+1,8))
 elif event.keycode == KEY_L:
  show_log = not show_log
  dialogue_label.visible_characters = -1
  if show_log:
   speaker_label.text = "会話ログ（再閲覧）"
   dialogue_label.text = "\n".join(history)
  else: _show_line()
 elif event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE]:
  if show_log: return
  if visible_chars < full_text.length():
   visible_chars = full_text.length()
   dialogue_label.visible_characters = -1
  else:
   line_index += 1
   _show_line()

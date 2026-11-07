extends Control
## Isolated playable flow harness: no existing game assets, saves or main scene are changed.
## Open res://scenes/intermission_vertical_slice_harness.tscn in Godot 4.6.
const INTERMISSION = preload("res://intermission_flow.tscn")
const SAVE_PATH = "user://intermission_harness_progress.cfg"
var stage: int = 1
var player_count: int = 1
var phase: String = "title"
var dialog: Control
var status: Label
var actions: VBoxContainer

func _ready() -> void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var bg := ColorRect.new()
 bg.color = Color("#101626")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(bg)
 var column := VBoxContainer.new()
 column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 column.position = Vector2(96, 48)
 column.custom_minimum_size = Vector2(448, 270)
 add_child(column)
 status = Label.new()
 status.add_theme_font_size_override("font_size", 22)
 column.add_child(status)
 actions = VBoxContainer.new()
 column.add_child(actions)
 _show_title()

func _clear_actions() -> void:
 for child in actions.get_children():
  actions.remove_child(child)
  child.queue_free()

func _button(label: String, callback: Callable) -> void:
 var b := Button.new()
 b.text = label
 actions.add_child(b)
 b.pressed.connect(callback)

func _show_title() -> void:
 phase = "title"
 status.text = "曼珠沙華 / FLOW HARNESS (DRAFT)"
 _clear_actions()
 _button("出撃 / SELECT", _show_select)
 _button("試験用セーブから再開", _load_progress)

func _show_select() -> void:
 phase = "select"
 status.text = "STAGE %02d  /  %d PLAYER(S)" % [stage, player_count]
 _clear_actions()
 _button("人数を変更 (1 → 2 → 3)", func(): player_count = player_count % 3 + 1; _show_select())
 _button("出撃", _launch)
 _button("戻る", _show_title)

func _launch() -> void:
 phase = "stage"
 status.text = "STAGE %02d / COMBAT TEST GATE" % stage
 _clear_actions()
 _button("ボス撃破を模擬（戦闘は未接続）", _result)
 _button("リトライ", _launch)
 _button("タイトル", _show_title)

func _result() -> void:
 phase = "result"
 status.text = "STAGE %02d CLEAR" % stage
 _clear_actions()
 _button("幕間会話を見る", _intermission)
 _button("セーブ", _save_progress)
 _button("リトライ", _launch)

func _intermission() -> void:
 if dialog != null: return
 phase = "intermission"
 dialog = INTERMISSION.instantiate()
 add_child(dialog)
 dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 dialog.intermission_finished.connect(_on_intermission_finished)
 var pilots: Array[String] = []
 for i in range(player_count):
  pilots.append(["コルミィ", "ジヨーザ", "マフィオ"][i])
 dialog.begin(stage, pilots)

func _on_intermission_finished(next_stage: int) -> void:
 if is_instance_valid(dialog):
  dialog.queue_free()
 dialog = null
 if next_stage == 0:
  phase = "ending"
  status.text = "ENDING / DRAFT ROUTE"
  _clear_actions()
  _button("タイトルへ", _show_title)
  return
 stage = next_stage
 phase = "next"
 status.text = "STAGE %02d READY / INTERMISSION COMPLETE" % stage
 _clear_actions()
 _button("進行状況をセーブ", _save_progress)
 _button("次のステージへ（模擬）", _launch)
 _button("タイトル", _show_title)

func _save_progress() -> void:
 var cfg := ConfigFile.new()
 cfg.set_value("harness", "stage", stage)
 cfg.set_value("harness", "players", player_count)
 var error := cfg.save(SAVE_PATH)
 if error == OK:
  status.text = "SAVED / STAGE %02d / HARNESS ONLY" % stage
 else:
  status.text = "SAVE ERROR %d" % error

func _load_progress() -> void:
 var cfg := ConfigFile.new()
 if cfg.load(SAVE_PATH) != OK:
  status.text = "NO HARNESS SAVE FOUND"
  return
 stage = clampi(int(cfg.get_value("harness", "stage", 1)), 1, 8)
 player_count = clampi(int(cfg.get_value("harness", "players", 1)), 1, 3)
 _show_select()

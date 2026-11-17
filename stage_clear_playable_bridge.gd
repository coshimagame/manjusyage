extends Control
## Isolated playable stage-clear -> control room -> next sortie smoke scene.
## Prototype dialogue is NOT canon. Existing character art is never replaced.
const PILOTS := ["コルミィ", "ジヨーザ", "マフィオ"]
var pilot_index := 0
var player_count := 1 # isolated smoke UI only; does not create combat players
var stage := 1
var phase := 0 # 0=result, 1=dialogue, 2=next sortie
var line_index := 0
var final_clear := false # stage 8 has actually been cleared, not merely reached
var lines: Array[String] = []
var heading: Label
var left_portrait: TextureRect
var right_portrait: TextureRect
var left_name: Label
var right_name: Label
var message: Label
var action: Button
var back: Button
var change_pilot: Button
var change_count: Button
var save_button: Button
var load_button: Button
const SAVE_PATH := "user://stage_bridge_smoke.cfg"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("#0a1024")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	heading = _label(Vector2(20, 12), Vector2(600, 40), 24)
	left_portrait = _portrait(Vector2(40, 68))
	right_portrait = _portrait(Vector2(460, 68))
	left_name = _label(Vector2(40, 195), Vector2(150, 25), 16)
	right_name = _label(Vector2(460, 195), Vector2(150, 25), 16)
	message = _label(Vector2(35, 225), Vector2(570, 42), 17)
	action = _button(Vector2(400, 310), "次へ", _advance)
	back = _button(Vector2(40, 310), "タイトル相当へ", _reset)
	change_pilot = _button(Vector2(240, 310), "操縦者変更", _cycle_pilot)
	change_pilot.size = Vector2(150, 38)
	change_count = _button(Vector2(420, 270), "参加人数: 1人", _cycle_count)
	change_count.size = Vector2(180, 34)
	save_button = _button(Vector2(40, 270), "試作状態を保存", _save_progress)
	save_button.size = Vector2(175, 34)
	load_button = _button(Vector2(230, 270), "試作状態を復元", _load_progress)
	load_button.size = Vector2(175, 34)
	_show_phase()

func _label(pos: Vector2, dims: Vector2, font_size: int) -> Label:
	var item := Label.new()
	item.position = pos
	item.size = dims
	item.add_theme_font_size_override("font_size", font_size)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(item)
	return item

func _portrait(pos: Vector2) -> TextureRect:
	var item := TextureRect.new()
	item.position = pos
	item.size = Vector2(140, 118)
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(item)
	return item

func _button(pos: Vector2, title: String, handler: Callable) -> Button:
	var item := Button.new()
	item.position = pos
	item.size = Vector2(200, 38)
	item.text = title
	item.pressed.connect(handler)
	add_child(item)
	return item

func _try_portrait(paths: Array[String]) -> Texture2D:
	for path in paths:
		if ResourceLoader.exists(path):
			var resource := load(path)
			if resource is Texture2D:
				return resource
	return null

func _show_phase() -> void:
	change_pilot.visible = phase == 0
	change_count.visible = phase == 0
	change_count.text = "参加人数: %d人" % player_count
	action.disabled = false
	left_name.text = PILOTS[pilot_index]
	right_name.text = "ムゥ"
	# These are optional slots. Never substitute unapproved character designs.
	left_portrait.texture = _try_portrait(["res://art/active/pilot_%d_portrait.png" % pilot_index])
	right_portrait.texture = _try_portrait(["res://art/active/mu_portrait.png"])
	left_portrait.tooltip_text = "承認済み画像がない場合は空欄"
	right_portrait.tooltip_text = "承認済み画像がない場合は空欄"
	if phase == 0:
		heading.text = "STAGE %d CLEAR" % stage
		message.text = "結果確認 → 管制室へ（操作検証用）"
		action.text = "管制室へ"
	elif phase == 1:
		heading.text = "管制室 / STAGE %d" % stage
		message.text = lines[line_index]
		action.text = "会話を進める"
	else:
		heading.text = "STAGE %d READY" % stage
		message.text = "全8面の試作進行終了。実戦シーンへの接続は未実装。" if final_clear else "次ステージ出撃準備（試作）。実戦せず次のクリアを模擬できます。"
		action.text = "試作終了" if final_clear else "次のクリアを模擬"
		action.disabled = final_clear

func _advance() -> void:
	if phase == 2 and final_clear:
		return
	if phase == 0:
		phase = 1
		line_index = 0
		lines = [
			"ムゥ：帰還を確認した。機体の状態を見せてくれ。",
			"%s：了解。次の出撃までに準備を整える。" % PILOTS[pilot_index],
			"ムゥ：次の領域へ進む前に、記録を保存しておこう。"
		]
	elif phase == 1:
		line_index += 1
		if line_index >= lines.size():
			phase = 2
			if stage == 8:
				final_clear = true
			else:
				stage += 1
	else:
		phase = 0
	_show_phase()

func _cycle_pilot() -> void:
	if phase != 0:
		return
	pilot_index = (pilot_index + 1) % PILOTS.size()
	_show_phase()

func _cycle_count() -> void:
	if phase != 0:
		return
	player_count = player_count % 3 + 1
	_show_phase()

func _reset() -> void:
	phase = 0
	stage = 1
	pilot_index = 0
	player_count = 1
	final_clear = false
	line_index = 0
	lines.clear()
	_show_phase()

func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("bridge", "version", 3)
	cfg.set_value("bridge", "player_count", player_count)
	cfg.set_value("bridge", "final_clear", final_clear)
	cfg.set_value("bridge", "stage", stage)
	cfg.set_value("bridge", "pilot", pilot_index)
	cfg.set_value("bridge", "phase", phase)
	cfg.set_value("bridge", "line", line_index)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Bridge smoke save failed: %d" % err)

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	var version := int(cfg.get_value("bridge", "version", 0))
	if version != 1 and version != 2 and version != 3:
		return
	var restored_count := int(cfg.get_value("bridge", "player_count", 1)) if version == 3 else 1
	var restored_stage := int(cfg.get_value("bridge", "stage", -1))
	var restored_pilot := int(cfg.get_value("bridge", "pilot", -1))
	var restored_phase := int(cfg.get_value("bridge", "phase", -1))
	var restored_line := int(cfg.get_value("bridge", "line", -1))
	var restored_final := bool(cfg.get_value("bridge", "final_clear", false)) if version >= 2 else false
	if restored_count < 1 or restored_count > 3 or restored_stage < 1 or restored_stage > 8 or restored_pilot < 0 or restored_pilot >= PILOTS.size() or restored_phase < 0 or restored_phase > 2:
		return
	if restored_final and (restored_stage != 8 or restored_phase != 2):
		return
	if restored_phase == 2 and restored_stage == 8 and not restored_final and version >= 2:
		return
	if restored_phase == 1 and (restored_line < 0 or restored_line >= 3):
		return
	stage = restored_stage
	player_count = restored_count
	pilot_index = restored_pilot
	phase = restored_phase
	final_clear = restored_final
	line_index = restored_line if restored_phase == 1 else 0
	lines = [
		"ムゥ：帰還を確認した。機体の状態を見せてくれ。",
		"%s：了解。次の出撃までに準備を整える。" % PILOTS[pilot_index],
		"ムゥ：次の領域へ進む前に、記録を保存しておこう。"
	] if phase == 1 else []
	_show_phase()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		_advance()
		get_viewport().set_input_as_handled()

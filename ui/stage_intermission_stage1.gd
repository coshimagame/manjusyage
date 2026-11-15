extends "res://ui/stage_intermission.gd"
## 第1面クリア後の会話データを幕間UIへ結ぶ実動作用アダプター。
## 既存game.gdの遷移は未変更。完了/スキップ信号を本編側で接続する。
const Dialogue = preload("res://ui/stage_intermission_dialogue.gd")

func setup_after_stage(cleared_stage: int, worldline: int = 1, active_players: int = 1) -> bool:
	var payload: Dictionary = Dialogue.build(cleared_stage, worldline, active_players)
	# Dictionary.get() returns an untyped Array. Copy it explicitly so Godot 4.6
	# does not reject it when this UI is launched from the real game.
	var dialogue_lines: Array[Dictionary] = []
	for line in payload.get("lines", []):
		if line is Dictionary:
			dialogue_lines.append(line)
	if dialogue_lines.is_empty():
		return false
	configure(int(payload.get("next_stage", cleared_stage + 1)), dialogue_lines)
	return true

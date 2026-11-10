extends RefCounted
## Provisional intermission dialogue catalog. NOT approved canon.
## Stable IDs allow future localization, portraits and save/log integration.
const PILOTS := ["コルミィ", "ジヨーザ", "マフィオ"]

static func lines_for(stage: int, active_pilots: Array = []) -> Array[Dictionary]:
	var safe_stage: int = clampi(stage, 1, 8)
	var lines: Array[Dictionary] = []
	lines.append(_line(safe_stage, "clear", "クゥ", "戦闘終了を確認。通信を維持します。"))
	var speakers: Array[String] = []
	for value in active_pilots:
		var name: String = str(value)
		if PILOTS.has(name) and not speakers.has(name):
			speakers.append(name)
	if speakers.is_empty():
		speakers.append("コルミィ")
	for speaker in speakers:
		match speaker:
			"コルミィ":
				lines.append(_line(safe_stage, "kolmy", speaker, "やった！　でも、まだ先があるんだよね。"))
			"ジヨーザ":
				lines.append(_line(safe_stage, "jyoza", speaker, "機体の記録を確認してから次へ進もう。"))
			"マフィオ":
				lines.append(_line(safe_stage, "mafio", speaker, "次も頑張る！　その前に何か食べたいな。"))
	lines.append(_line(safe_stage, "maintenance", "ムゥ", "機体を整備する。出撃準備を頼む。"))
	return lines

static func _line(stage: int, suffix: String, speaker: String, message: String) -> Dictionary:
	return {"id": "preview_s%02d_%s" % [stage, suffix], "speaker": speaker, "text": message, "status": "proposal"}

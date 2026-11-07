extends RefCounted
## Small, replaceable, provisional intermission micro-lines.
## These are NOT approved canon. No existing scenes or dialogue are overwritten.
## Each entry is independently addressable by ID for subtitles, logs and audio cues.

const LINES: Dictionary = {
	"micro_s01_clear_01": {"speaker": "コルミィ", "text": "やった！　でも、まだ先があるよね。", "status": "proposal"},
	"micro_s01_clear_02": {"speaker": "ジヨーザ", "text": "損傷を確認。次の区間に備えよう。", "status": "proposal"},
	"micro_s01_clear_03": {"speaker": "マフィオ", "text": "おなかすいた！　次は何が出るかな？", "status": "proposal"},
	"micro_s01_radio_01": {"speaker": "クゥ", "text": "……通信を確認。声は届いていますか。", "status": "proposal"},
	"micro_s01_hangar_01": {"speaker": "ムゥ", "text": "帰ってきたな。まず機体を見せてくれ。", "status": "proposal"},
	"micro_s01_hangar_02": {"speaker": "ムゥ", "text": "修理が終わるまで、少し休んでろ。", "status": "proposal"},
	"micro_s01_next_01": {"speaker": "ジヨーザ", "text": "進路を確認した。出撃準備に入る。", "status": "proposal"},
	"micro_s01_next_02": {"speaker": "コルミィ", "text": "よーし、次も行こう！", "status": "proposal"},
	"micro_s01_retry_01": {"speaker": "マフィオ", "text": "もう一回！　今度は負けないよ！", "status": "proposal"},
	"micro_s01_retry_02": {"speaker": "ジヨーザ", "text": "失敗の原因は記録した。再挑戦しよう。", "status": "proposal"},
	"micro_s01_save_01": {"speaker": "SYSTEM", "text": "航行記録を保存しました。", "status": "proposal"},
	"micro_s01_save_fail_01": {"speaker": "SYSTEM", "text": "保存できませんでした。空き容量を確認してください。", "status": "proposal"},
}

static func get_line(line_id: String) -> Dictionary:
	return LINES.get(line_id, {}).duplicate(true)

static func get_ids() -> PackedStringArray:
	var ids := PackedStringArray(LINES.keys())
	ids.sort()
	return ids

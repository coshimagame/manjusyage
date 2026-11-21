extends RefCounted
## 第1面クリア後の幕間台詞データ。既存UIに注入するための独立した試作。
## 台詞は未承認の仮稿。確定設定（人物名・性別・クゥの役割）と区別する。
## 外部画像・音源・セーブファイルには触れない。

const STAGE_ONE := 1
const STAGE_TWO := 2

static func build(stage: int, worldline: int = 1, active_players: int = 1) -> Dictionary:
	if stage != STAGE_ONE:
		return {"stage": stage, "next_stage": stage + 1, "lines": [], "provisional": true}
	var lines: Array[Dictionary] = [
		{"id": "S1_POST_KUU_01", "speaker": "クゥ", "text": "通信を確認。みんな、無事ね。"},
		{"id": "S1_POST_MU_01", "wrap_after": "機体の損傷を調べる。", "speaker": "ムゥ", "text": "機体の損傷を調べる。次の出撃まで少し待ってくれ。"},
		{"id": "S1_POST_KORUMII_01", "wrap_after": "まだ行けるよ！　", "speaker": "コルミィ", "text": "まだ行けるよ！　でも、整備は大事だよね。"},
		{"id": "S1_POST_JIYOZA_01", "wrap_after": "敵の動きに、", "speaker": "ジヨーザ", "text": "敵の動きに、説明のつかない規則性がある。"},
		{"id": "S1_POST_MAFIO_01", "wrap_after": "あの敵たち、", "speaker": "マフィオ", "text": "あの敵たち、何かを守っていたのかな。"},
		{"id": "S1_POST_KUU_02", "wrap_after": "答えはまだ分からない。", "speaker": "クゥ", "text": "答えはまだ分からない。でも、次も一緒に考えましょう。"}
	]
	# 選択人数で物語の主人公を削らない。単独時の残り2機はオート。
	# 周回による真相の断定は避け、短い伏線のみ試作する。
	if worldline > 1:
		lines.append({"id": "S1_POST_KUU_LOOP", "speaker": "クゥ", "text": "この通信……以前にも聞いた気がする。"})
	return {
		"stage": STAGE_ONE,
		"next_stage": STAGE_TWO,
		"worldline": maxi(worldline, 1),
		"active_players": clampi(active_players, 1, 3),
		"lines": lines,
		"provisional": true
	}

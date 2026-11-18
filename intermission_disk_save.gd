extends RefCounted
## 幕間会話の状態をディスクへ安全に保存する独立アダプター。
## 本編接続前の試作。既存セーブファイルには触れない。
const SAVE_PATH := "user://manjushage_intermission_v1.json"
const MAX_BYTES := 16384

static func save_snapshot(snapshot: Dictionary, path: String = SAVE_PATH) -> bool:
	if not validate_snapshot(snapshot):
		return false
	var payload := JSON.stringify({"version": 1, "snapshot": snapshot})
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(payload)
	file.flush()
	var ok := file.get_error() == OK
	file.close()
	return ok

static func load_snapshot(path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	if file.get_length() > MAX_BYTES:
		file.close()
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if not (parsed is Dictionary):
		return {}
	if parsed.get("version") != 1:
		return {}
	var snapshot = parsed.get("snapshot")
	if not (snapshot is Dictionary) or not validate_snapshot(snapshot):
		return {}
	return snapshot

static func validate_snapshot(snapshot: Dictionary) -> bool:
	var stage = snapshot.get("stage", -1)
	var participants = snapshot.get("participants", -1)
	var line = snapshot.get("line", -1)
	if not (stage is int) or stage < 1 or stage > 8:
		return false
	if not (participants is int) or participants < 1 or participants > 3:
		return false
	if not (line is int) or line < 0 or line > 999:
		return false
	return true

extends RefCounted
## Stage intermission dialogue cursor. No artwork or save files are modified.
## A dialogue entry is {"id": String, "speaker": String, "text": String}.
## Approved script content must be supplied by the caller; this class invents none.

const SPEAKERS = ["コルミィ", "ジヨーザ", "マフィオ", "ムゥ", "クゥ"]
var entries: Array[Dictionary] = []
var cursor: int = 0

func load_entries(source: Array) -> bool:
	var checked: Array[Dictionary] = []
	var seen: Dictionary = {}
	for raw in source:
		if not raw is Dictionary:
			return false
		var line: Dictionary = raw
		var id := str(line.get("id", ""))
		var speaker := str(line.get("speaker", ""))
		var body := str(line.get("text", ""))
		if id.is_empty() or seen.has(id) or not SPEAKERS.has(speaker) or body.strip_edges().is_empty():
			return false
		seen[id] = true
		checked.append({"id": id, "speaker": speaker, "text": body})
	entries = checked
	cursor = 0
	return true

func current() -> Dictionary:
	if cursor >= entries.size():
		return {}
	return entries[cursor].duplicate()

func advance() -> bool:
	if cursor < entries.size():
		cursor += 1
	return cursor < entries.size()

func finished() -> bool:
	return cursor >= entries.size()

func save_cursor() -> Dictionary:
	return {"line_id": str(current().get("id", "")), "index": cursor}

func restore_cursor(saved: Dictionary) -> bool:
	var id := str(saved.get("line_id", ""))
	if id.is_empty() and int(saved.get("index", -1)) == entries.size():
		cursor = entries.size()
		return true
	for i in range(entries.size()):
		if entries[i]["id"] == id:
			cursor = i
			return true
	return false

func portrait_sides() -> Dictionary:
	var speaker := str(current().get("speaker", ""))
	return {"left": speaker if speaker != "ムゥ" else "", "right": "ムゥ"}

extends RefCounted
## Pure stage-clear navigation state. Does not touch player saves or approved art.
## Call once when a boss clear is confirmed; do not call from a draw callback.
const MAX_STAGE := 8
const MAX_PLAYERS := 3

var stage := 1
var player_count := 1
var dialogue_index := 0
var dialogue_total := 0
var phase := "playing"
var cleared_stages: Array[int] = []

func configure(stage_number: int, participants: int) -> bool:
	if stage_number < 1 or stage_number > MAX_STAGE:
		return false
	if participants < 1 or participants > MAX_PLAYERS:
		return false
	stage = stage_number
	player_count = participants
	dialogue_index = 0
	dialogue_total = 0
	phase = "playing"
	# A new run must not inherit completion flags from the previous run.
	cleared_stages.clear()
	return true

func boss_defeated(lines: int) -> bool:
	if phase != "playing":
		return false
	dialogue_total = maxi(lines, 0)
	dialogue_index = 0
	phase = "dialogue" if dialogue_total > 0 else "result"
	if not cleared_stages.has(stage):
		cleared_stages.append(stage)
	return true

func advance_dialogue() -> bool:
	if phase != "dialogue":
		return false
	dialogue_index += 1
	if dialogue_index >= dialogue_total:
		phase = "result"
	return true

func next_stage() -> bool:
	if phase != "result" or stage >= MAX_STAGE:
		return false
	stage += 1
	dialogue_index = 0
	dialogue_total = 0
	phase = "playing"
	return true

func retry() -> void:
	dialogue_index = 0
	dialogue_total = 0
	phase = "playing"

func snapshot() -> Dictionary:
	return {
		"version": 1, "stage": stage, "player_count": player_count,
		"phase": phase, "dialogue_index": dialogue_index,
		"dialogue_total": dialogue_total, "cleared_stages": cleared_stages.duplicate()
	}

func restore(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != 1:
		return false
	var s := int(data.get("stage", 0))
	var n := int(data.get("player_count", 0))
	var p := str(data.get("phase", ""))
	var index := int(data.get("dialogue_index", -1))
	var total := int(data.get("dialogue_total", -1))
	if s < 1 or s > MAX_STAGE or n < 1 or n > MAX_PLAYERS:
		return false
	if not p in ["playing", "dialogue", "result"]:
		return false
	if total < 0 or index < 0 or index > total:
		return false
	if p == "dialogue" and (total == 0 or index >= total):
		return false
	var completed = data.get("cleared_stages", [])
	if not completed is Array:
		return false
	for value in completed:
		if not value is int or value < 1 or value > MAX_STAGE:
			return false
	stage = s
	player_count = n
	phase = p
	dialogue_index = index
	dialogue_total = total
	cleared_stages.clear()
	for value in completed:
		if not cleared_stages.has(value):
			cleared_stages.append(value)
	return true

extends RefCounted
## 幕間イベントの安全な選択器。台詞・画像・セーブには触れない。
## 既存の幕間シーンから pick() を呼ぶための独立部品。
const STAGE_IDS := {
	1: "MU_HANGAR_01",
	2: "MU_ANALYSIS_02",
	3: "MU_APPETITE_03",
	4: "MU_WORKSHOP_04",
	6: "MU_LOG_05",
	7: "MU_CONTROL_WARNING"
}
const ENDING_IDS := {
	1: "MU_LAST_SIGNAL_07",
	2: "MU_SURVIVED_09"
}

static func pick(cleared_stage: int, run_index: int, cleared: bool = true) -> Dictionary:
	if not cleared or cleared_stage < 1 or cleared_stage > 8 or run_index < 1:
		return {}
	if cleared_stage == 8:
		if ENDING_IDS.has(run_index):
			return {"event_id": ENDING_IDS[run_index], "stage": 8, "run_index": run_index, "status": "draft_dialogue"}
		return {"event_id": "MU_FUTURE_10", "stage": 8, "run_index": run_index, "status": "proposal"}
	if STAGE_IDS.has(cleared_stage):
		return {"event_id": STAGE_IDS[cleared_stage], "stage": cleared_stage, "run_index": run_index, "status": "draft_dialogue"}
	return {}

static func should_advance_after(event_id: String) -> bool:
	# 最終面の後は次面へ進めない。エンディング/周回処理へ委譲する。
	return not event_id.begins_with("MU_LAST_SIGNAL") and not event_id.begins_with("MU_SURVIVED") and event_id != "MU_FUTURE_10"

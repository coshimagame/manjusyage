extends RefCounted
# BRIEFING-001: stage availability and Mu-invention milestones.
# Do not confuse narrative stage availability with playable stage content.
const SAVE_PATH="user://briefing_progress.cfg"
var save_path: String=SAVE_PATH # Override in isolated tests.
const MAX_STAGES=8
const PLAYABLE_STAGES=[1,2]
const NAMES=[
	"赤い残響",
	"追憶の海（仮）",
	"孤独な庭（仮）",
	"分岐する空（仮）",
	"忘却の要塞（仮）",
	"白い彼岸（仮）",
	"輪廻の終点（仮）",
	"曼珠沙華（仮）"
]
const INVENTIONS={
	"mafio":{"stage":4,"name":"ごちそうさま図鑑"},
	"jiyoza":{"stage":5,"name":"解析履歴"},
	"cormii":{"stage":6,"name":"ツイてる日記"}
}
# These stages are a prototype design, not final canon for boss mechanics.
var highest_unlocked=1
var cleared: Dictionary={}

func load_data():
	highest_unlocked=1
	cleared.clear()
	var cfg=ConfigFile.new()
	if cfg.load(save_path)!=OK: return
	highest_unlocked=clampi(int(cfg.get_value("stage","highest_unlocked",1)),1,MAX_STAGES)
	for i in range(1,MAX_STAGES+1):
		cleared[i]=bool(cfg.get_value("cleared",str(i),false))
	# Recover missing/unreliable index from cleared flags.
	for i in range(1,MAX_STAGES):
		if bool(cleared.get(i,false)): highest_unlocked=maxi(highest_unlocked,i+1)

func save_data() -> int:
	var cfg=ConfigFile.new()
	cfg.set_value("stage","highest_unlocked",highest_unlocked)
	for i in range(1,MAX_STAGES+1):
		cfg.set_value("cleared",str(i),bool(cleared.get(i,false)))
	return cfg.save(save_path)

func mark_cleared(stage: int):
	if stage<1 or stage>MAX_STAGES: return
	cleared[stage]=true
	highest_unlocked=maxi(highest_unlocked,mini(MAX_STAGES,stage+1))
	save_data()

func can_select(stage: int) -> bool:
	return stage>=1 and stage<=highest_unlocked

func has_gameplay(stage: int) -> bool:
	return PLAYABLE_STAGES.has(stage)

func can_launch(stage: int) -> bool:
	return can_select(stage) and has_gameplay(stage)

func feature_available(key: String) -> bool:
	return INVENTIONS.has(key) and highest_unlocked>=int(INVENTIONS[key]["stage"])

func next_briefing_stage() -> int:
	# Stage 1 is never preceded by a briefing on first contact.
	return mini(MAX_STAGES,maxi(2,highest_unlocked))

func stage_name(stage: int) -> String:
	return NAMES[clampi(stage,1,MAX_STAGES)-1]

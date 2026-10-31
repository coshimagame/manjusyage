extends RefCounted
# JIYOZA-ANALYSIS-001: An enemy pattern must be encountered before
# it can be destroyed with Special Analysis. Bosses cannot be studied
# or destroyed using the screen clear; boss bullets are excluded too.
# Data is separate from Mafio's capture archive.
const SAVE_PATH="user://jiyoza_enemy_analysis.cfg"
var observed: Dictionary={}

func load_data():
	observed.clear()
	var cfg=ConfigFile.new()
	if cfg.load(SAVE_PATH)!=OK: return
	for key in cfg.get_section_keys("observed") if cfg.has_section("observed") else []:
		observed[str(key)]=bool(cfg.get_value("observed",str(key),false))

func save_data() -> int:
	var cfg=ConfigFile.new()
	for key in observed:
		cfg.set_value("observed",str(key),bool(observed[key]))
	return cfg.save(SAVE_PATH)

func previously_observed(enemy_id: String) -> bool:
	return bool(observed.get(enemy_id,false))

func record_encounter(enemy_id: String):
	if enemy_id=="" or enemy_id=="boss" or previously_observed(enemy_id): return
	observed[enemy_id]=true
	save_data()

func mark_new_group(group: Array, enemy_id: String):
	# Snapshot BEFORE this group is observed: first-ever wave stays immune.
	var eligible=previously_observed(enemy_id)
	for enemy in group:
		enemy["analysis_id"]=enemy_id
		enemy["analysis_eligible"]=eligible
	record_encounter(enemy_id)

func count_observed() -> int:
	return observed.size()

extends RefCounted
# STATUS-JOURNAL-002 — player accomplishments, independent of health and scores.
# No mission objectives, hitbox, or campaign flags depend on these statistics.
const SAVE_PATH="user://pilot_journals.cfg"
const LIMIT=12
var fortunes: Array=[]
var chance_counts: Dictionary={"low":0,"normal":0,"jackpot":0}
var enemy_seen: Dictionary={}
var enemy_scanned: Dictionary={}

func load_data():
	var cfg=ConfigFile.new()
	if cfg.load(SAVE_PATH)!=OK: return
	for grade in chance_counts.keys():
		chance_counts[grade]=maxi(0,int(cfg.get_value("luck",str(grade),0)))
	var saved=cfg.get_value("luck","recent",[])
	if saved is Array: fortunes=saved.slice(maxi(0,saved.size()-LIMIT))
	var seen=cfg.get_value("analysis","seen",{})
	var scanned=cfg.get_value("analysis","scanned",{})
	if seen is Dictionary: enemy_seen=seen
	if scanned is Dictionary: enemy_scanned=scanned

func save_data():
	var cfg=ConfigFile.new()
	for grade in chance_counts.keys():
		cfg.set_value("luck",str(grade),chance_counts[grade])
	cfg.set_value("luck","recent",fortunes)
	cfg.set_value("analysis","seen",enemy_seen)
	cfg.set_value("analysis","scanned",enemy_scanned)
	return cfg.save(SAVE_PATH)

func record_fortune(grade:String,power:float,stability:int):
	if not chance_counts.has(grade): return
	chance_counts[grade]=int(chance_counts[grade])+1
	fortunes.append({"grade":grade,"power":snappedf(power,.01),"stability":stability})
	if fortunes.size()>LIMIT: fortunes.pop_front()
	if total_fortunes()%20==0: save_data()

func total_fortunes()->int:
	var total=0
	for val in chance_counts.values(): total+=int(val)
	return total

func record_seen(id:String):
	if id.is_empty(): return
	enemy_seen[id]=mini(99999,int(enemy_seen.get(id,0))+1)
	if int(enemy_seen[id])%20==0:save_data()

func record_scan(id:String):
	if id.is_empty(): return
	enemy_scanned[id]=mini(99999,int(enemy_scanned.get(id,0))+1)
	save_data()

func has_seen(id:String)->bool:
	return int(enemy_seen.get(id,0))>0
func has_scanned(id:String)->bool:
	return int(enemy_scanned.get(id,0))>0

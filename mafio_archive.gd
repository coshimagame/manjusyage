extends RefCounted
# MAFIO-ARCHIVE-001 / Original enemy-eating encyclopedia, prototype v0.1.
# Names are tentative art concepts. Only P-001/P-002 are playable today.
# Save is separate from achievements, profiles and existing score files.
const SAVE_PATH="user://mafio_archive.cfg"
const ENTRIES=[
	{"id":"P-001","name":"試作・狙撃機","source":"現行試作","attack":"直線的な狙い撃ち","technique":"aimed","ability":"狙いを定める弾","type":"mechanical"},
	{"id":"P-002","name":"試作・散華機","source":"現行試作","attack":"広がる三連弾","technique":"fan","ability":"扇状の三連弾","type":"organic"},
	{"id":"E-102","name":"縫合蜂","source":"1面・案","attack":"貫通針","technique":"pierce","ability":"貫通ニードル","type":"organic"},
	{"id":"E-103","name":"器官砲台","source":"1面・案","attack":"脈動追尾弾","technique":"pulse","ability":"鼓動追尾弾","type":"organic"},
	{"id":"E-201","name":"追憶魚","source":"2面・案","attack":"曲線弾","technique":"curve","ability":"記憶曲線弾","type":"organic"},
	{"id":"E-203","name":"声写し","source":"2面・案","attack":"時差弾","technique":"delay","ability":"遅延反響弾","type":"memory"},
	{"id":"E-301","name":"花守","source":"3面・案","attack":"花弁の扇","technique":"petal","ability":"散華扇","type":"organic"},
	{"id":"E-303","name":"種子運び","source":"3面・案","attack":"種子の分裂弾","technique":"seed","ability":"種子分裂弾","type":"organic"},
	{"id":"E-401","name":"位相鳥","source":"4面・案","attack":"位相をずらす弾","technique":"phase","ability":"位相跳躍弾","type":"phase"},
	{"id":"E-403","name":"境界縫い","source":"4面・案","attack":"折れ曲がる針","technique":"bend","ability":"屈折針弾","type":"phase"},
	{"id":"E-501","name":"記録兵","source":"5面・案","attack":"予測狙撃","technique":"predict","ability":"予測レール","type":"mechanical"},
	{"id":"E-503","name":"再演ドローン","source":"5面・案","attack":"攻撃の反復","technique":"echo","ability":"反復射撃","type":"mechanical"},
	{"id":"E-601","name":"白花灯","source":"6面・案","attack":"ゆっくり放射光","technique":"halo","ability":"守りの放射光","type":"memory"},
	{"id":"E-603","name":"守灯機","source":"6面・案","attack":"細長い光線","technique":"beam","ability":"細光レーザー","type":"mechanical"},
	{"id":"E-701","name":"帰還兵","source":"7面・案","attack":"ブーメラン弾","technique":"boomerang","ability":"帰還刃","type":"mechanical"},
	{"id":"E-703","name":"逆行監視機","source":"7面・案","attack":"引き返す弾","technique":"return","ability":"逆行リターン","type":"phase"},
	{"id":"E-801","name":"調停小機","source":"8面・案","attack":"三法則の同期","technique":"sync","ability":"同期光弾","type":"phase"},
	{"id":"E-802","name":"誓約盾","source":"8面・案","attack":"花弁防壁","technique":"shield","ability":"護りの花弁","type":"memory"}
]
var captured: Dictionary={}

func load_data():
	captured.clear()
	var cfg=ConfigFile.new()
	if cfg.load(SAVE_PATH)!=OK: return
	for entry in ENTRIES:
		var id: String=entry["id"]
		captured[id]=maxi(0,int(cfg.get_value("captured",id,0)))

func save_data():
	var cfg=ConfigFile.new()
	for key in captured:
		cfg.set_value("captured",str(key),int(captured[key]))
	return cfg.save(SAVE_PATH)

func capture(enemy: Dictionary):
	var kind: String=str(enemy.get("technique","aimed"))
	var id: String=str(enemy.get("archive_id","P-002" if kind=="fan" else "P-001"))
	if entry_for(id).is_empty(): return
	captured[id]=mini(9999,int(captured.get(id,0))+1)
	save_data()

func entry_for(id: String) -> Dictionary:
	for entry in ENTRIES:
		if str(entry["id"])==id: return entry
	return {}

func unlocked(id: String) -> bool:
	return int(captured.get(id,0))>0

func total_unlocked() -> int:
	var amount=0
	for entry in ENTRIES:
		if unlocked(str(entry["id"])): amount+=1
	return amount

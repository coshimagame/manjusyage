extends RefCounted

# MAFIO-ARCHIVE-001 — 捕食した実在敵だけを記録する、既存セーブと独立した図鑑。
# 後半ステージ由来の項目は将来案であり、未出現の敵を解放しない。
const SAVE_PATH="user://mafio_archive.cfg"
const ENTRIES=[
	{"id":"P-001","name":"生体・照準体","source":"赤い残響","attack":"直線的な狙い撃ち","technique":"aimed","ability":"照準弾"},
	{"id":"P-002","name":"散華器官","source":"赤い残響","attack":"広がる三連弾","technique":"fan","ability":"散華三連"},
	{"id":"P-003","name":"縫い合わせ体","source":"赤い残響","attack":"蛇行弾","technique":"weave","ability":"蛇行弾"},
	{"id":"P-004","name":"急降下胞子","source":"赤い残響","attack":"急降下弾","technique":"dive","ability":"急降下弾"},
	{"id":"P-005","name":"環状記憶体","source":"赤い残響","attack":"周回弾","technique":"orbit","ability":"環状弾"},
	{"id":"E-301","name":"花守","source":"3面・案","attack":"花弁の扇","technique":"petal","ability":"散華扇"},
	{"id":"E-303","name":"種子運び","source":"3面・案","attack":"種子の分裂弾","technique":"seed","ability":"種子分裂弾"},
	{"id":"E-601","name":"白花灯","source":"6面・案","attack":"ゆっくり放射光","technique":"halo","ability":"守りの放射光"},
	{"id":"E-603","name":"守灯機","source":"6面・案","attack":"細長い光線","technique":"beam","ability":"細光レーザー"},
	{"id":"E-102","name":"縫合蜂","source":"1面・案","attack":"貫通針","technique":"pierce","ability":"貫通ニードル"}
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
	var id="P-001"
	for entry in ENTRIES:
		if str(entry["technique"])==kind:
			id=str(entry["id"])
			break
	captured[id]=mini(9999,int(captured.get(id,0))+1)
	save_data()

func unlocked(id: String) -> bool:
	return int(captured.get(id,0))>0

func total_unlocked() -> int:
	var amount=0
	for entry in ENTRIES:
		if unlocked(str(entry["id"])): amount+=1
	return amount

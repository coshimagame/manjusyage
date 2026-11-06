extends RefCounted
# Enemy roster: data-driven proposals. Stage 1 is playable; later stage entries
# are content definitions, not claims that their levels are playable.
const ROSTER={
1:{"small":[{"id":"pulse_mite","name":"脈虫","move":"sine","shot":"aimed","hp":3,"speed":70},{"id":"wall_larva","name":"壁這い","move":"zigzag","shot":"fan","hp":4,"speed":58},{"id":"red_scout","name":"赤い偵察体","move":"dive","shot":"aimed","hp":3,"speed":82}],"mid":{"id":"artery_gate","name":"動脈門","move":"anchor","shot":"fan","hp":55,"speed":0}},
2:{"small":[{"id":"memory_fish","name":"記憶魚","move":"school","shot":"aimed","hp":3,"speed":80},{"id":"jelly_archive","name":"浮遊記録体","move":"sine","shot":"fan","hp":4,"speed":42},{"id":"pressure_eel","name":"水圧鰻","move":"dive","shot":"aimed","hp":5,"speed":95}],"mid":{"id":"tidal_recorder","name":"潮汐記録塔","move":"anchor","shot":"fan","hp":70,"speed":0}},
3:{"small":[{"id":"root_drill","name":"根穿ち","move":"zigzag","shot":"aimed","hp":4,"speed":66},{"id":"spore_bloom","name":"胞子花","move":"sine","shot":"fan","hp":3,"speed":48},{"id":"vine_hunter","name":"蔓猟兵","move":"dive","shot":"aimed","hp":5,"speed":90}],"mid":{"id":"garden_keeper","name":"庭守りの大輪","move":"anchor","shot":"fan","hp":75,"speed":0}},
4:{"small":[{"id":"wing_shard","name":"翼片","move":"zigzag","shot":"aimed","hp":3,"speed":100},{"id":"turbine_eye","name":"風車眼","move":"sine","shot":"fan","hp":5,"speed":55},{"id":"courier","name":"空路運搬体","move":"school","shot":"aimed","hp":4,"speed":80}],"mid":{"id":"sky_switch","name":"分岐機関","move":"anchor","shot":"fan","hp":80,"speed":0}},
5:{"small":[{"id":"erase_bit","name":"消去子","move":"zigzag","shot":"fan","hp":4,"speed":72},{"id":"screen_ghost","name":"残像映写機","move":"sine","shot":"aimed","hp":3,"speed":65},{"id":"lock_guard","name":"記録番","move":"school","shot":"aimed","hp":5,"speed":68}],"mid":{"id":"archive_lock","name":"忘却封印器","move":"anchor","shot":"fan","hp":85,"speed":0}},
6:{"small":[{"id":"glass_wisp","name":"硝子の灯","move":"sine","shot":"aimed","hp":3,"speed":60},{"id":"dream_mirror","name":"夢鏡","move":"zigzag","shot":"fan","hp":5,"speed":62},{"id":"transfer_ray","name":"転移光線体","move":"dive","shot":"aimed","hp":4,"speed":90}],"mid":{"id":"white_chamber","name":"白い転移室","move":"anchor","shot":"fan","hp":90,"speed":0}},
7:{"small":[{"id":"split_ring","name":"分岐環","move":"sine","shot":"fan","hp":5,"speed":74},{"id":"echo_twin","name":"残響双体","move":"school","shot":"aimed","hp":4,"speed":85},{"id":"phase_needle","name":"位相針","move":"dive","shot":"aimed","hp":4,"speed":100}],"mid":{"id":"overlap_relay","name":"重界中継核","move":"anchor","shot":"fan","hp":100,"speed":0}},
8:{"small":[{"id":"petal_blade","name":"花弁刃","move":"zigzag","shot":"aimed","hp":5,"speed":95},{"id":"seed_orb","name":"種子球","move":"sine","shot":"fan","hp":6,"speed":68},{"id":"core_guard","name":"中枢護衛","move":"school","shot":"fan","hp":7,"speed":78}],"mid":{"id":"lily_heart","name":"彼岸の心房","move":"anchor","shot":"fan","hp":110,"speed":0}}
}
static func small(stage:int, index:int) -> Dictionary:
 var entries:Array=ROSTER[clampi(stage,1,8)]["small"]
 return entries[posmod(index,entries.size())].duplicate(true)
static func mid(stage:int) -> Dictionary:
 return ROSTER[clampi(stage,1,8)]["mid"].duplicate(true)
static func motion(enemy:Dictionary, dt:float, target:Vector2) -> void:
 enemy.age+=dt
 var movement=str(enemy.get("move","sine"))
 var age=float(enemy.age)
 var speed=float(enemy.get("speed",60.0))
 if movement=="anchor":
  enemy.pos.x=lerpf(float(enemy.pos.x),475.0,minf(1.0,dt*2.0))
  enemy.pos.y=180.0+sin(age*.8)*46.0
 elif movement=="zigzag":
  enemy.pos.x-=speed*dt
  enemy.pos.y=float(enemy.base)+sin(age*4.5+float(enemy.phase))*34.0
 elif movement=="dive":
  enemy.pos.x-=speed*dt
  enemy.pos.y=lerpf(float(enemy.pos.y),float(target.y),minf(1.0,dt*.8))
 elif movement=="school":
  enemy.pos.x-=speed*dt
  enemy.pos.y=float(enemy.base)+sin(age*2.8+float(enemy.phase))*15.0
 else:
  enemy.pos.x-=speed*dt
  enemy.pos.y=float(enemy.base)+sin(age*2.3+float(enemy.phase))*float(enemy.get("amplitude",23.0))

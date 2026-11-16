extends SceneTree

# STATUS-001 regression: the status overlay must pause safely and never alter
# player selection, HP, or captured-save contents merely by opening it.
func _initialize(): run.call_deferred()

func key(code):
	var event=InputEventKey.new()
	event.physical_keycode=code
	event.pressed=true
	return event

func run():
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.count=3
	g.pilot_offset=0
	g.start_game()
	var hp_before=g.players[0].hp
	g._input(key(KEY_TAB))
	assert(g.mode=="status","TAB must open the pilot status overlay")
	assert(g.status_slot==0 and not g.archive_page)
	g._input(key(KEY_RIGHT))
	assert(g.status_slot==1,"Status navigation must preserve the selected pilot")
	assert(g.pilot_portraits.size()==3 and g.pilot_portraits.all(func(p): return p != null),"All three status portraits must load from the transparent pilot sprite set")
	assert(g.status_frame_modules(0).size()==3 and g.status_frame_modules(1).size()==3 and g.status_frame_modules(2).size()==3,"Each pilot needs three visible prototype frame modules")
	assert(g.status_frame_modules(0)[0]!=g.status_frame_modules(1)[0] and g.status_frame_modules(1)[0]!=g.status_frame_modules(2)[0],"Frame loadouts must visually distinguish the shared-base fighters")
	g._input(key(KEY_TAB))
	assert(g.mode=="play" and g.players[0].hp==hp_before,"Status must return without changing combat state")
	g.mode="pause"
	g._input(key(KEY_TAB))
	assert(g.mode=="status" and g.status_return_mode=="pause")
	g._input(key(KEY_ESCAPE))
	assert(g.mode=="pause")
	var mafio=g.players.filter(func(p): return p.character==2)[0]
	mafio.learned="petal"
	assert(g.Abilities.velocities(mafio,Vector2.RIGHT,[]).size()==5,"Petal capture must create a five-shot pattern")
	mafio.learned="weave"
	assert(g.Abilities.velocities(mafio,Vector2.RIGHT,[]).size()==2,"Existing weave organism must create a paired shot")
	mafio.learned="beam"
	assert(g.Abilities.velocities(mafio,Vector2.RIGHT,[])[0].length()==520.0,"Beam capture must retain its tuned projectile speed")
	mafio.digest_total=1.2
	mafio.digest=.58
	mafio.pending_technique="petal"
	assert(int(round((1.0-mafio.digest/mafio.digest_total)*100.0))==52,"Digest display must use live remaining digestion data")
	g.mafio_archive.captured={"P-002":1}
	assert(g.mafio_archive.total_unlocked()==1,"Archive total must derive only from captured records")
	g.queue_free()
	await process_frame
	print("STATUS V09 PASS: pause-safe status, pilot navigation, capture patterns, archive read")
	quit()

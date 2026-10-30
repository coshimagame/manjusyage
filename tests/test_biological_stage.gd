extends SceneTree

func _initialize(): run.call_deferred()

func run():
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.bio_route=true
	g.start_game()
	g.travel=750
	g.players[0].pos=Vector2(200,50)
	g.players[0].inv=0
	g.bio.update(g,.016)
	assert(g.players[0].hp==3,"Living wall must cause damage")
	g.bio.update(g,.016)
	assert(g.players[0].hp==3,"Invulnerability must prevent repeated contact damage")
	assert(g.bio.organs.size()==1)
	var organ=g.bio.organs[0]
	organ.pos=Vector2(400,100); organ.hp=1
	g.bullets.append({"pos":organ.pos,"color":0,"owner":0})
	g.bio.update(g,.016)
	assert(g.bio.organs.is_empty() and g.pickups.size()==1,"Destroyable organ drops energy")
	g.begin_boss()
	assert(not g.bio.exposed())
	var hp=g.boss.hp
	g.bullets=[{"pos":g.boss.pos-Vector2(1,0),"color":g.boss.color,"owner":0}]
	g.update_game(.001)
	assert(g.boss.hp==hp,"Core must stay protected until both armor parts break")
	for part in range(2): g.bio.damage_part(g,part,100)
	assert(g.bio.exposed())
	g.bullets=[{"pos":g.boss.pos-Vector2(1,0),"color":g.boss.color,"owner":0}]
	g.update_game(.001)
	assert(g.boss.hp==hp-1)
	g.start_game()
	assert(g.bio.armor.is_empty() and g.bio.organs.is_empty(),"Retry must reset biological state")
	g.queue_free()
	await process_frame
	print("BIO PASS: wall damage/invulnerability, organ destruction, protected core, two-part break, retry reset")
	quit()

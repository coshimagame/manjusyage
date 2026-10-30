extends SceneTree

func _initialize(): run.call_deferred()

func run():
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.bio_route=true;g.count=3;g.pilot_offset=1;g.start_game()
	assert(g.players.map(func(p):return p.character)==[1,2,0])
	var k=g.players[2]
	var early_peak=g.Abilities.damage(k,0)
	var early_gap=early_peak-g.Abilities.damage(k,2)
	k.experience=24
	assert(g.Abilities.damage(k,0)>early_peak)
	assert(g.Abilities.damage(k,0)-g.Abilities.damage(k,2)<early_gap)
	var j=g.players[0];j.experience=24
	assert(g.Abilities.damage(j,0)>g.Abilities.damage(k,0))
	var m=g.players[1]
	g.enemies=[{"pos":m.pos+Vector2(30,0),"hp":2,"technique":"fan"}]
	assert(g.Abilities.eat(g,m))
	assert(m.learned=="none")
	g.Abilities.digest(m,1.3)
	assert(m.learned=="fan" and g.Abilities.velocities(m,Vector2.UP,[]).size()==3)
	g.vertical.begin(g)
	assert(g.vertical.active and g.shots.is_empty())
	g.vertical.update(g,2.1)
	g.vertical.update(g,.1)
	assert(not g.enemies.is_empty())
	g.shots.append({"pos":Vector2(10,10),"vel":Vector2.ZERO,"r":3})
	g.vertical.update(g,20.1)
	assert(g.shots.is_empty())
	g.vertical.update(g,2)
	assert(g.vertical.done and not g.vertical.active and g.travel==3700)
	g.start_game()
	assert(not g.vertical.done and g.players[0].experience==0)
	g.new_music=true;g.start_game()
	assert(g.music_name=="wistful_demo" and g.music.stream.get_length()>51)
	g.queue_free()
	await process_frame
	print("SETTINGS PASS: solo-select order, growth curves, digest/copied fan, vertical transition and clearing, retry, new music")
	quit()

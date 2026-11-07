extends SceneTree
# Current character rules regression. Run in a test-only Godot user profile.
func _initialize(): run.call_deferred()

func run():
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	g.bio_route=true
	g.count=3
	g.pilot_offset=1
	g.start_game()
	assert(g.players.map(func(p):return p.character)==[1,2,0])

	# Cormii: fortune is rerolled, not a permanent stability upgrade.
	var k=g.players[2]
	assert(k.luck==50)
	var previous=g.Abilities.draw_omikuji(k,90)
	assert(previous.after==90 and k.luck==90)
	var lucky_chance=g.Abilities.chance_profile(k,.70)
	assert(lucky_chance.grade=="jackpot")
	previous=g.Abilities.draw_omikuji(k,20)
	assert(previous.before==90 and previous.after==20)
	assert(g.Abilities.chance_profile(k,.70).grade=="normal")
	var old_luck=k.luck
	g.Abilities.consume_charged_luck(k)
	assert(k.luck==old_luck-8)
	assert(g.Abilities.damage(k,0.0,.5)>0.0)

	# Jiyoza grows progressively; scan is separate from the usual charge.
	var j=g.players[0]
	var low_output=g.Abilities.damage(j,0.0)
	j.experience=24
	assert(g.Abilities.damage(j,0.0)>low_output)
	assert(j.analysis_charge==0 and j.analysis_uses==0)

	# Mafio equips immediately, then digestion restores regular fire.
	var m=g.players[1]
	g.enemies=[{"pos":m.pos+Vector2(30,0),"hp":2,"technique":"fan"}]
	assert(g.Abilities.eat(g,m))
	assert(m.learned=="fan")
	assert(m.digest>0)
	assert(g.Abilities.velocities(m,Vector2.UP,[]).size()==3)
	g.Abilities.digest(m,m.digest_total+.1)
	assert(m.learned=="none" and m.digest<=0)
	assert(g.Abilities.velocities(m,Vector2.UP,[]).size()==1)

	# Mixed scroll still transitions and resets on a new stage attempt.
	g.vertical.begin(g)
	assert(g.vertical.active and g.shots.is_empty())
	g.vertical.update(g,2.1)
	g.vertical.update(g,.1)
	assert(not g.enemies.is_empty())
	g.shots.append({"pos":Vector2(10,10),"vel":Vector2.ZERO,"r":3})
	g.vertical.update(g,20.1)
	assert(g.shots.is_empty())
	g.vertical.update(g,2.0)
	assert(g.vertical.done and not g.vertical.active and g.travel==3700)
	g.start_game()
	assert(not g.vertical.done and g.players[0].experience==0)

	g.new_music=true
	g.start_game()
	# The current default is the generated ambient stream; F8 retains the ruins
	# fallback.  Keep the test aligned with the actual selectable music path.
	assert(g.music_name=="ambient_stage")
	assert(g.music.stream is AudioStreamWAV and g.music.stream.loop_end>160000)
	g.queue_free()
	await process_frame
	print("SETTINGS PASS: character order, fortune rerolls, Jiyoza growth, Mafio temporary digestion, vertical stage and music")
	quit(0)

extends SceneTree
func _initialize():run.call_deferred()
func run():
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.set_process(false)
	assert(g.art_v09 and g.slice_mode)
	g.count=3;g.start_game()
	assert(g.music_name=="bgm_stage01_plan_a" and absf(g.music.stream.get_length()-49.23)<.05)
	assert(g.music.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD)
	assert(g.vertical.duration==12)
	var prior=g.high_scores.duplicate()
	g.score=999999;g.finish(true)
	assert(g.high_scores==prior,"Short-slice score must not overwrite original route records")
	var record=JSON.parse_string(FileAccess.get_file_as_string("user://last_run.json"))
	assert(record.ruleset=="red-echo-slice-v09")
	g.start_game();g.elapsed=54.99;g.vertical.done=true
	g.update_game(.02)
	assert(not g.boss.is_empty() and g.music_name=="bgm_boss01_plan_a")
	g.boss.hp=0;g.update_game(.02)
	assert(g.aftermath>0 and g.mode=="play" and g.shots.is_empty())
	g.update_game(3.1)
	assert(g.mode=="clear")
	# Stage clear must open the provisional story overlay without starting a
	# second run; completing or skipping it continues the same party into the sea.
	g.open_stage1_intermission()
	assert(g.mode=="intermission")
	var overlay: Control = g.get_child(g.get_child_count()-1)
	overlay._complete(true)
	assert(g.mode=="play" and g.stage_number==2)
	g.start_game()
	assert(g.aftermath==0 and g.visual.blasts.is_empty())
	var horizontal_names := ["cormii_muu_v02_h.png", "jiyoza_muu_v02_h.png", "mafio_gold_black_v03_h.png"]
	var vertical_names := ["cormii_muu_v02_v.png", "jiyoza_muu_v02_v.png", "mafio_gold_black_v02.png"]
	assert(g.visual.ship_variants.size()==3 and g.visual.vertical_ship_variants.size()==3)
	for i in range(3):
		var horizontal: AtlasTexture = g.visual.ship_variants[i]
		var vertical: AtlasTexture = g.visual.vertical_ship_variants[i]
		assert(horizontal != null and horizontal.atlas.resource_path == "res://art/active/ships/"+horizontal_names[i])
		assert(vertical != null and vertical.atlas.resource_path == "res://art/active/ships/"+vertical_names[i])
	assert(g.visual.item_hp_texture!=null and g.visual.item_energy_texture!=null)
	assert(g.visual.bullet_petal_texture!=null and g.visual.bullet_needle_texture!=null)
	assert(g.visual.bullet_flower_ring_texture!=null and g.visual.bullet_target_eye_texture!=null)
	assert(g.visual.defeat_petals_texture!=null and g.visual.hit_flash_texture!=null and g.visual.pickup_pillar_texture!=null)
	assert(g.visual.stage1_enemy_h.size()==12 and g.visual.stage1_enemy_v.size()==12)
	for art_id in ["EN001","EN002","EN003","EN004","EN005","EN006","EN007","EN008","EN009","MB01","SB01","BB01"]:
		assert(g.visual.stage1_enemy_texture(art_id,false)!=null)
		assert(g.visual.stage1_enemy_texture(art_id,true)!=null)
	# Pickup styling is presentation-only: both existing item effects and their
	# collision radius stay intact while the v0.9 collector bloom is emitted.
	g.players[0].hp=3
	g.pickups=[{"pos":g.players[0].pos,"kind":0}]
	g.update_game(.01)
	assert(g.players[0].hp==4 and not g.visual.collects.is_empty())
	g.players[0].charge=54
	g.pickups=[{"pos":g.players[0].pos,"kind":1}]
	g.update_game(.01)
	assert(absf(g.players[0].charge-79.02)<.01 and g.pickups.is_empty())
	assert(g.visual.collects.back().kind==1)
	g.visual.hit(Vector2(200,180))
	g.visual.confirm(Vector2(200,180),1)
	g.start_game()
	assert(g.visual.hits.is_empty() and g.visual.confirms.is_empty() and g.visual.collects.is_empty())
	g.travel=3100
	g.vertical.begin(g);g.vertical.age=3;g.vertical.spawn=0
	g.vertical.update(g,.01)
	for enemy in g.enemies: enemy.cool=0
	g.vertical.update(g,.01)
	assert(not g.shots.is_empty() and g.shots[0].form=="needle")
	g.start_game()
	g.enemies.clear();g.wave_id=0;g.spawn_wave()
	var forms={}
	for enemy in g.enemies: forms[enemy.technique]=true
	assert(forms.size()>=3,"0.9 wave needs mixed readable movement forms")
	var stage1_art={}
	var stage1_variants={}
	for wave in range(6):
		g.enemies.clear();g.spawn_wave()
		for enemy in g.enemies:
			stage1_art[enemy.art_id]=true
			if str(enemy.art_id)!="": stage1_variants[enemy.art_id]=enemy
	for art_id in ["EN001","EN002","EN003","EN004","EN005","EN006","EN007","EN008","EN009","MB01","SB01"]:
		assert(stage1_art.has(art_id),"Stage 1 should schedule user-provided "+art_id+" art")
	var motions={}
	var shot_forms={}
	var display_scales={}
	var scheduled_volley_total=0
	var cascade_profiles=0
	for art_id in ["EN001","EN002","EN003","EN004","EN005","EN006","EN007","EN008","EN009","MB01","SB01"]:
		var variant=stage1_variants[art_id]
		assert(variant.has("motion") and variant.has("shot_form") and variant.has("shot_offsets"))
		assert(variant.shot_offsets.size()>0 and variant.shot_speed>0 and variant.hit_radius>0 and variant.volley_count>0)
		motions[variant.motion]=true
		shot_forms[variant.shot_form]=true
		display_scales[str(variant.scale)]=true
		scheduled_volley_total+=variant.shot_offsets.size()*variant.volley_count
		if variant.volley_count>1 and variant.volley_gap>0:cascade_profiles+=1
	assert(motions.size()>=10,"Stage 1 draft enemies need distinct movement routes")
	assert(shot_forms.size()>=8,"Stage 1 draft enemies need distinct readable projectile forms")
	assert(display_scales.size()>=10,"Stage 1 draft enemies need distinct display scales")
	assert(scheduled_volley_total>=80 and cascade_profiles>=8,"Stage 1 needs substantial but staged projectile patterns")
	var long_body=stage1_variants["MB01"]
	assert(long_body.body_segments>=4 and long_body.body_span>=160 and long_body.body_radius>0,"MB01 must remain a readable long-body encounter")
	var tail_point=g.enemy_body_point(long_body,long_body.body_segments)
	assert(tail_point.distance_to(long_body.pos)>80 and g.enemy_body_contains(long_body,tail_point,long_body.hit_radius),"Long-body collision must match the visible tail")
	# A dense pattern is staged rather than appearing as an unreadable solid
	# wall: every authored volley is created, while the second beat remains
	# dormant until its short visible wind-up has elapsed.
	g.enemies.clear();g.shots.clear();g.wave_id=5;g.spawn_wave()
	var expected_shots=0
	for enemy_index in range(g.enemies.size()):
		var enemy=g.enemies[enemy_index]
		g.enemies[enemy_index]["cool"]=0.0
		g.enemies[enemy_index]["pos"].x=500.0+enemy_index*14.0
		expected_shots+=enemy.shot_offsets.size()*enemy.volley_count
	g.update_game(.01)
	var delayed_shots=0
	for shot in g.shots:
		if shot.delay>0:delayed_shots+=1
	assert(g.shots.size()==expected_shots and delayed_shots>0,"Staged Stage 1 volleys must create both immediate and delayed shots (expected=%d actual=%d delayed=%d)" % [expected_shots,g.shots.size(),delayed_shots])
	var flyer=g.enemies[1]
	flyer.cool=0
	g.update_game(.01)
	assert(flyer.retreating, "Small creatures leave the firing lane after their second salvo")
	flyer.pos.x=695.9
	g.update_game(.05)
	assert(not g.enemies.has(flyer), "Departed creatures must free their slot")
	var expected_shake=0.0 if g.visual.intensity>0 else 1.0
	var expected_flash=0.0 if g.visual.flash_level>0 else .35
	for key in [KEY_F10,KEY_F12]:
		var event=InputEventKey.new();event.physical_keycode=key;event.pressed=true;g._input(event)
	assert(g.visual.intensity==expected_shake and g.visual.flash_level==expected_flash)
	var cfg=ConfigFile.new();assert(cfg.load("user://visual.cfg")==OK)
	assert(cfg.get_value("v","shake",-1)==expected_shake and cfg.get_value("v","flash",-1)==expected_flash)
	g.queue_free();await process_frame;await process_frame
	print("V09 PASS: Stage 1 enemy H/V sheets, P0 item/projectile/VFX textures, default route, music/loop, short vertical, score isolation, boss/aftermath, intermission, pickup bloom, retry, accessible effects persisted")
	quit()

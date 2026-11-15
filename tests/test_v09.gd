extends SceneTree
func _initialize():run.call_deferred()
func run():
	var g=load("res://main.tscn").instantiate()
	root.add_child(g)
	g.set_process(false)
	assert(g.art_v09 and g.slice_mode)
	g.count=3;g.start_game()
	assert(g.music_name=="red_echo_v09" and absf(g.music.stream.get_length()-76.8)<.01)
	assert(g.music.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD)
	assert(g.vertical.duration==12)
	var prior=g.high_scores.duplicate()
	g.score=999999;g.finish(true)
	assert(g.high_scores==prior,"Short-slice score must not overwrite original route records")
	var record=JSON.parse_string(FileAccess.get_file_as_string("user://last_run.json"))
	assert(record.ruleset=="red-echo-slice-v09")
	g.start_game();g.elapsed=54.99;g.vertical.done=true
	g.update_game(.02)
	assert(not g.boss.is_empty() and g.music_name=="red_echo_boss_v09")
	g.boss.hp=0;g.update_game(.02)
	assert(g.aftermath>0 and g.mode=="play" and g.shots.is_empty())
	g.update_game(3.1)
	assert(g.mode=="clear")
	# Stage clear must open the provisional story overlay without starting a
	# second run; completing or skipping it returns to the verified title flow.
	g.open_stage1_intermission()
	assert(g.mode=="intermission")
	var overlay: Control = g.get_child(g.get_child_count()-1)
	overlay._complete(true)
	assert(g.mode=="menu")
	g.start_game()
	assert(g.aftermath==0 and g.visual.blasts.is_empty())
	assert(g.visual.ship_variants.size()==3)
	assert(g.visual.ship_variants[0]!=null and g.visual.ship_variants[1]!=null and g.visual.ship_variants[2]!=null)
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
	g.enemies.clear();g.wave_id=0;g.spawn_wave()
	var forms={}
	for enemy in g.enemies: forms[enemy.technique]=true
	assert(forms.size()>=3,"0.9 wave needs mixed readable movement forms")
	var stage1_art={}
	for wave in range(6):
		g.enemies.clear();g.spawn_wave()
		for enemy in g.enemies: stage1_art[enemy.art_id]=true
	for art_id in ["EN001","EN002","EN003","EN004","EN005","EN006","EN007","EN008","EN009","MB01","SB01"]:
		assert(stage1_art.has(art_id),"Stage 1 should schedule user-provided "+art_id+" art")
	var expected_shake=0.0 if g.visual.intensity>0 else 1.0
	var expected_flash=0.0 if g.visual.flash_level>0 else .35
	for key in [KEY_F10,KEY_F12]:
		var event=InputEventKey.new();event.physical_keycode=key;event.pressed=true;g._input(event)
	assert(g.visual.intensity==expected_shake and g.visual.flash_level==expected_flash)
	var cfg=ConfigFile.new();assert(cfg.load("user://visual.cfg")==OK)
	assert(cfg.get_value("v","shake",-1)==expected_shake and cfg.get_value("v","flash",-1)==expected_flash)
	g.queue_free();await process_frame;await process_frame
	print("V09 PASS: Stage 1 enemy H/V sheets, default route, music/loop, short vertical, score isolation, boss/aftermath, intermission, pickup bloom, retry, accessible effects persisted")
	quit()

extends SceneTree
var failures=0
func check(value,label):
	if not value:
		failures+=1
		push_error(label)
func _initialize(): call_deferred("run")
func run():
	var scene=load("res://main.tscn").instantiate()
	root.add_child(scene)
	await create_timer(.4).timeout
	check(scene.music.playing and scene.music_name=="bgm_opening_plan_a","Title BGM must play immediately")
	check(scene.music.get_playback_position()>.1,"Audio playback position must advance")
	check(scene.music.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD,"Music must loop")
	print("AUDIO: playing=",scene.music.playing," position=",scene.music.get_playback_position()," bus_peak_db=",AudioServer.get_bus_peak_volume_left_db(0,0))
	# Inject events into this test process only; this is not a physical button test.
	var devices=Input.get_connected_joypads()
	if devices.is_empty():
		push_error("This diagnostic needs one enumerated controller")
		quit(1)
		return
	var id=devices[0]
	scene.pad_profiles={}
	scene.start_game()
	scene.pads=[id]
	var motion=InputEventJoypadMotion.new()
	motion.device=id; motion.axis=JOY_AXIS_LEFT_X; motion.axis_value=1
	Input.parse_input_event(motion.duplicate());Input.flush_buffered_events()
	var event=InputEventJoypadButton.new()
	event.device=id;event.button_index=JOY_BUTTON_DPAD_LEFT;event.pressed=true
	Input.parse_input_event(event.duplicate());Input.flush_buffered_events()
	check(scene.movement(0)[0].x<-.9,"D-pad must override opposing stick input")
	var before=scene.players[0].pos.x
	scene.update_game(.05)
	check(scene.players[0].pos.x<before,"Actual movement update must move ship left")
	event.pressed=false;Input.parse_input_event(event.duplicate());Input.flush_buffered_events()
	motion.axis_value=0;Input.parse_input_event(motion.duplicate());Input.flush_buffered_events()
	check(scene.movement(0)[0]==Vector2.ZERO,"Releasing inputs must stop movement")
	scene.pad_profiles[scene.profile_key(id)]={"up":{"kind":"axis","index":4,"sign":-1.0},"fire":{"kind":"button","index":8}}
	motion.axis=4;motion.axis_value=-1;Input.parse_input_event(motion.duplicate());Input.flush_buffered_events()
	check(scene.movement(0)[0].y<-.9,"Custom axis mapping must support directional movement")
	event.button_index=8;event.pressed=true;Input.parse_input_event(event.duplicate());Input.flush_buffered_events()
	check(scene.movement(0)[1],"Custom fire button must work")
	event.pressed=false;Input.parse_input_event(event.duplicate());Input.flush_buffered_events()
	motion.axis_value=0;Input.parse_input_event(motion.duplicate());Input.flush_buffered_events()
	scene.mode="menu"
	scene.open_calibration()
	for index in range(8):
		event.button_index=index;event.pressed=true
		Input.parse_input_event(event.duplicate());Input.flush_buffered_events()
		event.pressed=false;Input.parse_input_event(event.duplicate());Input.flush_buffered_events()
		scene._process(0)
	check(scene.mode=="menu" and scene.pad_profiles[scene.profile_key(id)].size()==8,"Setup must save all 8 controls and return to menu")
	var cfg=ConfigFile.new()
	check(cfg.load("user://controls.cfg")==OK,"Control profile must persist")
	scene.music.stop()
	for player in scene.sfx_pool:player.stop()
	await create_timer(.3).timeout
	scene.queue_free()
	await process_frame
	print("INPUT / AUDIO TEST failures=",failures)
	call_deferred("quit",1 if failures else 0)

extends Node2D

const W = 640.0
const H = 360.0
const COLORS = [Color("67ecff"), Color("ff668e"), Color("ffce63")]
const WHITE = Color("e5f5ff")
const DIM = Color("617797")
const SHIP = ["...........11.............", "......11111221............", "..11112222222211..........", "..1333332222222211........", "1112222222444422221111....", "1222222244444422222222111.", "1112222222222222221111....", "..1333332222222211........", "..11112222222211..........", "......11111221............", "...........11............."]
const FOE = ["..11........11..", ".1221......1221.", "1222211111122221", ".12223333332221.", "..123344443321..", "1112334444332111", ".12223333332221.", "1222211111122221", ".1221......1221.", "..11........11.."]
# Separate original enemy silhouettes for focused and fan-volley attackers.
const FOE_LANCE = ["........11......", ".......1221.....", "..11..122221....", ".1221122233321..", "1222222334443221", ".1221122233321..", "..11..122221....", ".......1221.....", "........11......"]
const FOE_BLOOM = ["..111.......111..", ".12221.....12221.", "1222221...1222221", ".122223333322221.", "..12233444433221.", "...122333333221..", "1222221...1222221", ".12221.....12221.", "..111.......111.."]
const FONT = {
"A":"01110/10001/10001/11111/10001/10001/10001", "B":"11110/10001/10001/11110/10001/10001/11110", "C":"01111/10000/10000/10000/10000/10000/01111", "D":"11110/10001/10001/10001/10001/10001/11110", "E":"11111/10000/10000/11110/10000/10000/11111", "F":"11111/10000/10000/11110/10000/10000/10000", "G":"01111/10000/10000/10111/10001/10001/01111", "H":"10001/10001/10001/11111/10001/10001/10001", "I":"11111/00100/00100/00100/00100/00100/11111", "J":"00111/00010/00010/00010/10010/10010/01100", "K":"10001/10010/10100/11000/10100/10010/10001", "L":"10000/10000/10000/10000/10000/10000/11111", "M":"10001/11011/10101/10101/10001/10001/10001", "N":"10001/11001/11001/10101/10011/10011/10001", "O":"01110/10001/10001/10001/10001/10001/01110", "P":"11110/10001/10001/11110/10000/10000/10000", "Q":"01110/10001/10001/10001/10101/10010/01101", "R":"11110/10001/10001/11110/10100/10010/10001", "S":"01111/10000/10000/01110/00001/00001/11110", "T":"11111/00100/00100/00100/00100/00100/00100", "U":"10001/10001/10001/10001/10001/10001/01110", "V":"10001/10001/10001/10001/10001/01010/00100", "W":"10001/10001/10001/10101/10101/10101/01010", "X":"10001/10001/01010/00100/01010/10001/10001", "Y":"10001/10001/01010/00100/00100/00100/00100", "Z":"11111/00001/00010/00100/01000/10000/11111", "0":"01110/10001/10011/10101/11001/10001/01110", "1":"00100/01100/00100/00100/00100/00100/01110", "2":"01110/10001/00001/00010/00100/01000/11111", "3":"11110/00001/00001/01110/00001/00001/11110", "4":"00010/00110/01010/10010/11111/00010/00010", "5":"11111/10000/10000/11110/00001/00001/11110", "6":"01110/10000/10000/11110/10001/10001/01110", "7":"11111/00001/00010/00100/01000/01000/01000", "8":"01110/10001/10001/01110/10001/10001/01110", "9":"01110/10001/10001/01111/00001/00001/01110", ":":"00000/00100/00100/00000/00100/00100/00000", ".":"00000/00000/00000/00000/00000/00110/00110", "-":"00000/00000/00000/11111/00000/00000/00000", "+":"00000/00100/00100/11111/00100/00100/00000", "/":"00001/00010/00010/00100/01000/01000/10000", "<":"00010/00100/01000/10000/01000/00100/00010", ">":"01000/00100/00010/00001/00010/00100/01000", "!":"00100/00100/00100/00100/00100/00000/00100", "?":"01110/10001/00001/00010/00100/00000/00100"
}

var planet_texture: ImageTexture
const Abilities=preload("res://pilot_abilities.gd")
const MafioArchive=preload("res://mafio_archive.gd")
const EnemyAnalysis=preload("res://enemy_analysis.gd")
var enemy_analysis=EnemyAnalysis.new()
var analysis_flash=0.0
var mafio_archive=MafioArchive.new()
var status_slot=0
var status_return_mode="play"
var archive_page=false
var archive_cursor=0
const VerticalPassage=preload("res://vertical_passage.gd")
var vertical=VerticalPassage.new()
var mixed_scroll=true
var pilot_offset=0
var new_music=false
const ArtCatalog = preload("res://art_catalog.gd")
var artwork = ArtCatalog.new()
const BioStage = preload("res://biological_stage.gd")
var bio = BioStage.new()
var bio_route = true
const PILOT_NAMES = ["コルミィ", "ジヨーザ", "マフィオ"]
var mode = "menu"
var count = 1
var players: Array = []
var bullets: Array = []
var enemies: Array = []
var shots: Array = []
var particles: Array = []
var pickups: Array = []
var stars: Array = []
var pads: Array = []
var pad_edges = {}
var clock = 0.0
var travel = 0.0
var elapsed = 0.0
var wave_timer = 1.0
var wave_id = 0
var score = 0
var reserves = 3
var combo = 1
var combo_time = 0.0
var high_scores = [0,0,0]
var gate = 0
var gates_done = 0
var gate_order = [1,0,2]
var gate_step = 0
var gate_lights = [0.0,0.0,0.0]
var gate_flash = 0.0
var boss = {}
var notice = ""
var notice_time = 0.0
var shake = 0.0
var music: AudioStreamPlayer
var sounds = {}
var sfx_pool: Array = []
var muted = false
var show_help = false
var auto_test = false
var screenshot_mode = ""
var frame_count = 0
var tests_done = false
var test_count = 3
var pad_profiles = {}
var calibration_step = -1
var calibration_device = -1
var calibration_bindings = {}
var calibration_return = "menu"
var calibration_ready = false
var calibration_previous = {}
var calibration_axis_baseline = {}
var music_name = ""
var jp_font: SystemFont
const CONTROL_ACTIONS = ["up","down","left","right","fire","color","burst","start"]
const CONTROL_LABELS = ["上","下","左","右","ショットのボタン","色切り替えのボタン","バーストのボタン","決定・ポーズのボタン"]

func _ready():
	artwork.reload()
	mafio_archive.load_data()
	enemy_analysis.load_data()
	# Pixel textures stay sharp at integer scaling.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	DisplayServer.window_set_title("曼珠沙華（MANJUSHAGE）")
	randomize()
	build_planet_texture()
	for i in range(130):
		stars.append(Vector3(randf()*W,randf()*H,randf_range(.3,1.6)))
	pads = Array(Input.get_connected_joypads())
	Input.joy_connection_changed.connect(_pad_changed)
	jp_font=SystemFont.new()
	jp_font.font_names=PackedStringArray(["Yu Gothic", "Meiryo", "sans-serif"])
	var input_cfg=ConfigFile.new()
	if input_cfg.load("user://controls.cfg")==OK: pad_profiles=input_cfg.get_value("input","profiles",{})
	var audio_cfg=ConfigFile.new()
	if audio_cfg.load("user://audio.cfg")==OK:
		var output=str(audio_cfg.get_value("audio","output","Default"))
		if AudioServer.get_output_device_list().has(output): AudioServer.output_device=output
	music = AudioStreamPlayer.new()
	add_child(music)
	music.volume_db = -3
	music.finished.connect(_repeat_music)
	for name in ["shot","switch","hit","burst","gate","pickup"]:
		sounds[name] = load("res://audio/"+name+".wav")
	for i in range(12):
		var player = AudioStreamPlayer.new()
		player.volume_db = -8
		add_child(player)
		sfx_pool.append(player)
	var cfg = ConfigFile.new()
	if cfg.load("user://scores.cfg") == OK:
		for i in range(3): high_scores[i] = int(cfg.get_value("scores",str(i),0))
	for arg in OS.get_cmdline_user_args():
		if arg == "--legacy": bio_route=false
		if arg == "--bio": bio_route=true
		if arg.begins_with("--pilot="): pilot_offset=clampi(int(arg.substr(8)),0,2)
		if arg=="--new-music":new_music=true
		if arg == "--autotest": auto_test = true
		if arg.begins_with("--players="): test_count = clampi(int(arg.substr(10)),1,3)
		if arg.begins_with("--shot="): screenshot_mode = arg.substr(7)
	if not auto_test: track("title")
	if auto_test:
		Engine.time_scale = 20.0
		count = test_count
		start_game()
		run_mechanics_tests()
	elif screenshot_mode != "" and screenshot_mode != "menu":
		count = 3
		start_game()
		if screenshot_mode == "vertical":
			bio_route=true;travel=3100;vertical.begin(self);vertical.age=3
		if screenshot_mode == "gate": begin_gate(1)
		if screenshot_mode == "boss":
			travel=4800
			begin_boss()
		if screenshot_mode=="status": mode="status"
		if screenshot_mode=="archive":
			mode="status"; status_slot=0
			for j in range(players.size()):
				if players[j].character==2:
					status_slot=j
					break
			archive_page=players[status_slot].character==2
		for pilot in players: pilot.inv=0
	queue_redraw()

func _repeat_music():
	music.play()

func _pad_changed(device, connected):
	if connected:
		if not pads.has(device):
			var empty = -1
			for i in range(pads.size()):
				if not Input.get_connected_joypads().has(pads[i]): empty=i; break
			if empty>=0: pads[empty]=device
			else: pads.append(device)
	else:
		if mode == "play" and pads.has(device) and pads.find(device) < count:
			mode = "pause"
			notice = "CONTROLLER LOST - RECONNECT OR USE KEYBOARD"
		# Preserve slots so one disconnect cannot silently swap players.
		# Reconnected devices fill the same ID; menu re-enumerates on restart.
	if mode == "menu": pads = Array(Input.get_connected_joypads())

func sfx(name):
	if muted or auto_test: return
	for player in sfx_pool:
		if not player.playing:
			player.stream = sounds[name]
			player.play()
			return

func track(name):
	if name=="wistful_demo" and not ResourceLoader.exists("res://audio/wistful_demo.wav"):
		name="ruins" if mode=="play" else "title"
		tell("NEW MUSIC NOT BUILT / USING ORIGINAL",5)
	music_name=name
	music.stream = load("res://audio/"+name+".wav")
	if music.stream == null:
		tell("AUDIO FILE MISSING / PLEASE REBUILD",30)
		return
	if music.stream is AudioStreamWAV:
		music.stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		music.stream.loop_begin=0
		music.stream.loop_end=int(music.stream.get_length()*music.stream.mix_rate)
	if not auto_test: music.play()

func profile_key(device):
	return Input.get_joy_guid(device)+":"+Input.get_joy_name(device)

func binding_down(device,binding):
	if binding.get("kind","")=="button": return Input.is_joy_button_pressed(device,int(binding.index))
	if binding.get("kind","")=="axis": return Input.get_joy_axis(device,int(binding.index))*float(binding.sign)>.5
	return false

func pad_action(device,action,default_button):
	var profile=pad_profiles.get(profile_key(device),{})
	if profile.has(action): return binding_down(device,profile[action])
	return Input.is_joy_button_pressed(device,default_button)

func pad_direction(device):
	var dpad=Vector2(float(pad_action(device,"right",JOY_BUTTON_DPAD_RIGHT))-float(pad_action(device,"left",JOY_BUTTON_DPAD_LEFT)),float(pad_action(device,"down",JOY_BUTTON_DPAD_DOWN))-float(pad_action(device,"up",JOY_BUTTON_DPAD_UP)))
	# Digital directions take priority so a drifting stick cannot cancel a D-pad press.
	if dpad.length_squared()>0: return dpad.normalized()
	var stick=Vector2(Input.get_joy_axis(device,JOY_AXIS_LEFT_X),Input.get_joy_axis(device,JOY_AXIS_LEFT_Y))
	return stick.limit_length() if stick.length()>.25 else Vector2.ZERO

func pad_action_edge(device,action,button):
	var key=str(device)+":"+action
	var down=pad_action(device,action,button)
	var previous=pad_edges.get(key,false)
	pad_edges[key]=down
	return down and not previous

func open_calibration():
	if Input.get_connected_joypads().is_empty():
		tell("CONNECT A CONTROLLER FIRST",5)
		return
	calibration_return=mode
	calibration_step=0; calibration_device=-1; calibration_bindings={}; calibration_previous={}
	calibration_ready=true
	calibration_axis_baseline={}
	for id in Input.get_connected_joypads():
		for axis in range(JOY_AXIS_MAX): calibration_axis_baseline[str(id)+":"+str(axis)]=Input.get_joy_axis(id,axis)
	mode="controls"

func capture_binding(event):
	if event is InputEventKey and event.pressed and event.physical_keycode==KEY_ESCAPE:
		mode=calibration_return; calibration_step=-1
		return
	if not calibration_ready or not (event is InputEventJoypadButton or event is InputEventJoypadMotion): return
	if calibration_device>=0 and event.device!=calibration_device: return
	var binding={}
	if event is InputEventJoypadButton and event.pressed:
		binding={"kind":"button","index":event.button_index}
	elif event is InputEventJoypadMotion:
		var baseline=calibration_axis_baseline.get(str(event.device)+":"+str(event.axis),0.0)
		if absf(event.axis_value-baseline)>.65 and absf(event.axis_value)>.65 and absf(baseline)<.4:
			binding={"kind":"axis","index":event.axis,"sign":signf(event.axis_value)}
	if binding.is_empty(): return
	# Each action must be distinct; otherwise a held direction could also fire/start.
	if calibration_bindings.values().has(binding): return
	calibration_device=event.device
	calibration_bindings[CONTROL_ACTIONS[calibration_step]]=binding
	calibration_previous=binding
	calibration_ready=false
	calibration_step+=1
	if calibration_step==CONTROL_ACTIONS.size():
		pad_profiles[profile_key(calibration_device)]=calibration_bindings.duplicate(true)
		var cfg=ConfigFile.new()
		cfg.set_value("input","profiles",pad_profiles)
		var result=cfg.save("user://controls.cfg")
		tell("CONTROLS SAVED" if result==OK else "CONTROLS ACTIVE / SAVE FAILED",4)
		pad_edges[str(calibration_device)+":start"]=true
		pad_edges[str(calibration_device)+":fire"]=true
		mode=calibration_return; calibration_step=-1

func japanese(message,pos,size=13,color=WHITE):
	draw_string(jp_font,pos,message,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func tell(message, duration = 3.0):
	notice = message
	notice_time = duration

func start_game():
	bio.reset()
	vertical.reset()
	pads = Array(Input.get_connected_joypads())
	players.clear(); bullets.clear(); shots.clear(); enemies.clear(); pickups.clear(); particles.clear()
	travel = 0; elapsed = 0; wave_id = 0; wave_timer = 1.5; score = 0
	reserves = count*3; combo = 1; combo_time = 0; gate = 0; gates_done = 0; boss = {}
	for i in range(count):
		players.append({"pos":Vector2(100-i*23,110+i*65),"color":i,"hp":4,"cool":0.0,"inv":2.0,"down":0.0,"rescue":0.0,"charge":100.0,"burst":0.0})
	for i in range(count): Abilities.initialize(players[i],(i+pilot_offset)%3)
	mode = "play"
	show_help = false
	track("wistful_demo" if new_music else "ruins")
	tell("STAGE 01 / RED ECHO - EXPERIMENT" if bio_route else "SECTOR 01 / THE SLEEPING RELAY",4)

func button_edge(device, button):
	var key = str(device)+":"+str(button)
	var down = Input.is_joy_button_pressed(device,button)
	var previous = pad_edges.get(key,false)
	pad_edges[key] = down
	return down and not previous

func _input(event):
	if mode=="controls":
		capture_binding(event)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key = event.physical_keycode
		if mode=="status":
			if key in [KEY_ESCAPE,KEY_TAB,KEY_ENTER]:
				mode=status_return_mode
			elif key in [KEY_LEFT,KEY_A]:
				status_slot=(status_slot+players.size()-1)%maxi(1,players.size()); archive_page=false
			elif key in [KEY_RIGHT,KEY_D]:
				status_slot=(status_slot+1)%maxi(1,players.size()); archive_page=false
			elif key==KEY_E and players[status_slot].character==2:
				archive_page=not archive_page
			elif key==KEY_UP:
				archive_cursor=maxi(0,archive_cursor-1)
			elif key==KEY_DOWN:
				archive_cursor=mini(MafioArchive.ENTRIES.size()-1,archive_cursor+1)
			return
		if key==KEY_TAB and mode in ["play","pause"]:
			status_return_mode=mode; mode="status"; status_slot=0; archive_page=false
			return
		if key==KEY_F4 and mode=="menu": pilot_offset=(pilot_offset+1)%3; return
		if key==KEY_F5 and mode=="menu": mixed_scroll=not mixed_scroll; return
		if key==KEY_F8 and mode=="menu":
			new_music=not new_music
			track("wistful_demo" if new_music else "title")
			return
		if key==KEY_F3 and mode=="menu":
			bio_route=not bio_route
			return
		if key==KEY_F2 and mode in ["menu","pause"]:
			open_calibration()
			return
		if key==KEY_F6:
			muted=false
			AudioServer.set_bus_mute(0,false)
			music.stream_paused=false
			music.play()
			sfx("pickup")
		if key==KEY_F7:
			var outputs=AudioServer.get_output_device_list()
			if not outputs.is_empty():
				AudioServer.output_device=outputs[(outputs.find(AudioServer.output_device)+1)%outputs.size()]
				var cfg=ConfigFile.new()
				cfg.set_value("audio","output",AudioServer.output_device)
				cfg.save("user://audio.cfg")
		if key == KEY_F11:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		if key == KEY_M:
			muted = not muted
			AudioServer.set_bus_mute(0,muted)
		if mode == "menu":
			if key in [KEY_LEFT,KEY_A]: count = maxi(1,count-1)
			if key in [KEY_RIGHT,KEY_D]: count = mini(3,count+1)
			if key in [KEY_1,KEY_2,KEY_3]: count = key-KEY_1+1
			if key == KEY_H: show_help = not show_help
			if key in [KEY_ENTER,KEY_SPACE]: start_game()
		elif mode == "play":
			if key in [KEY_ESCAPE,KEY_P]: mode = "pause"; notice = "FLIGHT PAUSED"
			for i in range(count):
				if key == [KEY_X,KEY_F,KEY_O][i]: change_color(i)
				if key == [KEY_C,KEY_G,KEY_N][i]: burst(i)
		elif mode == "pause":
			if key in [KEY_ESCAPE,KEY_P,KEY_ENTER]: mode = "play"
			if key == KEY_Q: mode = "menu"; track("title")
		else:
			if key in [KEY_ENTER,KEY_SPACE]: start_game()
			if key == KEY_ESCAPE: mode = "menu"; track("title")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mode == "menu":
		var p = get_global_mouse_position()
		if Rect2(220,236,200,32).has_point(p): start_game()
		elif Rect2(185,307,270,20).has_point(p): open_calibration()
		elif p.y > 200 and p.y < 232:
			if p.x < 320: count=maxi(1,count-1)
			else: count=mini(3,count+1)

func change_color(i):
	if players[i].down > 0: return
	players[i].color = (players[i].color+1)%3
	sfx("switch")

func burst(i):
	var p = players[i]
	if p.down>0: return
	if bio_route and p.character==2 and Abilities.eat(self,p): return
	if p.character==1:
		special_analysis(p)
		return
	if p.charge<100: return
	p.charge = 0; p.burst = .55; p.inv = 1
	shots.clear()
	for e in enemies: e.hp -= 5
	if not boss.is_empty():
		if bio_route and not bio.exposed():
			for part in range(2): bio.damage_part(self,part,8)
		else: boss.hp-=12
	shake = 4
	sfx("burst")


# SPECIAL ANALYSIS: only previously observed normal enemies, never bosses.
# Enemy-bullet tags travel from the source and are checked independently.
func special_analysis(p):
	# Never spend ordinary, time-regenerated burst energy.
	if p.analysis_charge<100 or p.analysis_uses>=2: return
	var affected=0
	for e in enemies:
		if e.get("analysis_eligible",false) and float(e.get("hp",0.0))>0: affected+=1
	for shot in shots:
		if shot.get("analysis_eligible",false): affected+=1
	if affected==0:
		tell("UNKNOWN ENEMY / BOSS IMMUNE",2.2)
		return
	p.analysis_charge=0
	p.analysis_uses+=1
	p.burst=.48
	p.inv=maxf(float(p.inv),.65)
	analysis_flash=.56
	for e in enemies:
		if e.get("analysis_eligible",false) and float(e.get("hp",0.0))>0:
			explode(e.pos,Color("a8eaff"),11)
			e.hp=0
			e.flash=.2
	shots=shots.filter(func(shot):return not bool(shot.get("analysis_eligible",false)))
	tell("ANALYSIS / KNOWN PATTERNS PURGED",2.2)
	sfx("burst")
func _process(dt):
	clock += dt
	analysis_flash=maxf(0.0,analysis_flash-dt)
	music.stream_paused = mode in ["pause","status"]
	frame_count += 1
	if mode=="controls":
		if not calibration_ready and calibration_device>=0:
			calibration_ready=not binding_down(calibration_device,calibration_previous)
		queue_redraw()
		return
	for device in Input.get_connected_joypads():
		var start = pad_action_edge(device,"start",JOY_BUTTON_START)
		var a = pad_action_edge(device,"fire",JOY_BUTTON_A)
		var x = pad_action_edge(device,"color",JOY_BUTTON_X)
		var b = pad_action_edge(device,"burst",JOY_BUTTON_B)
		var left = pad_action_edge(device,"left",JOY_BUTTON_DPAD_LEFT)
		var right = pad_action_edge(device,"right",JOY_BUTTON_DPAD_RIGHT)
		if mode == "menu":
			if left: count=maxi(1,count-1)
			if right: count=mini(3,count+1)
			if x: pilot_offset=(pilot_offset+1)%3
			if b: bio_route=not bio_route
			if start or a: start_game()
		elif mode == "play":
			if start: mode="pause"; notice="FLIGHT PAUSED"
			var slot = pads.find(device)
			if slot >= 0 and slot < count:
				if x: change_color(slot)
				if b: burst(slot)
		elif mode == "pause":
			if x:
				status_return_mode="pause"; status_slot=0; archive_page=false; mode="status"
			elif start or a: mode="play"
		elif mode == "status":
			if start or b: mode=status_return_mode
			elif left:
				status_slot=(status_slot+players.size()-1)%maxi(1,players.size());archive_page=false
			elif right:
				status_slot=(status_slot+1)%maxi(1,players.size());archive_page=false
			elif x and players[status_slot].character==2: archive_page=not archive_page
			elif a and archive_page: archive_cursor=(archive_cursor+1)%MafioArchive.ENTRIES.size()
		elif start or a: start_game()
	if mode == "play":
		update_game(minf(dt,.05))
	elif mode == "menu":
		travel += dt*14
		notice_time=maxf(0,notice_time-dt)
	for part in particles:
		part.pos += part.vel*dt
		part.life -= dt
	particles = particles.filter(func(p): return p.life>0)
	shake = maxf(0,shake-dt*20)
	queue_redraw()
	if screenshot_mode != "" and frame_count == 12:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://"+screenshot_mode+".png")
		get_tree().quit()
	if auto_test and elapsed > 245 and not tests_done:
		push_error("AUTOTEST TIMEOUT")
		get_tree().quit(1)

func movement(i):
	var keysets = [[KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,KEY_Z],[KEY_A,KEY_D,KEY_W,KEY_S,KEY_R],[KEY_J,KEY_L,KEY_I,KEY_K,KEY_U]]
	var k=keysets[i]
	var v=Vector2(float(Input.is_physical_key_pressed(k[1]))-float(Input.is_physical_key_pressed(k[0])),float(Input.is_physical_key_pressed(k[3]))-float(Input.is_physical_key_pressed(k[2])))
	var fire=Input.is_physical_key_pressed(k[4]) or (i==0 and Input.is_physical_key_pressed(KEY_SPACE))
	if i<pads.size() and Input.get_connected_joypads().has(pads[i]):
		var id=pads[i]
		v+=pad_direction(id)
		fire=fire or pad_action(id,"fire",JOY_BUTTON_A) or Input.get_joy_axis(id,JOY_AXIS_TRIGGER_RIGHT)>.4
	return [v.limit_length(),fire]

func update_game(dt):
	elapsed += dt
	if bio_route and mixed_scroll and not vertical.done and travel>=3100 and gate==0 and boss.is_empty():
		if not vertical.active: vertical.begin(self)
		vertical.update(self,dt)
		return
	notice_time = maxf(0,notice_time-dt)
	gate_flash = maxf(0,gate_flash-dt)
	combo_time -= dt
	if combo_time<0: combo=1
	if gate==0 and boss.is_empty(): travel+=dt*(28 if bio_route else 35)
	if bio_route: bio.update(self,dt)
	for i in range(count):
		var p=players[i]
		p.fusion_flash=maxf(0.0,float(p.get("fusion_flash",0.0))-dt)
		Abilities.digest(p,dt)
		p.cool-=dt; p.inv-=dt; p.burst=maxf(0,p.burst-dt)
		p.charge=minf(100,p.charge+dt*2)
		# Cor mii continues normal fire while storing a variable-power release shot.
		if p.character==0:
			if movement(i)[1] and p.down<=0:
				p.shot_hold=minf(1.7,float(p.shot_hold)+dt)
			elif p.shot_hold>=.70 and p.down<=0:
				var charged=Abilities.damage(p,elapsed,randf())*(3.0+maxf(0,p.shot_hold-.7)*1.5)
				bullets.append({"pos":p.pos+Vector2(19,0),"color":p.color,"owner":i,"vel":Vector2(430,0),"damage":charged,"grade":"charged_"+str(p.last_power_grade)})
				p.shot_hold=0.0
				sfx("shot")
			else:
				p.shot_hold=0.0
		if p.down>0:
			p.down=maxf(.01,p.down-dt)
			var near=false
			for other in players:
				if other.down==0 and other.pos.distance_to(p.pos)<55: near=true
			p.rescue=maxf(0,p.rescue+dt*(1 if near else -.5))
			if p.rescue>=1.5 or (p.down<.1 and reserves>0):
				if p.rescue<1.5: reserves-=1
				p.down=0; p.hp=4; p.inv=3; p.rescue=0
				p.pos.x=clampf(p.pos.x,40,320)
				sfx("pickup")
			continue
		var input=movement(i)
		if auto_test:
			p.inv=100
			input[1]=true
			var target=Vector2(180+i*20,150)
			if gate>0:
				var index=gate_order[mini(gate_step,2)] if gate==1 else i
				if gate==2 and count<3:
					for j in range(3):
						if gate_lights[j]<=0: index=j; break
				p.color=index
				target=Vector2(360,100+index*80)
			elif not boss.is_empty():
				p.color=boss.color
				target=Vector2(350,boss.pos.y)
				if bio_route and not bio.exposed():
					for part in range(2):
						if bio.armor[part]>0:
							target=Vector2(350,bio.part_pos(self,part).y)
							break
			input[0]=(target-p.pos).limit_length()
		p.pos+=input[0]*155*dt
		p.pos.x=clampf(p.pos.x,18,440 if gate>0 else 605)
		p.pos.y=clampf(p.pos.y,48,320)
		if input[1] and p.cool<=0:
			p.cool=.13
			var velocities=Abilities.velocities(p,Vector2.RIGHT,enemies) if bio_route else [Vector2(390,0)]
			# One chance roll per volley, shared by all projectiles. Works in both routes.
			var power=1.0
			if p.character==0:
				power=Abilities.damage(p,elapsed,randf())
			elif bio_route:
				power=Abilities.damage(p,elapsed)
			for velocity in velocities:
				bullets.append({"pos":p.pos+Vector2(18,0),"color":p.color,"owner":i,"vel":velocity,"damage":power,"grade":p.last_power_grade if p.character==0 else "normal"})
			if i==0: sfx("shot")
	var alive=players.any(func(p): return p.down==0)
	if not alive and reserves==0:
		finish(false)
		return
	if gate==0 and boss.is_empty():
		if travel>=1400 and gates_done==0: begin_gate(1)
		elif travel>=3000 and gates_done==1: begin_gate(2)
		elif travel>=4800: begin_boss()
		else:
			wave_timer-=dt
			if wave_timer<=0:
				spawn_wave(); wave_timer=2.5
	if gate>0:
		for i in range(3): gate_lights[i]=maxf(0,gate_lights[i]-dt) if gate==2 else gate_lights[i]
		if gate==2 and gate_lights.all(func(t): return t>0): open_gate()
	if not boss.is_empty(): update_boss(dt)
	for bullet in bullets:
		bullet.pos+=dt*bullet.get("vel",Vector2(390,0))
		if gate>0 and bullet.pos.x>472:
			for i in range(3):
				if absf(bullet.pos.y-(100+i*80))<17:
					if bullet.color==i:
						if gate==1 and gate_step<3 and i==gate_order[gate_step]:
							gate_lights[i]=99; gate_step+=1; sfx("pickup")
						elif gate==2: gate_lights[i]=7.5; sfx("pickup")
					else: gate_flash=.12
			bullet.pos.x=800
			if gate==1 and gate_step>=3: open_gate()
		for e in enemies:
			if e.hp>0 and bullet.pos.distance_to(e.pos)<19:
				e.hp-=bullet.get("damage",1.0); e.flash=.08; bullet.pos.x=800; sfx("hit")
		if bio_route and not boss.is_empty() and bio.intercept(self,bullet): continue
		if not boss.is_empty() and bullet.pos.distance_to(boss.pos)<38:
			if bullet.color==boss.color and (not bio_route or bio.exposed()):
				boss.hp-=bullet.get("damage",1.0); boss.flash=.07; sfx("hit")
			bullet.pos.x=800
	bullets=bullets.filter(func(b):return b.pos.x<700 and b.pos.y>30 and b.pos.y<340)
	for e in enemies:
		e.age+=dt; e.flash=maxf(0,e.flash-dt)
		e.pos.x-=e.speed*dt
		e.pos.y=e.base+sin(e.age*2.3+e.phase)*e.amplitude
		e.cool-=dt
		if e.cool<=0 and e.pos.x<610:
			e.cool=2.5
			var target=players[wave_id%count].pos
			for angle in ([-.2,0,.2] if bio_route and e.get("technique","")=="fan" else [0]):
				shots.append({"pos":e.pos,"vel":(target-e.pos).normalized().rotated(angle)*85,"r":3,"analysis_eligible":e.get("analysis_eligible",false),"source_id":e.get("analysis_id","")})
		for p in players:
			if p.down==0 and p.pos.distance_to(e.pos)<20: hurt(p)
		if e.hp<=0:
			# Jiyoza: only dedicated marked enemies drop analysis shards.
			if e.get("scan_crystal",false) and players.any(func(p):return p.character==1 and p.analysis_uses<2):
				pickups.append({"pos":e.pos,"kind":3})
			for p in players:
				if p.down==0:p.experience+=1
			explode(e.pos,COLORS[1],14)
			score+=100*combo; combo=mini(8,combo+1); combo_time=3
			if randi()%4==0:
				var kind=0 if randi()%4==0 else 1
				# Rare, Cormii-only pickup; stop dropping it once the core is maxed.
				var needs_stability=players.any(func(p): return p.character==0 and p.stability<3)
				if needs_stability and kind==1 and randi()%3==0: kind=2
				pickups.append({"pos":e.pos,"kind":kind})
	enemies=enemies.filter(func(e): return e.hp>0 and e.pos.x > -40)
	for shot in shots:
		shot.pos+=shot.vel*dt
		for p in players:
			if p.down==0 and p.pos.distance_to(shot.pos)<8+shot.r:
				hurt(p); shot.pos.x=-100
	shots=shots.filter(func(s):return s.pos.x>-30 and s.pos.x<680 and s.pos.y>30 and s.pos.y<340)
	for item in pickups:
		item.pos.x-=dt*40
		for p in players:
			if p.down==0 and p.pos.distance_to(item.pos)<20:
				# Stability core belongs to Cormii; other pilots must not consume it.
				if item.kind==2 and p.character!=0: continue
				if item.kind==3 and (p.character!=1 or p.analysis_uses>=2 or p.analysis_charge>=100): continue
				if item.kind==0:
					p.hp=mini(4,p.hp+1)
				elif item.kind==1:
					p.charge=minf(100,p.charge+25)
				elif item.kind==3:
					p.analysis_charge=mini(100,int(p.analysis_charge)+25)
					if p.analysis_charge>=100: tell("SPECIAL ANALYSIS / READY",2.0)
				else:
					p.stability=mini(3,p.stability+1)
					tell("COR MII / STABILITY "+str(p.stability)+"/3",2.0)
				explode(item.pos,Color("96faff") if item.kind==3 else (Color("ffe5a0") if item.kind==2 else (Color("ffb7a2") if item.kind==0 else Color("9ee8ff"))),11 if item.kind in [2,3] else 8)
				score+=50; sfx("pickup"); item.pos.x=-100
	pickups=pickups.filter(func(p):return p.pos.x>-20)
	if not boss.is_empty() and boss.hp<=0: finish(true)

func spawn_wave():
	wave_id+=1
	var base=85+(wave_id*61)%190
	var pattern="fan" if wave_id%2==0 else "aimed"
	var group: Array=[]
	for j in range(3+count):
		group.append({"pos":Vector2(670+j*34,base),"base":base,"age":0.0,"phase":j*.65,"speed":55.0+wave_id%4*9,"amplitude":23.0,"hp":2+int(count>1),"cool":1.5+j*.35,"flash":0.0,"technique":pattern,"scan_crystal":wave_id in [4,8,12,16,24,32,40,48] and j==0})
	enemy_analysis.mark_new_group(group,"prototype/"+pattern)
	enemies.append_array(group)

func begin_gate(number):
	gate=number; gate_step=0; gate_lights=[0.0,0.0,0.0]
	enemies.clear(); shots.clear(); bullets.clear()
	tell("RELAY 01 / MATCH COLOR - SHOOT IN ORDER" if number==1 else "RELAY 02 / LIGHT ALL THREE WITHIN 7 SECONDS",5)

func open_gate():
	score+=2500*count
	gates_done+=1; gate=0
	explode(Vector2(490,180),COLORS[0],60)
	for p in players: p.charge=minf(100,p.charge+40)
	sfx("gate"); tell("RELAY LINKED / ROUTE UNLOCKED",3)
	wave_timer=3

func begin_boss():
	enemies.clear(); shots.clear(); bullets.clear()
	boss={"pos":Vector2(525,180),"hp":65.0+count*35,"max":65.0+count*35,"age":0.0,"cool":2.5,"volleys":0,"color":0,"flash":0.0}
	if bio_route: bio.begin_boss(count)
	track("sentinel")
	tell("WARNING / LIVING CORE - EXPERIMENT" if bio_route else "WARNING / PRISM SENTINEL",4)

func update_boss(dt):
	boss.age+=dt; boss.cool-=dt; boss.flash=maxf(0,boss.flash-dt)
	boss.pos.y=180+sin(boss.age*.65)*74
	boss.color=int(boss.age/7)%3
	if boss.cool<=0:
		boss.volleys+=1
		boss.cool=2.3 if boss.volleys%3==0 else 1.55
		var phase=1 if not bio_route or not bio.exposed() else (3 if boss.hp<boss.max*.5 else 2)
		var fan=7 if phase==3 else 5
		for j in range(fan):
			var angle=PI+(j-(fan-1)*.5)*.24+sin(boss.age)*.15
			shots.append({"pos":boss.pos+Vector2(-35,0),"vel":Vector2.from_angle(angle)*(72+(phase-1)*7),"r":4})
		if boss.hp<boss.max*.5 and boss.volleys%3==0:
			for p in players:
				if p.down==0: shots.append({"pos":boss.pos,"vel":(p.pos-boss.pos).normalized()*95,"r":3})
	for p in players:
		if p.down==0 and p.pos.distance_to(boss.pos)<60: hurt(p)

func hurt(p):
	if p.inv>0: return
	p.hp-=1; p.inv=1.7; shake=3; combo=1
	sfx("hit"); explode(p.pos,COLORS[p.color],10)
	if p.hp<=0:
		p.down=6; p.rescue=0
		tell("SHIP DOWN / APPROACH THE POD TO RESCUE",3)
		if not auto_test:
			for id in pads:
				Input.start_joy_vibration(id,.2,.4,.2)

# Spark/petal bursts have a strict limit so heavy 3P bullet screens stay clear.
func explode(pos,color,amount):
	for i in range(mini(amount,maxi(0,210-particles.size()))):
		var lifetime=randf_range(.22,.62)
		particles.append({"pos":pos,"vel":Vector2.from_angle(randf()*TAU)*randf_range(26,102),"life":lifetime,"max_life":lifetime,"color":color,"petal":i%3==0})

func finish(won):
	mode="clear" if won else "over"
	music.stop(); sfx("gate" if won else "burst")
	if won: track("ending")
	if won:
		score+=reserves*1000
		explode(Vector2(525,180),COLORS[2],90)
	if not auto_test:
		high_scores[count-1]=maxi(high_scores[count-1],score)
		var cfg=ConfigFile.new()
		for i in range(3): cfg.set_value("scores",str(i),high_scores[i])
		cfg.save("user://scores.cfg")
		var record={"version":"0.2.0","ruleset":"ruins-v1","players":count,"score":score,"elapsed":elapsed,"cleared":won,"gates":gates_done,"timestamp":Time.get_datetime_string_from_system()}
		var file=FileAccess.open("user://last_run.json",FileAccess.WRITE)
		if file: file.store_string(JSON.stringify(record,"  "))
	else:
		tests_done=true
		if won and gates_done==2:
			print("AUTOTEST PASS: ",count," pilots, both relay puzzles, boss defeat, stage clear. Score=",score," elapsed=",elapsed)
			get_tree().quit(0)
		else:
			push_error("AUTOTEST FAIL")
			get_tree().quit(1)

func run_mechanics_tests():
	# Exercise actual keyboard event handlers and the same collision/recovery update used in play.
	var event=InputEventKey.new()
	event.physical_keycode=KEY_X; event.pressed=true
	_input(event)
	assert(players[0].color==1,"Color switching must work through keyboard input")
	event.physical_keycode=KEY_C
	shots.append({"pos":Vector2(500,180),"vel":Vector2.ZERO,"r":3})
	_input(event)
	assert(shots.is_empty() and players[0].charge==0,"Burst must consume energy and clear bullets")
	event.physical_keycode=KEY_ESCAPE
	_input(event)
	assert(mode=="pause","Escape must pause")
	_input(event)
	assert(mode=="play","Escape must resume")
	players[0].inv=0; players[0].hp=1
	hurt(players[0])
	assert(players[0].down>0,"Fatal damage must create a rescue pod")
	if count>1:
		players[1].pos=players[0].pos
		players[0].rescue=1.49
		update_game(.02)
		assert(players[0].down==0 and reserves==count*3,"Ally rescue must not cost a reserve")
	else:
		players[0].down=.05
		update_game(.02)
		assert(players[0].down==0 and reserves==2,"Solo recovery must consume one reserve")
	print("MECHANICS PASS: color, burst, pause/resume, damage and recovery")
	start_game()

func text_at(message, pos, color=WHITE, scale_px=1):
	var x=pos.x
	for ch in str(message).to_upper():
		if FONT.has(ch):
			var rows=FONT[ch].split("/")
			for y in range(7):
				for col in range(5):
					if rows[y][col]=="1": draw_rect(Rect2(x+col*scale_px,pos.y+y*scale_px,scale_px,scale_px),color)
		x+=6*scale_px

func centered(message,y,color=WHITE,size=1):
	text_at(message,Vector2((W-message.length()*6*size)/2,y),color,size)

func sprite(rows,pos,palette,size=1):
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			var ch=rows[y][x]
			if ch!=".":
				var base: Color = palette[int(ch)-1]
				var shade = base.lightened(.12) if y < rows.size()/2 else base.darkened(.16)
				draw_rect(Rect2(floor(pos.x+x*size),floor(pos.y+y*size),size,size),shade)
				if size>1:
					var above = "." if y==0 or x>=rows[y-1].length() else rows[y-1][x]
					if above!=ch: draw_rect(Rect2(floor(pos.x+x*size),floor(pos.y+y*size),size,1),base.lightened(.28))
					if x==rows[y].length()-1 or rows[y][x+1]==".": draw_rect(Rect2(floor(pos.x+(x+1)*size-1),floor(pos.y+y*size),1,size),base.darkened(.32))

func ship(pos,color,size=1,character=-1):
	var pilot_slot=""
	if character>=0 and character<3:
		pilot_slot=["ship_cormii","ship_jiyoza","ship_mafio"][character]
	var art=artwork.texture(pilot_slot) if pilot_slot!="" else null
	if art!=null:
		draw_texture_rect(art,Rect2(pos-Vector2(16,10)*size,Vector2(32,20)*size),false)
	else:
		var pal=[Color("263e67"),WHITE,color,Color("7b94be")]
		sprite(SHIP,pos-Vector2(12,5)*size,pal,size)
	draw_rect(Rect2(pos.x-18*size,pos.y-2*size,(6+int(clock*20)%4)*size,4*size),Color("ff8b4e"))
	draw_rect(Rect2(pos.x-14*size,pos.y-size,5*size,2*size),Color("ffedb0"))

func build_planet_texture():
	var img=Image.create(125,125,false,Image.FORMAT_RGBA8)
	for py in range(-61,62):
		var half=int(sqrt(maxf(0,62*62-py*py)))
		for px in range(-half,half):
			var light=clampf(.48-float(px)/150-float(py)/230,0,1)
			var col=Color("34455f").lerp(Color("95b2b6"),floor(light*12)/12)
			if sin(py*.23+sin(px*.045)*2)>.56: col=col.lightened(.12)
			img.set_pixel(px+62,py+62,col)
	planet_texture=ImageTexture.create_from_image(img)

func background():
	if mode=="menu":
		var cover=artwork.texture("title_backdrop")
		if cover!=null:
			draw_texture_rect(cover,Rect2(0,0,W,H),false)
			draw_rect(Rect2(0,0,W,H),Color(0,0,0,.25))
			return
	if bio_route:
		bio.draw_background(self)
		return
	# Four independent scroll planes; fine highlights stay on the native pixel grid.
	for y in range(360):
		draw_line(Vector2(0,y),Vector2(640,y),Color("101630").lerp(Color("566978"),float(y)/430))
	for star in stars:
		var sx=floor(fposmod(star.x-travel*star.z*.08,W))
		draw_rect(Rect2(sx,star.y,1,1),Color("7b91ac") if star.z<1 else Color("c5d3d5"))
	# Scanline-built planet: shaded limb and cloud strata without blurred filtering.
	var planet=Vector2(472-floor(fposmod(travel*.025,100)),118)
	draw_texture(planet_texture,planet-Vector2(62,62))
	for layer in range(3):
		var base_y=230+layer*38
		var tint=[Color("34475f"),Color("293c53"),Color("203248")][layer]
		for i in range(13):
			var x=floor(fposmod(i*61-travel*(.08+layer*.09),793))-70
			var ht=25+(i*31+layer*17)%75
			draw_rect(Rect2(x,base_y-ht,43,ht+110),tint)
			draw_rect(Rect2(x+4,base_y-ht-4,35,4),tint.lightened(.08))
			draw_rect(Rect2(x+5,base_y-ht+5,2,ht-5),tint.lightened(.11))
			for row in range(3):
				for col in range(3):
					draw_rect(Rect2(x+12+col*8,base_y-ht+12+row*13,3,5),tint.darkened(.3))
	for i in range(8):
		var x=floor(fposmod(i*106-travel*.48,848))-90
		var top=275+(i*19)%35
		# Carved foreground masonry, bevels, seams and illuminated insets.
		draw_rect(Rect2(x,top,64,70),Color("182b3e"))
		draw_rect(Rect2(x,top,64,3),Color("77959b"))
		draw_rect(Rect2(x+2,top+3,5,67),Color("435e6b"))
		draw_rect(Rect2(x+58,top+3,6,67),Color("101e32"))
		for row in range(4):
			draw_line(Vector2(x+8,top+12+row*14),Vector2(x+57,top+12+row*14),Color("30475a"))
			draw_rect(Rect2(x+18+(row%2)*15,top+4+row*14,1,8),Color("425c69"))
		draw_rect(Rect2(x+27,top+9,10,30),Color("0b1d30"))
		draw_rect(Rect2(x+30,top+12,3,23),Color("58b4bb"))

# HP and energy have distinct silhouettes, not tiny lettered boxes.
func draw_collectible(item):
	var p: Vector2=item.pos+Vector2(0,sin(clock*3.0+item.pos.x*.02)*1.2)
	var image=artwork.texture("item_stability" if item.kind==2 else ("item_hp" if item.kind==0 else "item_energy"))
	if image!=null:
		draw_texture_rect(image,Rect2(p-Vector2(10,10),Vector2(20,20)),false)
		return
	if item.kind==2:
		# Gold hexagonal probability core: two counter-rotating probability rings.
		var ring=.15*sin(clock*4.0)
		draw_circle(p,12,Color(1,.78,.25,.12))
		draw_arc(p,9,ring,PI+ring,14,Color("ffe2a1"),1.5)
		draw_arc(p,9,PI+ring,TAU+ring,14,Color("a6eaff"),1.5)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-4,-7),p+Vector2(4,-7),p+Vector2(8,0),p+Vector2(4,7),p+Vector2(-4,7),p+Vector2(-8,0)]),Color("a97630"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-3,-5),p+Vector2(3,-5),p+Vector2(6,0),p+Vector2(3,5),p+Vector2(-3,5),p+Vector2(-6,0)]),Color("fff0bc"))
		draw_rect(Rect2(p+Vector2(-1,-4),Vector2(2,8)),Color("8ecfdf"))
		draw_rect(Rect2(p+Vector2(-4,-1),Vector2(8,2)),Color("8ecfdf"))
		return
	var heart=item.kind==0
	var outline=Color("3c152f") if heart else Color("112b4e")
	var glow=Color(.98,.32,.52,.13) if heart else Color(.25,.79,1.0,.15)
	draw_circle(p,11,glow)
	if heart:
		var shape=PackedVector2Array([p+Vector2(0,7),p+Vector2(-7,-1),p+Vector2(-7,-5),p+Vector2(-4,-8),p+Vector2(-1,-7),p,p+Vector2(1,-7),p+Vector2(4,-8),p+Vector2(7,-5),p+Vector2(7,-1)])
		draw_colored_polygon(shape,outline)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,5),p+Vector2(-5,-2),p+Vector2(-4,-5),p+Vector2(-1,-4),p,p+Vector2(1,-4),p+Vector2(4,-5),p+Vector2(5,-2)]),Color("ff6788"))
		draw_rect(Rect2(p+Vector2(-4,-5),Vector2(3,2)),Color("fff4d7"))
		draw_rect(Rect2(p+Vector2(-1,-2),Vector2(2,5)),Color("fff2df"))
		draw_rect(Rect2(p+Vector2(-3,0),Vector2(6,2)),Color("fff2df"))
	else:
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-10),p+Vector2(8,0),p+Vector2(0,10),p+Vector2(-8,0)]),outline)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-7),p+Vector2(6,0),p+Vector2(0,7),p+Vector2(-6,0)]),Color("5ce5ff"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-1,-6),p+Vector2(4,-1),p+Vector2(0,1),p+Vector2(2,6),p+Vector2(-4,0),p+Vector2(0,-2)]),Color("fff1b9"))
	draw_rect(Rect2(p+Vector2(-1,-13),Vector2(2,2)),Color("fff9e8"))
	draw_rect(Rect2(p+Vector2(11,0),Vector2(2,1)),Color("fff1d0"))

# A small two-tone halo follows Mafio's absorption/digestion state.
# Inspired by the split-dye fringe in the character design: self vs other.
# Visual only, behind no enemy bullets, with four small lights at most.
func draw_mafio_fusion(p):
	if p.character!=2 or p.down>0: return
	var digesting=clampf(float(p.digest)/maxf(.1,float(p.digest_total)),0.0,1.0)
	var flash=clampf(float(p.get("fusion_flash",0.0)),0.0,1.0)
	if digesting<=0.0 and flash<=0.0: return
	var opacity=minf(.75,.20+digesting*.23+flash*.38)
	var center: Vector2=p.pos
	var left=Color(.99,.83,.66,opacity)
	var right=Color(.65,.45,.95,opacity)
	draw_arc(center,16.0,PI*.5,PI*1.5,15,left,1.5)
	draw_arc(center,16.0,-PI*.5,PI*.5,15,right,1.5)
	# The moving seam carries swallowed technique energy through the cockpit.
	var progress=1.0-digesting if digesting>0 else 1.0-flash
	var offset=lerpf(-12.0,12.0,progress)
	draw_line(center+Vector2(offset,-9),center+Vector2(offset+3,8),Color(1.0,.96,.84,opacity),1.0)
	for n in range(4):
		var a=clock*3.0+float(n)*TAU/4.0
		var glint=center+Vector2(cos(a)*19.0,sin(a)*11.0)
		draw_rect(Rect2(glint,Vector2(2,2)),left if n%2==0 else right)

func _draw():
	background()
	if mode=="status":
		draw_status_screen()
		return
	if mode=="controls":
		draw_controls()
		return
	if mode=="menu":
		draw_menu()
		return
	if vertical.active and mode in ["play","pause","over"]:
		vertical.draw(self)
		if analysis_flash>0: draw_analysis_scan()
		draw_hud()
		if mode=="pause": centered("PAUSED / START TO RESUME",185,WHITE,2)
		if mode=="over": draw_result()
		return
	if shake>0: draw_set_transform(Vector2(randf_range(-shake,shake),randf_range(-shake,shake)))
	if bio_route: bio.draw_organs(self)
	if gate>0: draw_gate()
	for e in enemies:
		if bio_route and e.hp<=3 and players.any(func(p):return p.character==2): draw_arc(e.pos,24,0,TAU,16,Color("f0da9a"),1)
		var is_fan=e.get("technique","aimed")=="fan"
		# A pointed lance and a wide flowering interceptor read differently.
		if is_fan:
			draw_line(e.pos+Vector2(-19,0),e.pos+Vector2(-31,0),Color("ab5178"),2)
			draw_rect(Rect2(e.pos+Vector2(-27,-2),Vector2(3,3)),Color("ffd5a0"))
		else:
			draw_line(e.pos+Vector2(11,0),e.pos+Vector2(23,0),Color("7194b6"),2)
		var enemy_art=artwork.texture("enemy_bloom" if is_fan else "enemy_lance")
		if enemy_art!=null:
			draw_texture_rect(enemy_art,Rect2(e.pos-Vector2(17,11),Vector2(34,22)),false)
			if e.flash>0: draw_circle(e.pos,5,Color(1,1,1,.6))
		else:
			sprite(FOE_BLOOM if is_fan else FOE_LANCE,e.pos-Vector2(16,9),[Color("22213d"),Color("5e7390") if not is_fan else Color("8f456c"),Color("c9a5b3"),WHITE if e.flash>0 else Color("ffc37d")],2)
	for b in bullets:
		var tier=b.get("grade","normal")
		if str(tier).begins_with("charged_"):
			var bright=Color("ffeb9b") if tier=="charged_jackpot" else (Color("fcb0b8") if tier=="charged_normal" else Color("95889f"))
			draw_circle(b.pos,10,Color(bright.r,bright.g,bright.b,.2))
			draw_colored_polygon(PackedVector2Array([b.pos+Vector2(-16,0),b.pos+Vector2(-4,-6),b.pos+Vector2(13,0),b.pos+Vector2(-4,6)]),bright)
			draw_rect(Rect2(b.pos+Vector2(-8,-1),Vector2(13,2)),WHITE)
		elif tier=="jackpot":
			# The reward remains unmistakable, even at 640x360.
			draw_rect(Rect2(b.pos.x-16,b.pos.y-4,25,8),Color("ea4778"))
			draw_rect(Rect2(b.pos.x-12,b.pos.y-2,23,4),Color("ffe59b"))
			draw_rect(Rect2(b.pos.x+3,b.pos.y-1,7,2),WHITE)
			draw_rect(Rect2(b.pos.x-7,b.pos.y-7,3,2),Color("ffb6be"))
			draw_rect(Rect2(b.pos.x-3,b.pos.y+5,3,2),Color("ffb6be"))
		elif tier=="low":
			draw_rect(Rect2(b.pos.x-4,b.pos.y-1,7,2),COLORS[b.color])
			draw_rect(Rect2(b.pos.x+1,b.pos.y,3,1),WHITE)
		else:
			draw_rect(Rect2(b.pos.x-8,b.pos.y-2,13,4),COLORS[b.color])
			draw_rect(Rect2(b.pos.x,b.pos.y-1,6,2),WHITE)
	for s in shots:
		# Dangerous projectile: angular silhouette and bright core;
		# harmless petals are thinner, dimmer and fade.
		var q=s.pos
		var size=s.r+2
		draw_colored_polygon(PackedVector2Array([q+Vector2(-size,0),q+Vector2(0,-size),q+Vector2(size,0),q+Vector2(0,size)]),Color("542342"))
		draw_colored_polygon(PackedVector2Array([q+Vector2(-size+2,0),q+Vector2(0,-size+2),q+Vector2(size-2,0),q+Vector2(0,size-2)]),Color("ff7194"))
		draw_rect(Rect2(q-Vector2.ONE*1.5,Vector2(3,3)),Color("fff5d7"))
	for item in pickups:
		draw_collectible(item)
	if not boss.is_empty(): draw_boss()
	for i in range(players.size()):
		var p=players[i]
		if p.down>0:
			draw_rect(Rect2(p.pos-Vector2(7,5),Vector2(14,10)),COLORS[i],false,2)
			text_at("SOS",p.pos+Vector2(-8,-15),COLORS[i])
			draw_rect(Rect2(p.pos+Vector2(-12,11),Vector2(24*p.rescue/1.5,2)),WHITE)
		elif p.inv<=0 or int(clock*14)%2==0:
			ship(p.pos,COLORS[p.color],1,p.character)
			text_at(str(i+1),p.pos+Vector2(-5,-17),COLORS[i])
			# A small diamond marks the precise player hitbox.
			draw_rect(Rect2(p.pos-Vector2(1,1),Vector2(2,2)),COLORS[p.color])
		# During absorption and digestion, the two halves briefly converge.
		# Even if the invulnerability sprite blinks, its harmless halo remains.
		if bio_route: draw_mafio_fusion(p)
		if p.burst>0:
			draw_arc(p.pos,(.55-p.burst)*650,0,TAU,48,COLORS[p.color],2)
	for part in particles:
		var fade=clampf(float(part.life)/maxf(.05,float(part.get("max_life",.6))),0.0,1.0)
		var tint: Color=part.color
		tint.a=fade*.9
		if part.get("petal",false):
			draw_line(part.pos+Vector2(-3,2),part.pos+Vector2(2,-2),tint,2)
			draw_rect(Rect2(part.pos+Vector2(-1,-2),Vector2(2,2)),Color(1.0,.85,.73,fade*.8))
		else:
			draw_rect(Rect2(part.pos,Vector2(2,2)),tint)
	draw_set_transform(Vector2.ZERO)
	if analysis_flash>0: draw_analysis_scan()
	draw_hud()
	if notice_time>0:
		if notice.begins_with("SHIP DOWN"):
			draw_rect(Rect2(411,44,221,16),Color(.06,.08,.17,.88))
			draw_rect(Rect2(411,44,2,16),Color("ffb573"))
			text_at("ALLY DOWN / FIND SOS",Vector2(420,49),Color("ffe6bf"))
		else:
			draw_rect(Rect2(116,44,408,17),Color(.02,.04,.1,.88))
			centered(notice,49,COLORS[2])
	if mode=="pause":
		draw_rect(Rect2(0,0,W,H),Color(0,0,.04,.8))
		centered("PAUSED",125,WHITE,3)
		centered(notice,164,COLORS[2])
		centered("START / ENTER : RESUME",194)
		centered("Q : RETURN TO TITLE",213,DIM)
		centered("M : SOUND   F11 : FULLSCREEN",245,DIM)
		centered("TAB / X : PILOT STATUS",259,Color("eacb9c"))
		japanese("F2：コントローラー設定 / F6：音声テスト",Vector2(179,272))
	elif mode in ["clear","over"]: draw_result()

# Compact multi-pilot avionics. No Japanese names intrude into the battle area.
# A non-obscuring blue-white scanner overlay. Keep hostile bullets visible.
func draw_analysis_scan():
	var alpha=clampf(analysis_flash/.56,0.0,1.0)
	for n in range(11):
		var py=43+n*26.0
		draw_line(Vector2(0,py),Vector2(640,py),Color(.55,.91,1.0,.23*alpha),1)
	for n in range(17):
		var px=17+n*38.0
		draw_line(Vector2(px,44),Vector2(px,333),Color(.35,.82,1.0,.11*alpha),1)
	draw_rect(Rect2(4,42,632,292),Color(.72,.97,1.0,.45*alpha),false,2)
	text_at("ANALYSIS COMPLETE",Vector2(259,49),Color(.75,.96,1.0,alpha))
func draw_hud():
	draw_rect(Rect2(0,0,640,40),Color("08101e"))
	draw_rect(Rect2(0,39,640,1),Color("803951"))
	for i in range(count):
		var p=players[i]
		var x=7+i*143
		var accent=COLORS[i]
		draw_rect(Rect2(x,3,136,33),Color("111c30"))
		draw_rect(Rect2(x,3,136,33),Color("5a4054"),false,1)
		draw_rect(Rect2(x,3,28,2),accent)
		text_at("P"+str(i+1),Vector2(x+5,10),accent)
		japanese(PILOT_NAMES[p.character],Vector2(x+31,16),11,WHITE)
		if p.character==1 and p.down<=0:
			text_at("A"+str(enemy_analysis.count_observed()),Vector2(x+94,10),Color("c0f7ff"))
		if p.character==0 and p.down<=0:
			draw_rect(Rect2(x+94,34,29,2),Color("392c48"))
			draw_rect(Rect2(x+94,34,29.0*clampf(p.shot_hold/1.0,0,1),2),Color("ffcf77"))
		if p.character==0 and p.down<=0 and p.stability>0:
			text_at("S"+str(p.stability),Vector2(x+93,10),Color("ffe8af"))
		if p.character==2 and p.down<=0:
			# Hair motif / tech digestion marker: left self, right other.
			draw_rect(Rect2(x+100,7,5,3),Color("ffe1b2"))
			draw_rect(Rect2(x+105,7,5,3),Color("9a6ed8"))
			if p.digest>0:
				draw_rect(Rect2(x+100,12,10*(1.0-clampf(p.digest/maxf(.1,p.digest_total),0,1)),2),Color("d9faff"))
		if p.down>0:
			text_at("SOS",Vector2(x+103,10),Color("ffb77c"))
		else:
			draw_rect(Rect2(x+121,10,8,7),COLORS[p.color])
			draw_rect(Rect2(x+123,12,4,3),WHITE)
		for h in range(4):
			draw_rect(Rect2(x+6+h*15,21,12,6),Color("ff9ab2") if h<p.hp else Color("28334b"))
			if h<p.hp: draw_rect(Rect2(x+7+h*15,21,9,2),Color("ffe5dd"))
		draw_rect(Rect2(x+6,31,87,3),Color("26364a"))
		draw_rect(Rect2(x+6,31,87*clampf(p.charge/100.0,0,1),3),accent)
		if p.charge>=100 and p.down<=0: text_at("READY",Vector2(x+98,27),Color("ffe3a4"))
		elif p.down>0: text_at("RESCUE",Vector2(x+98,27),Color("ffaf82"))
		else: text_at(str(int(p.charge))+"%",Vector2(x+103,27),DIM)
	draw_rect(Rect2(444,3,190,33),Color("111a2c"))
	draw_rect(Rect2(444,3,190,33),Color("5a4054"),false,1)
	text_at("SCORE",Vector2(451,9),DIM)
	text_at("%07d"%score,Vector2(496,9),WHITE)
	text_at("STOCK "+str(reserves),Vector2(452,24),Color("ffce63"))
	text_at("COMBO X"+str(combo),Vector2(547,24),COLORS[0])
	draw_rect(Rect2(0,336,640,24),Color("08101e"))
	draw_rect(Rect2(0,336,640,1),Color("803951"))
	text_at("01 / RED ECHO" if bio_route else "01 / RUINS",Vector2(12,346),WHITE)
	if bio_route and count==1: japanese(Abilities.label(players[0],elapsed),Vector2(156,355),10,COLORS[0])
	text_at("M MUSIC "+("OFF" if muted else "ON"),Vector2(365,346),DIM)
	draw_rect(Rect2(502,347,124,4),Color("28374e"))
	draw_rect(Rect2(502,347,minf(124.0,travel/4800.0*124.0),4),Color("ef8c95"))
	text_at("STAGE",Vector2(554,354),DIM)

func draw_gate():
	var col=COLORS[1] if gate_flash>0 else Color("365878")
	draw_rect(Rect2(475,64,33,255),Color("172942"))
	draw_rect(Rect2(480,64,3,255),col)
	for y in range(65,320,9): draw_rect(Rect2(508,y,110,2),Color("29304f"))
	for i in range(3):
		var pos=Vector2(490,100+i*80)
		var active=gate_lights[i]>0
		draw_rect(Rect2(pos-Vector2(18,19),Vector2(36,38)),COLORS[i],false,2)
		draw_rect(Rect2(pos-Vector2(11,12),Vector2(22,24)),COLORS[i] if active else Color("14243b"))
		text_at(["C","R","G"][i],pos-Vector2(2,3),Color("14243b") if active else COLORS[i])
		text_at(str(gate_order.find(i)+1) if gate==1 else "SYNC",pos+Vector2(30,-3),COLORS[i])
		if gate==1 and gate_step<3 and gate_order[gate_step]==i: text_at(">",pos-Vector2(33,3),WHITE)
		if gate==2 and active: draw_rect(Rect2(pos+Vector2(-18,23),Vector2(36*gate_lights[i]/7.5,3)),COLORS[i])
	text_at("X : CHANGE COLOR",Vector2(330,303),WHITE)
	if gate==1: text_at("ROSE > CYAN > GOLD",Vector2(330,316),COLORS[2])
	else: text_at("KEEP ALL RELAYS LIT",Vector2(330,316),COLORS[2])

func draw_boss():
	if bio_route:
		bio.draw_boss(self)
		return
	var p=boss.pos
	var col=COLORS[boss.color]
	for side in [-1,1]:
		draw_rect(Rect2(p+Vector2(-10,side*51-10),Vector2(75,20)),Color("4c426f"))
		draw_rect(Rect2(p+Vector2(-26,side*46-8),Vector2(37,16)),Color("8895b9"))
		draw_rect(Rect2(p+Vector2(-30,side*46-3),Vector2(10,6)),col)
	draw_rect(Rect2(p+Vector2(-12,-36),Vector2(67,72)),Color("5a507d"))
	draw_rect(Rect2(p+Vector2(-25,-27),Vector2(67,54)),Color("9395b9"))
	draw_rect(Rect2(p+Vector2(-32,-20),Vector2(65,40)),Color("33355a"))
	draw_rect(Rect2(p+Vector2(-36,-13),Vector2(22,26)),WHITE if boss.flash>0 else col)
	draw_rect(Rect2(p+Vector2(-30,-7),Vector2(10,14)),WHITE)
	for j in range(4): draw_rect(Rect2(p+Vector2(42,-24+j*16),Vector2(15,7)),Color("232c4d"))
	# Stepped armor, illuminated conduits and exposed vents keep the silhouette pixel-native.
	for side in [-1,1]:
		for j in range(4):
			draw_rect(Rect2(p+Vector2(j*13-8,side*61-3),Vector2(10,6)),Color("6d6f99"))
		draw_rect(Rect2(p+Vector2(48,side*53-7),Vector2(18,14)),Color("b6bad2"))
		draw_rect(Rect2(p+Vector2(50,side*53-3),Vector2(12,6)),Color("3c4168"))
		draw_rect(Rect2(p+Vector2(-17,side*22-1),Vector2(45,2)),Color("c9d0e0"))
	for j in range(4):
		draw_rect(Rect2(p+Vector2(2+j*7,-12),Vector2(3,24)),Color("252a48"))
		draw_rect(Rect2(p+Vector2(3+j*7,-6),Vector2(1,12)),col.darkened(.5))
	draw_rect(Rect2(p+Vector2(28,-29),Vector2(8,5)),col)
	draw_rect(Rect2(p+Vector2(28,24),Vector2(8,5)),col)
	draw_arc(p,44,PI*.6,PI*1.4,16,col,2)
	text_at("PRISM SENTINEL / MATCH ITS CORE COLOR",Vector2(193,70),col)
	draw_rect(Rect2(193,82,360,4),Color("302b4c"))
	draw_rect(Rect2(193,82,360*maxf(0,boss.hp)/boss.max,4),col)

func draw_menu():
	text_at("AN ORIGINAL CO-OP ARCADE SHOOTER",Vector2(22,20),DIM)
	text_at("LOCAL 1-3P",Vector2(552,20),COLORS[0])
	japanese("F3：ルート切替 / "+("赤い残響・生体試作" if bio_route else "共鳴遺跡・従来試作"),Vector2(22,43),12,COLORS[2])
	# A user-supplied or original PNG logo overrides the procedural plate.
	# Keep the fallback if the asset has not been imported into Godot yet.
	var logo=artwork.texture("title_logo")
	if logo!=null:
		draw_texture_rect(logo,Rect2(122,64,396,82),false)
	else:
		draw_rect(Rect2(125,66,390,80),Color("0d1227"))
		draw_rect(Rect2(125,66,390,80),Color("946b66"),false,2)
		draw_rect(Rect2(131,72,378,2),Color("e39b7b"))
		draw_rect(Rect2(132,139,376,2),Color("63253e"))
		for j in range(10):
			var ray_x=147+j*37
			draw_line(Vector2(ray_x,78),Vector2(ray_x+17,94),Color(.89,.24,.35,.25),1)
		japanese("曼珠沙華",Vector2(227,107),48,Color("45142e"))
		japanese("曼珠沙華",Vector2(222,103),48,Color("e7455f"))
		japanese("曼珠沙華",Vector2(219,99),48,Color("f1f0e6"))
		centered("MANJUSHAGE",122,Color("f2bfa3"),2)
	japanese("F4 / X：先頭 "+PILOT_NAMES[pilot_offset],Vector2(207,155),13,COLORS[2])
	japanese("F5：縦区間 "+("ON" if mixed_scroll else "OFF")+"   F8：新曲 "+("ON" if new_music else "OFF"),Vector2(185,202),11,WHITE)
	ship(Vector2(319,181),COLORS[0],2,pilot_offset)
	ship(Vector2(240,180),COLORS[1],1,(pilot_offset+1)%3)
	ship(Vector2(397,180),COLORS[2],1,(pilot_offset+2)%3)
	centered("<   "+str(count)+" PILOT"+("S" if count>1 else " ")+"   >",216,WHITE,2)
	draw_rect(Rect2(220,239,200,28),COLORS[0])
	centered("LAUNCH SQUAD",249,Color("0a1830"),1)
	japanese("左右で人数選択 / A または Enter で出撃",Vector2(189,282),13,WHITE)
	centered("GAMEPADS "+str(Input.get_connected_joypads().size())+" / BGM "+("OFF" if muted else ("ON" if music.playing else "ERROR"))+" / F6 AUDIO TEST",294,COLORS[2])
	japanese("F2：十字キー・ボタン設定（クリック可）",Vector2(193,321),12,COLORS[0])
	text_at("Z SHOT  X COLOR  C BURST",Vector2(22,328),DIM)
	text_at("H HOW TO PLAY",Vector2(282,328),WHITE)
	text_at("HI %07d"%high_scores[count-1],Vector2(510,328),COLORS[0])
	text_at("PROTOTYPE 0.8 / ART PASS 01",Vector2(22,345),Color("71849b"))
	japanese("F6：音声テスト / F7：出力切替",Vector2(205,353),11,DIM)
	text_at("F11 FULLSCREEN",Vector2(540,345),Color("3e536f"))
	if show_help:
		draw_rect(Rect2(45,42,550,270),Color("0c162c"))
		draw_rect(Rect2(45,42,550,270),COLORS[0],false,1)
		centered("FLIGHT MANUAL",60,COLORS[0],2)
		var lines=["GAMEPAD : STICK / D-PAD MOVE", "A / RT : SHOT   X : COLOR   B : BURST", "START : PAUSE   LEFT / RIGHT : PLAYER COUNT", "", "P1 : ARROWS    Z SHOT / X COLOR / C BURST", "P2 : W A S D   R SHOT / F COLOR / G BURST", "P3 : I J K L   U SHOT / O COLOR / N BURST", "", "MATCH THE RELAY COLOR AND SHOOT ITS CORE.", "APPROACH A DOWNED ALLY FOR 1.5S TO RESCUE.", "BURST CLEARS BULLETS. ENERGY REFILLS OVER TIME.", "1 HIT = 1 HULL. SOLO RESPAWNS USE RESERVES."]
		for i in range(lines.size()): text_at(lines[i],Vector2(69,92+i*15),WHITE if i<7 else DIM)
		centered("H : CLOSE / ENTER : LAUNCH",290,COLORS[2])
		if bio_route: japanese("マフィオ：弱った輪付きの敵へ近づき、C / Bで捕食（40ゲージ）",Vector2(67,307),11,COLORS[2])
	if notice_time>0: japanese(notice,Vector2(16,60),12,COLORS[2])

func draw_controls():
	centered("CONTROLLER SETUP",47,COLORS[0],2)
	japanese("十字キーとボタンを、このコントローラー用に登録します",Vector2(121,85),14)
	japanese(str(calibration_step+1)+" / 8   "+CONTROL_LABELS[calibration_step]+" を押してください",Vector2(170,137),18,COLORS[2])
	japanese("スティックではなく、使いたい十字キーを押してください",Vector2(129,169),13,DIM)
	japanese("1回押したら離し、次の指示に進んでください",Vector2(160,193),13,DIM)
	if calibration_device>=0:
		japanese(Input.get_joy_name(calibration_device),Vector2(175,229),14,COLORS[0])
		text_at("DEVICE "+str(calibration_device+1),Vector2(282,245),DIM)
	japanese("Esc：キャンセル（元の設定を維持）",Vector2(203,292),13)
	japanese("登録完了後は、決定ボタンを一度離してください",Vector2(167,318),12,DIM)

func draw_result():
	draw_rect(Rect2(0,0,W,H),Color(0.015,.025,.08,.9))
	centered("SECTOR CLEAR" if mode=="clear" else "SIGNAL LOST",83,COLORS[0] if mode=="clear" else COLORS[1],3)
	if bio_route and mode=="clear":
		japanese("記憶の断片・仮稿：赤い光の向こうに、道が続いていた。",Vector2(96,126),13,WHITE)
	else: centered("THE RELAY SINGS AGAIN" if mode=="clear" else "REGROUP. RELOAD. RETURN.",119,DIM)
	centered("%07d"%score,153,WHITE,4)
	centered(str(count)+" PILOTS / "+str(gates_done)+" RELAYS / "+str(int(elapsed))+" SECONDS",198,COLORS[2])
	centered("LOCAL BEST  %07d"%high_scores[count-1],223,DIM)
	centered("ENTER / A : FLY AGAIN",269,WHITE)
	centered("ESC : TITLE",289,DIM)


# STATUS-001: All pilots share identical HP/heart language, while the rest
# of the page is entirely separate avionics. TAB or pause-pad X opens.
func draw_status_screen():
	if players.is_empty(): return
	status_slot=clampi(status_slot,0,players.size()-1)
	var p=players[status_slot]
	var char_id=int(p.character)
	var accents=[Color("ee618c"),Color("68c8f4"),Color("f4c974")]
	var bg=[Color("221322"),Color("071c32"),Color("211a25")][char_id]
	var accent=accents[char_id]
	draw_rect(Rect2(0,0,640,360),bg)
	draw_rect(Rect2(0,0,640,4),accent)
	for j in range(21):
		draw_line(Vector2(j*32,42),Vector2(j*32,320),Color(accent.r,accent.g,accent.b,.045),1.0)
	japanese(PILOT_NAMES[char_id],Vector2(24,32),23,WHITE)
	text_at("P"+str(status_slot+1),Vector2(218,21),accent,2)
	# Invariant shared HP interface: same icon sizes, colors, layout across pilots.
	japanese("ライフ",Vector2(306,24),12,WHITE)
	for h in range(4):
		var c=Color("ff8fa7") if h<int(p.hp) else Color("3c425a")
		draw_colored_polygon(PackedVector2Array([
			Vector2(370+h*18,14),Vector2(374+h*18,10),
			Vector2(378+h*18,14),Vector2(382+h*18,10),
			Vector2(386+h*18,14),Vector2(378+h*18,23)
		]),c)
	draw_line(Vector2(22,41),Vector2(617,41),accent,2)
	if archive_page and char_id==2:
		draw_mafio_archive()
	elif char_id==0:
		draw_cormii_status(p)
	elif char_id==1:
		draw_jiyoza_status(p)
	else:
		draw_mafio_status(p)
	text_at("TAB / START : BACK     LEFT / RIGHT : PILOT",Vector2(27,342),accent)

func draw_cormii_status(p):
	japanese("確率変動・出力抽選",Vector2(29,71),20,Color("ffd7d9"))
	var stabil=clampi(int(p.get("stability",0)),0,3)
	var chances=[25,13,6,2]
	var jackpots=[20,21,20,20]
	var low_chance=chances[stabil]
	japanese("確率安定コア  "+str(stabil)+"/3",Vector2(30,105),15,Color("ffe6aa"))
	for i in range(3):
		var x=42+i*185
		var tint=[Color("5f3e57"),Color("bd5374"),Color("ffbb70")][i]
		draw_rect(Rect2(x,124,167,148),Color("3f2436"))
		draw_rect(Rect2(x,124,167,148),tint,false,2)
		text_at(["LOW","NORMAL","JACKPOT"][i],Vector2(x+17,143),tint,2)
		draw_circle(Vector2(x+80,201),28,tint.darkened(.35))
		draw_arc(Vector2(x+80,201),26,-PI*.6,PI*.6,20,tint,3)
		japanese(["弱威力","通常威力","大当たり！"][i],Vector2(x+45,249),14,WHITE)
		var chance=[low_chance,80-low_chance,20][i]
		text_at(str(chance)+"%",Vector2(x+63,169),Color("fff2de"),2)
	japanese("強い一撃は残し、低威力の確率を減らす",Vector2(114,308),15,WHITE)

func draw_jiyoza_status(p):
	japanese("解析端末 / 精密・漸進成長",Vector2(29,71),19,Color("b6efff"))
	for n in range(11):
		draw_line(Vector2(40+n*54,100),Vector2(40+n*54,298),Color("1c5673"),1)
	for n in range(8):
		draw_line(Vector2(40,100+n*27),Vector2(603,100+n*27),Color("1c5673"),1)
	var level_now=Abilities.level(p)+1
	text_at("ANALYSIS LV "+str(level_now),Vector2(55,119),Color("a4e8ff"),2)
	for n in range(12):
		draw_rect(Rect2(55+n*42,162,32,15),Color("50d8ed") if n<mini(12,int(p.experience)) else Color("183e60"))
	for m in range(4):
		draw_line(Vector2(80+m*55,234),Vector2(245+m*55,210),Color(.40,.79,.96,.45),2)
	draw_arc(Vector2(505,227),57,0,TAU,40,Color("3f81ad"),1)
	draw_arc(Vector2(505,227),45,0,TAU*float(level_now)/4.0,40,Color("c6f5ff"),3)
	draw_line(Vector2(449,227),Vector2(561,227),Color("7ddfeb"),1)
	draw_line(Vector2(505,168),Vector2(505,286),Color("7ddfeb"),1)
	japanese("取得経験 "+str(p.experience),Vector2(56,283),15,WHITE)
	japanese("記録した敵種 "+str(enemy_analysis.count_observed()),Vector2(298,299),12,Color("b0e8f5"))
	japanese("解析精度と出力が着実に上がる",Vector2(58,306),14,Color("a9d8e7"))

func draw_mafio_status(p):
	japanese("融合器官 / 捕食・消化・変異",Vector2(29,71),19,Color("ffe3b6"))
	draw_rect(Rect2(32,90,286,203),Color("34262f"))
	draw_rect(Rect2(318,90,284,203),Color("2c2448"))
	draw_line(Vector2(318,90),Vector2(318,293),Color("fff0d0"),2)
	for n in range(6):
		var y=111+n*25
		draw_arc(Vector2(321,y),16,-PI/2,PI/2,12,Color("e9b7ff"),1)
	var progress=1.0-clampf(float(p.digest)/maxf(.1,float(p.digest_total)),0,1)
	draw_arc(Vector2(319,182),66,0,TAU,40,Color("e1cfaf"),2)
	draw_arc(Vector2(319,182),65,-PI/2,-PI/2+progress*TAU,40,Color("9addff"),4)
	japanese("現在の技",Vector2(61,127),15,WHITE)
	japanese("基本弾" if str(p.learned)=="none" else ("拡散弾" if str(p.learned)=="fan" else "狙い撃ち"),Vector2(61,170),20,Color("ffe5b4"))
	japanese("残り "+str(snappedf(p.digest,.1))+" 秒",Vector2(382,150),17,WHITE)
	japanese("捕食記録  "+str(mafio_archive.total_unlocked())+"/"+str(MafioArchive.ENTRIES.size()),Vector2(365,213),15,WHITE)
	text_at("E / X : ENEMY ARCHIVE",Vector2(344,262),Color("d5baf6"))
	japanese("敵の技を食べて、自分の力へ変える",Vector2(150,316),14,WHITE)

func draw_mafio_archive():
	japanese("マフィオの捕食図鑑",Vector2(23,72),20,Color("fff0d4"))
	text_at("E / X : STATUS",Vector2(474,64),Color("e0b8fc"))
	var entries=MafioArchive.ENTRIES
	var index=clampi(archive_cursor,0,entries.size()-1)
	archive_cursor=index
	var first=clampi(index-3,0,maxi(0,entries.size()-8))
	for i in range(8):
		var j=first+i
		if j>=entries.size(): break
		var item=entries[j]
		var unlocked=mafio_archive.unlocked(str(item.id))
		var row_y=91+i*28
		if j==index:
			draw_rect(Rect2(18,row_y-15,298,26),Color("5b3e59"))
			draw_rect(Rect2(18,row_y-15,3,26),Color("f5c979"))
		japanese(str(item.id)+"  "+(str(item.name) if unlocked else "？？？？？"),Vector2(28,row_y),14,WHITE if unlocked else Color("76849c"))
		if unlocked:
			text_at("x"+str(mafio_archive.captured.get(str(item.id),0)),Vector2(259,row_y-7),Color("aee7ec"))
	draw_rect(Rect2(326,77,295,245),Color("1b233b"))
	draw_rect(Rect2(326,77,295,245),Color("c8a8ce"),false,1)
	var chosen=entries[index]
	if mafio_archive.unlocked(str(chosen.id)):
		japanese(str(chosen.name),Vector2(349,107),21,Color("ffe4bd"))
		draw_circle(Vector2(472,168),35,Color("544066"))
		draw_arc(Vector2(472,168),30,0,TAU,24,Color("edc785"),2)
		draw_colored_polygon(PackedVector2Array([Vector2(472,143),Vector2(489,174),Vector2(456,174)]),Color("9fbcf5"))
		japanese("敵の攻撃："+str(chosen.attack),Vector2(343,239),13,WHITE)
		japanese("習得技："+str(chosen.ability),Vector2(343,266),13,Color("d8b4fc"))
		japanese("捕食："+str(mafio_archive.captured.get(str(chosen.id),0))+" 回",Vector2(343,295),12,WHITE)
	else:
		text_at("UNKNOWN",Vector2(371,128),Color("72809d"),2)
		draw_circle(Vector2(472,185),43,Color("30344a"))
		japanese("未捕食・詳細不明",Vector2(380,277),16,Color("91a1b7"))
	text_at("UP / DOWN : SELECT",Vector2(355,310),Color("a5aac0"))

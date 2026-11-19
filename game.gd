extends Node2D

const W = 640.0
const H = 360.0
const COLORS = [Color("67ecff"), Color("ff668e"), Color("ffce63")]
const WHITE = Color("e5f5ff")
const DIM = Color("617797")
const SHIP = ["...........11.............", "......11111221............", "..11112222222211..........", "..1333332222222211........", "1112222222444422221111....", "1222222244444422222222111.", "1112222222222222221111....", "..1333332222222211........", "..11112222222211..........", "......11111221............", "...........11............."]
const FOE = ["..11........11..", ".1221......1221.", "1222211111122221", ".12223333332221.", "..123344443321..", "1112334444332111", ".12223333332221.", "1222211111122221", ".1221......1221.", "..11........11.."]
const FONT = {
"A":"01110/10001/10001/11111/10001/10001/10001", "B":"11110/10001/10001/11110/10001/10001/11110", "C":"01111/10000/10000/10000/10000/10000/01111", "D":"11110/10001/10001/10001/10001/10001/11110", "E":"11111/10000/10000/11110/10000/10000/11111", "F":"11111/10000/10000/11110/10000/10000/10000", "G":"01111/10000/10000/10111/10001/10001/01111", "H":"10001/10001/10001/11111/10001/10001/10001", "I":"11111/00100/00100/00100/00100/00100/11111", "J":"00111/00010/00010/00010/10010/10010/01100", "K":"10001/10010/10100/11000/10100/10010/10001", "L":"10000/10000/10000/10000/10000/10000/11111", "M":"10001/11011/10101/10101/10001/10001/10001", "N":"10001/11001/11001/10101/10011/10011/10001", "O":"01110/10001/10001/10001/10001/10001/01110", "P":"11110/10001/10001/11110/10000/10000/10000", "Q":"01110/10001/10001/10001/10101/10010/01101", "R":"11110/10001/10001/11110/10100/10010/10001", "S":"01111/10000/10000/01110/00001/00001/11110", "T":"11111/00100/00100/00100/00100/00100/00100", "U":"10001/10001/10001/10001/10001/10001/01110", "V":"10001/10001/10001/10001/10001/01010/00100", "W":"10001/10001/10001/10101/10101/10101/01010", "X":"10001/10001/01010/00100/01010/10001/10001", "Y":"10001/10001/01010/00100/00100/00100/00100", "Z":"11111/00001/00010/00100/01000/10000/11111", "0":"01110/10001/10011/10101/11001/10001/01110", "1":"00100/01100/00100/00100/00100/00100/01110", "2":"01110/10001/00001/00010/00100/01000/11111", "3":"11110/00001/00001/01110/00001/00001/11110", "4":"00010/00110/01010/10010/11111/00010/00010", "5":"11111/10000/10000/11110/00001/00001/11110", "6":"01110/10000/10000/11110/10001/10001/01110", "7":"11111/00001/00010/00100/01000/01000/01000", "8":"01110/10001/10001/01110/10001/10001/01110", "9":"01110/10001/10001/01111/00001/00001/01110", ":":"00000/00100/00100/00000/00100/00100/00000", ".":"00000/00000/00000/00000/00000/00110/00110", "-":"00000/00000/00000/11111/00000/00000/00000", "+":"00000/00100/00100/11111/00100/00100/00000", "/":"00001/00010/00010/00100/01000/01000/10000", "<":"00010/00100/01000/10000/01000/00100/00010", ">":"01000/00100/00010/00001/00010/00100/01000", "!":"00100/00100/00100/00100/00100/00000/00100", "?":"01110/10001/00001/00010/00100/00000/00100"
}

const Visual=preload("res://visual_v09.gd")
var visual=Visual.new()
var art_v09=true
var slice_mode=true
var aftermath=0.0
var result_delay=0.0
var sound_cooldowns={}
var planet_texture: ImageTexture
var title_logo: Texture2D
var title_logo_extended: Texture2D
var launch_button: Texture2D
# The UI atlas is a user-provided Chat asset.  It is intentionally loaded as a
# single source image so later revisions can replace it without changing game
# logic or the saved control/menu state.
var chat_ui_atlas: Texture2D
# User-approved protagonist visual boards.  Only their portrait, colour, and
# interface language are presented at runtime; printed board values remain
# reference material and never replace live combat/save data.
var character_hub_ui: Texture2D
var character_system_ui: Texture2D
const Abilities=preload("res://pilot_abilities.gd")
const MafioArchive=preload("res://mafio_archive.gd")
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
	DisplayServer.window_set_title("曼珠沙華（MANJUSHAGE）")
	randomize()
	visual.setup()
	mafio_archive.load_data()
	# Adopt the GitHub main title art when it is present.  The old drawn mark remains
	# as a safe fallback for earlier checkouts and incomplete asset packages.
	# This source tree is deliberately usable without a pre-generated .godot import
	# cache, so load PNGs as images rather than depending on Texture2D import.
	title_logo=image_texture_from_file("res://art/active/title_logo.png")
	title_logo_extended=image_texture_from_file("res://art/ui/title_logo_extended_v01.png")
	launch_button=image_texture_from_file("res://art/ui/launch_button_v01.png")
	chat_ui_atlas=image_texture_from_file("res://art/ui/chat_ui_atlas_20261106.png")
	character_hub_ui=image_texture_from_file("res://art/ui/character_hub_ui_20261106.png")
	character_system_ui=image_texture_from_file("res://art/ui/character_system_ui_20261106.png")
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
	for name in ["shot","switch","hit","burst","gate","pickup","pulse_v09","lance_v09","spore_v09","impact_v09","break_small_v09","break_medium_v09","break_boss_v09","consume_v09"]:
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
		if arg == "--legacy": bio_route=false;slice_mode=false
		if arg == "--bio": bio_route=true
		if arg.begins_with("--pilot="): pilot_offset=clampi(int(arg.substr(8)),0,2)
		if arg=="--new-music":new_music=true
		if arg == "--autotest": auto_test = true;slice_mode=false
		if arg.begins_with("--players="): test_count = clampi(int(arg.substr(10)),1,3)
		if arg.begins_with("--shot="): screenshot_mode = arg.substr(7)
	if OS.get_cmdline_user_args().has("--slice"):slice_mode=true
	if OS.get_cmdline_user_args().has("--classic"):slice_mode=false
	if OS.get_cmdline_user_args().has("--old-art"):art_v09=false
	var visual_cfg=ConfigFile.new()
	if visual_cfg.load("user://visual.cfg")==OK:
		visual.intensity=clampf(visual_cfg.get_value("v","shake",1.0),0,1)
		visual.flash_level=clampf(visual_cfg.get_value("v","flash",.35),0,1)
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
		if screenshot_mode == "encounter":
			# Capture-only encounter: it places the real wave organisms inside the
			# frame with their normal movement/shot data. No player save is touched.
			enemies.clear()
			wave_id=3
			spawn_wave()
			for i in range(enemies.size()):
				enemies[i].pos.x=438+i*34
				enemies[i].cool=.34+i*.045
		if screenshot_mode == "status": mode="status"
		if screenshot_mode == "archive":
			mode="status"
			for i in range(players.size()):
				if players[i].character==2: status_slot=i
			archive_page=true
			# Capture-only sample data: never persisted, used to verify the real
			# archive presentation in a packed Windows build.
			mafio_archive.captured={"P-002":3,"P-003":1,"P-005":2}
			archive_cursor=1
		for pilot in players: pilot.inv=0
	queue_redraw()

func image_texture_from_file(path:String)->Texture2D:
	var image=Image.load_from_file(path)
	return ImageTexture.create_from_image(image) if image and not image.is_empty() else null

func draw_chat_ui_region(source:Rect2,target:Rect2,modulate:=Color.WHITE):
	if chat_ui_atlas:
		draw_texture_rect_region(chat_ui_atlas,target,source,modulate)

# VIS-021 — Direct user-approved visual basis for the three protagonists.
# The crop is deliberately portrait-only: board dialogue, exact numbers, and
# menu wording are not inferred as canon or copied into the live interface.
func draw_fixed_pilot_visual(char_id:int,accent:Color):
	if not character_system_ui: return
	var sources=[Rect2(10,62,245,326),Rect2(562,62,236,326),Rect2(1095,62,240,326)]
	var panel=Rect2(438,55,180,183)
	draw_rect(panel,Color("080d1c",.92))
	draw_texture_rect_region(character_system_ui,Rect2(447,59,162,169),sources[char_id])
	draw_rect(panel,Color(accent.r,accent.g,accent.b,.92),false,2)
	draw_rect(Rect2(447,211,162,17),Color("101525",.82))
	japanese("LIVE PROFILE / "+PILOT_NAMES[char_id],Vector2(453,224),9,accent)

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
	if art_v09 and bio_route:
		if name=="hit":name="impact_v09"
		elif name=="shot":name="pulse_v09"
		if sound_cooldowns.get(name,0)>0:return
		sound_cooldowns[name]=.045 if name=="impact_v09" else .025
	if muted or auto_test: return
	for player in sfx_pool:
		if not player.playing:
			player.volume_db=-10 if name in ["pulse_v09","lance_v09","spore_v09","impact_v09"] else -6
			player.stream = sounds[name]
			player.play()
			return

func track(name):
	if music.playing and not auto_test:
		var tail=AudioStreamPlayer.new()
		tail.stream=music.stream;tail.volume_db=music.volume_db
		add_child(tail);tail.play(music.get_playback_position())
		var fade=create_tween()
		fade.tween_property(tail,"volume_db",-45,.25)
		fade.tween_callback(tail.queue_free)
	if name=="wistful_demo" and not ResourceLoader.exists("res://audio/wistful_demo.wav"):
		name="ruins" if mode=="play" else "title"
		tell("NEW MUSIC NOT BUILT / USING ORIGINAL",5)
	if art_v09 and bio_route and slice_mode:
		if name in ["ruins","wistful_demo"]:name="red_echo_v09"
		elif name=="sentinel":name="red_echo_boss_v09"
	music_name=name
	music.volume_db=1.5 if name.begins_with("red_echo") else -3
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
	vertical.duration=12.0 if slice_mode else 24.0
	aftermath=0;result_delay=0;visual.blasts.clear()
	pads = Array(Input.get_connected_joypads())
	players.clear(); bullets.clear(); shots.clear(); enemies.clear(); pickups.clear(); particles.clear()
	travel = 0; elapsed = 0; wave_id = 0; wave_timer = 4.0 if slice_mode else 1.5; score = 0
	reserves = count*3; combo = 1; combo_time = 0; gate = 0; gates_done = 0; boss = {}
	for i in range(count):
		players.append({"pos":Vector2(100-i*23,110+i*65),"color":i,"hp":4,"cool":0.0,"inv":2.0,"down":0.0,"rescue":0.0,"charge":100.0,"burst":0.0})
	for i in range(count): Abilities.initialize(players[i],(i+pilot_offset)%3)
	mode = "play"
	show_help = false
	track("wistful_demo" if new_music else "ruins")
	tell("第一境界：赤い残響（試作）" if bio_route else "旧試作：共鳴遺跡",4)

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
			if key in [KEY_ESCAPE,KEY_TAB,KEY_ENTER,KEY_SPACE]:
				mode=status_return_mode
			elif key in [KEY_LEFT,KEY_A]:
				status_slot=(status_slot+players.size()-1)%maxi(1,players.size()); archive_page=false
			elif key in [KEY_RIGHT,KEY_D]:
				status_slot=(status_slot+1)%maxi(1,players.size()); archive_page=false
			elif key==KEY_E and players[status_slot].character==2:
				archive_page=not archive_page
			elif key==KEY_UP and archive_page:
				archive_cursor=maxi(0,archive_cursor-1)
			elif key==KEY_DOWN and archive_page:
				archive_cursor=mini(MafioArchive.ENTRIES.size()-1,archive_cursor+1)
			return
		if key==KEY_TAB and mode in ["play","pause"]:
			status_return_mode=mode; mode="status"; status_slot=0; archive_page=false
			return
		if key==KEY_F9 and mode=="menu":slice_mode=not slice_mode;return
		if key in [KEY_F10,KEY_F12]:
			if key==KEY_F10:visual.intensity=0.0 if visual.intensity>0 else 1.0
			else:visual.flash_level=0.0 if visual.flash_level>0 else .35
			var cfg=ConfigFile.new()
			cfg.set_value("v","shake",visual.intensity);cfg.set_value("v","flash",visual.flash_level)
			cfg.save("user://visual.cfg")
			return
		if key==KEY_F4 and mode=="menu": pilot_offset=(pilot_offset+1)%3; return
		if key==KEY_F5 and mode=="menu": mixed_scroll=not mixed_scroll; return
		if key==KEY_F8 and mode=="menu":
			new_music=not new_music
			track("wistful_demo" if new_music else "title")
			return
		if key==KEY_F3 and mode=="menu":
			bio_route=not bio_route
			if not bio_route:slice_mode=false
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
			if mode == "clear" and key == KEY_N and result_delay <= 0.0:
				launch_next_stage()
			elif key in [KEY_ENTER,KEY_SPACE]: start_game()
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

func _process(dt):
	clock += dt
	position=Vector2(sin(clock*71),cos(clock*83))*minf(2,shake)*visual.intensity if art_v09 and bio_route and mode=="play" else Vector2.ZERO
	if mode!="pause":visual.update(dt)
	for sound in sound_cooldowns:sound_cooldowns[sound]=maxf(0,sound_cooldowns[sound]-dt)
	if result_delay>0:result_delay=maxf(0,result_delay-dt)
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
			if b: bio_route=not bio_route;slice_mode=bio_route
			if start or a: start_game()
		elif mode == "play":
			if start: mode="pause"; notice="FLIGHT PAUSED"
			var slot = pads.find(device)
			if slot >= 0 and slot < count:
				if x: change_color(slot)
				if b: burst(slot)
		elif mode == "pause":
			if x: status_return_mode="pause"; status_slot=0; archive_page=false; mode="status"
			elif start or a: mode="play"
		elif mode == "status":
			if start or b: mode=status_return_mode
			elif left: status_slot=(status_slot+players.size()-1)%maxi(1,players.size()); archive_page=false
			elif right: status_slot=(status_slot+1)%maxi(1,players.size()); archive_page=false
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
	if slice_mode and aftermath>0:
		aftermath+=dt
		shots.clear();bullets.clear()
		if aftermath>=3.0:finish(true)
		return
	if slice_mode:
		if elapsed<34:travel=elapsed*55
		elif mixed_scroll and not vertical.done:travel=3100
		elif elapsed<55:travel=3700+(elapsed-46)*95
		if elapsed>=55 and boss.is_empty():begin_boss()
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
		Abilities.digest(p,dt)
		p.cool-=dt; p.inv-=dt; p.burst=maxf(0,p.burst-dt)
		p.charge=minf(100,p.charge+dt*2)
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
		p.motion=input[0]
		p.pos+=input[0]*155*dt
		p.pos.x=clampf(p.pos.x,18,440 if gate>0 else 605)
		p.pos.y=clampf(p.pos.y,48,320)
		if input[1] and p.cool<=0:
			p.cool=.13
			var velocities=Abilities.velocities(p,Vector2.RIGHT,enemies) if bio_route else [Vector2(390,0)]
			for velocity in velocities:
				bullets.append({"pos":p.pos+Vector2(18,0),"color":p.color,"owner":i,"vel":velocity,"damage":Abilities.damage(p,elapsed) if bio_route else 1.0})
			if art_v09 and bio_route:sfx(["pulse_v09","lance_v09","spore_v09"][p.character])
			elif i==0:sfx("shot")
	var alive=players.any(func(p): return p.down==0)
	if not alive and reserves==0:
		finish(false)
		return
	if gate==0 and boss.is_empty():
		if not slice_mode and travel>=1400 and gates_done==0: begin_gate(1)
		elif not slice_mode and travel>=3000 and gates_done==1: begin_gate(2)
		elif not slice_mode and travel>=4800: begin_boss()
		else:
			wave_timer-=dt
			if wave_timer<=0:
				spawn_wave(); wave_timer=3.2 if slice_mode else 2.5
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
				visual.hit(bullet.pos)
				e.hp-=bullet.get("damage",1.0); e.flash=.08; bullet.pos.x=800; sfx("hit")
		if bio_route and not boss.is_empty() and bio.intercept(self,bullet): continue
		if not boss.is_empty() and bullet.pos.distance_to(boss.pos)<38:
			visual.hit(bullet.pos)
			if bullet.color==boss.color and (not bio_route or bio.exposed()):
				boss.hp-=bullet.get("damage",1.0); boss.flash=.07; sfx("hit")
			bullet.pos.x=800
	bullets=bullets.filter(func(b):return b.pos.x<700 and b.pos.y>30 and b.pos.y<340)
	for e in enemies:
		e.age+=dt; e.flash=maxf(0,e.flash-dt)
		var motion=e.get("technique","aimed")
		# Each organism has a readable, repeatable route before its shot telegraph.
		if motion=="fan":
			e.pos.x-=e.speed*dt
			e.pos.y=e.base+sin(e.age*2.3+e.phase)*e.amplitude
		elif motion=="weave":
			e.pos.x-=e.speed*.82*dt
			e.pos.y=e.base+sin(e.age*3.4+e.phase)*e.amplitude*1.35
		elif motion=="dive":
			e.pos.x-=e.speed*.92*dt
			var plunge=sin(e.age*1.35+e.phase)*.5+.5
			e.pos.y=e.base+sin(e.age*4.1+e.phase)*12+(plunge-.5)*e.amplitude*2.1
		else: # orbit: a slow looping sidestep with a tight inner pulse.
			e.pos.x-=e.speed*.72*dt+sin(e.age*2.0+e.phase)*17*dt
			e.pos.y=e.base+sin(e.age*2.0+e.phase)*e.amplitude+sin(e.age*6.0+e.phase)*9
		# This slice teaches bullets and routes, not surprise contact damage.
		# Holding the living hull beyond the player lane preserves a clear rescue space.
		if bio_route:e.pos.x=maxf(420,e.pos.x)
		e.cool-=dt
		if e.cool<=0 and e.pos.x<610:
			e.cool=2.7 if motion=="orbit" else (2.3 if motion=="dive" else 2.5)
			var target=players[wave_id%count].pos
			var angles=[-.2,0,.2] if bio_route and motion=="fan" else ([0] if motion=="dive" else [-.11,.11])
			for angle in angles:
				var shot={"pos":e.pos,"vel":(target-e.pos).normalized().rotated(angle)*(78 if motion=="orbit" else 88),"r":4 if motion=="dive" else 3}
				if motion=="weave":shot.turn=.46 if angle<0 else -.46
				if motion=="orbit":shot.turn=.22 if angle<0 else -.22
				shots.append(shot)
		for p in players:
			if p.down==0 and p.pos.distance_to(e.pos)<20: hurt(p)
		if e.hp<=0:
			for p in players:
				if p.down==0:p.experience+=1
			explode(e.pos,COLORS[1],14)
			if art_v09 and bio_route: visual.confirm(e.pos,combo)
			score+=100*combo; combo=mini(8,combo+1); combo_time=3
			if randi()%4==0: pickups.append({"pos":e.pos,"kind":0 if randi()%4==0 else 1})
	enemies=enemies.filter(func(e): return e.hp>0 and e.pos.x > -40)
	for shot in shots:
		shot.vel=shot.vel.rotated(shot.get("turn",0.0)*dt)
		shot.pos+=shot.vel*dt
		for p in players:
			if p.down==0 and p.pos.distance_to(shot.pos)<8+shot.r:
				hurt(p); shot.pos.x=-100
	shots=shots.filter(func(s):return s.pos.x>-30 and s.pos.x<680 and s.pos.y>30 and s.pos.y<340)
	for item in pickups:
		item.pos.x-=dt*40
		for p in players:
			if p.down==0 and p.pos.distance_to(item.pos)<20:
				if item.kind==0: p.hp=mini(4,p.hp+1)
				else: p.charge=minf(100,p.charge+25)
				score+=50; sfx("pickup"); item.pos.x=-100
	pickups=pickups.filter(func(p):return p.pos.x>-20)
	if not boss.is_empty() and boss.hp<=0:
		if slice_mode:
			explode(boss.pos,COLORS[2],90);boss={};aftermath=.01;shots.clear();enemies.clear()
		else:finish(true)

func spawn_wave():
	wave_id+=1
	var base=85+(wave_id*61)%190
	for j in range(3+count):
		var technique=["fan","weave","dive","orbit"][(wave_id+j)%4] if bio_route else "aimed"
		var lane=base+(j-(count+1)*.5)*18
		enemies.append({"pos":Vector2(670+j*34,lane),"base":lane,"age":0.0,"phase":j*.65+wave_id*.27,"speed":55.0+wave_id%4*9,"amplitude":23.0+int(technique=="dive")*8,"hp":2+int(count>1),"cool":1.3+j*.27,"flash":0.0,"technique":technique})

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
	if slice_mode:
		boss.hp=40.0+count*18;boss.max=boss.hp
		bio.armor=[10+count*3,10+count*3]
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

func explode(pos,color,amount):
	if art_v09 and bio_route:
		visual.explode(pos,amount)
		sfx("break_boss_v09" if amount>=80 else ("break_medium_v09" if amount>=28 else "break_small_v09"))
	for i in range(amount):
		particles.append({"pos":pos,"vel":Vector2.from_angle(randf()*TAU)*randf_range(20,115),"life":randf_range(.2,.8),"color":color})

func finish(won):
	mode="clear" if won else "over"
	result_delay=1.2 if won and art_v09 else 0.0
	music.stop(); sfx("gate" if won else "burst")
	if won: track("ending")
	if won:
		score+=reserves*1000
		explode(Vector2(525,180),COLORS[2],90)
	if not auto_test:
		if not slice_mode:high_scores[count-1]=maxi(high_scores[count-1],score)
		var cfg=ConfigFile.new()
		for i in range(3): cfg.set_value("scores",str(i),high_scores[i])
		cfg.save("user://scores.cfg")
		var record={"version":"0.2.0","ruleset":"red-echo-slice-v09" if slice_mode else "ruins-v1","players":count,"score":score,"elapsed":elapsed,"cleared":won,"gates":gates_done,"timestamp":Time.get_datetime_string_from_system()}
		var file=FileAccess.open("user://last_run.json",FileAccess.WRITE)
		if file: file.store_string(JSON.stringify(record,"  "))
	else:
		tests_done=true
		if won and (gates_done==2 or slice_mode):
			print("AUTOTEST PASS: ",count," pilots, ","short slice" if slice_mode else "both relay puzzles",", boss defeat, stage clear. Score=",score," elapsed=",elapsed)
			get_tree().quit(0)
		else:
			push_error("AUTOTEST FAIL")
			get_tree().quit(1)

func launch_next_stage() -> void:
	# The Stage 2 prototype is proposed in a separate PR; do not break the
	# released Stage 1 flow if that scene has not been integrated yet.
	const stage_two_path := "res://stage2_prototype.tscn"
	if mode != "clear" or result_delay > 0.0:
		return
	if not ResourceLoader.exists(stage_two_path):
		tell("STAGE 2 NOT INSTALLED", 3.0)
		return
	get_tree().change_scene_to_file.call_deferred(stage_two_path)

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

func ship(pos,color,size=1):
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

func _draw():
	if mode=="status":
		draw_status_screen()
		return
	if art_v09 and bio_route:
		visual.draw(self)
		return
	background()
	if mode=="controls":
		draw_controls()
		return
	if mode=="menu":
		draw_menu()
		return
	if vertical.active and mode in ["play","pause","over"]:
		vertical.draw(self)
		draw_hud()
		if mode=="pause": centered("PAUSED / START TO RESUME",185,WHITE,2)
		if mode=="over": draw_result()
		return
	if shake>0: draw_set_transform(Vector2(randf_range(-shake,shake),randf_range(-shake,shake)))
	if bio_route: bio.draw_organs(self)
	if gate>0: draw_gate()
	for e in enemies:
		if bio_route and e.hp<=3 and players.any(func(p):return p.character==2): draw_arc(e.pos,24,0,TAU,16,Color("f0da9a"),1)
		sprite(FOE,e.pos-Vector2(16,10),[Color("3c2c59"),Color("9379b8"),Color("d871a4"),WHITE if e.flash>0 else Color("ffce63")],2)
	for b in bullets:
		draw_rect(Rect2(b.pos.x-8,b.pos.y-2,13,4),COLORS[b.color])
		draw_rect(Rect2(b.pos.x,b.pos.y-1,6,2),WHITE)
	for s in shots:
		draw_rect(Rect2(s.pos-Vector2.ONE*(s.r+1),Vector2.ONE*(s.r+1)*2),Color("7a2a66"))
		draw_rect(Rect2(s.pos-Vector2.ONE*s.r,Vector2.ONE*s.r*2),Color("ff829c"))
		draw_rect(Rect2(s.pos-Vector2.ONE,Vector2(2,2)),WHITE)
	for item in pickups:
		draw_rect(Rect2(item.pos-Vector2(6,6),Vector2(12,12)),COLORS[0] if item.kind==0 else COLORS[2],false,1)
		text_at("+" if item.kind==0 else "E",item.pos-Vector2(2,3),WHITE)
	if not boss.is_empty(): draw_boss()
	for i in range(players.size()):
		var p=players[i]
		if p.down>0:
			# A pod must remain easy to find in dense fire.  The pulse is purely
			# informational: the actual rescue range and timer stay in update_game.
			draw_arc(p.pos,20+sin(clock*6.0)*2,0,TAU,16,Color(COLORS[i].r,COLORS[i].g,COLORS[i].b,.42),1)
			draw_rect(Rect2(p.pos-Vector2(7,5),Vector2(14,10)),COLORS[i],false,2)
			text_at("SOS",p.pos+Vector2(-8,-15),COLORS[i])
			var rescue_ratio=clampf(p.rescue/1.5,0.0,1.0)
			draw_rect(Rect2(p.pos+Vector2(-12,11),Vector2(24,2)),Color("18233c"))
			draw_rect(Rect2(p.pos+Vector2(-12,11),Vector2(24*rescue_ratio,2)),WHITE)
			if rescue_ratio>0:
				for rescuer in players:
					if rescuer.down==0 and rescuer.pos.distance_to(p.pos)<55:
						draw_line(rescuer.pos,p.pos,Color(COLORS[rescuer.color].r,COLORS[rescuer.color].g,COLORS[rescuer.color].b,.72),1.5,true)
					draw_arc(p.pos,15+rescue_ratio*12,0,TAU,16,Color(WHITE.r,WHITE.g,WHITE.b,.7),1)
		elif p.inv<=0 or int(clock*14)%2==0:
			ship(p.pos,COLORS[p.color])
			text_at(str(i+1),p.pos+Vector2(-5,-17),COLORS[i])
			# A small diamond marks the precise player hitbox.
			draw_rect(Rect2(p.pos-Vector2(1,1),Vector2(2,2)),COLORS[p.color])
		if p.burst>0:
			draw_arc(p.pos,(.55-p.burst)*650,0,TAU,48,COLORS[p.color],2)
	for part in particles:
		draw_rect(Rect2(part.pos,Vector2(3,2)),part.color)
	draw_set_transform(Vector2.ZERO)
	draw_hud()
	if notice_time>0:
		draw_rect(Rect2(0,43,640,20),Color(0.02,.04,.1,.85))
		centered(notice,50,COLORS[2])
	if mode=="pause":
		draw_rect(Rect2(0,0,W,H),Color(0,0,.04,.8))
		centered("PAUSED",125,WHITE,3)
		centered(notice,164,COLORS[2])
		centered("START / ENTER : RESUME",194)
		centered("Q : RETURN TO TITLE",213,DIM)
		centered("M : SOUND   F11 : FULLSCREEN",245,DIM)
		japanese("F2：コントローラー設定 / F6：音声テスト",Vector2(179,272))
	elif mode in ["clear","over"]: draw_result()

# STATUS-001 — battle pauses behind this screen.  HP and energy retain the same
# shape for all pilots; each page only explains the already-playable mechanism.
func draw_status_screen():
	if players.is_empty(): return
	status_slot=clampi(status_slot,0,players.size()-1)
	var p=players[status_slot]
	var char_id=int(p.character)
	var accents=[Color("ff668e"),Color("67ecff"),Color("ffce63")]
	var backgrounds=[Color("21111f"),Color("071b31"),Color("211a26")]
	var accent=accents[char_id]
	draw_rect(Rect2(0,0,W,H),backgrounds[char_id])
	draw_rect(Rect2(0,0,W,4),accent)
	for i in range(21):
		draw_line(Vector2(i*32,48),Vector2(i*32,326),Color(accent.r,accent.g,accent.b,.07),1)
	for i in range(8):
		draw_line(Vector2(20,68+i*32),Vector2(620,68+i*32),Color(accent.r,accent.g,accent.b,.035),1)
	japanese(PILOT_NAMES[char_id],Vector2(23,33),23,WHITE)
	text_at("P"+str(status_slot+1),Vector2(184,21),accent,2)
	japanese("ライフ",Vector2(292,28),12,WHITE)
	for h in range(4):
		var heart=Color("ff8fa7") if h<int(p.hp) else Color("364055")
		draw_colored_polygon(PackedVector2Array([Vector2(350+h*19,18),Vector2(354+h*19,14),Vector2(358+h*19,18),Vector2(362+h*19,14),Vector2(366+h*19,18),Vector2(358+h*19,29)]),heart)
	japanese("エネルギー",Vector2(447,28),12,DIM)
	draw_rect(Rect2(519,19,96,8),Color("26324a"))
	draw_rect(Rect2(519,19,96*clampf(float(p.charge)/100.0,0,1),8),accent)
	draw_line(Vector2(22,49),Vector2(618,49),accent,2)
	if archive_page and char_id==2:
		draw_mafio_archive()
	elif char_id==0:
		draw_cormii_status(p,accent)
	elif char_id==1:
		draw_jiyoza_status(p,accent)
	else:
		draw_mafio_status(p,accent)
	# Draw after each live page so the supplied, fixed protagonist appearance is
	# visible rather than becoming a barely-readable watermark. The underlying
	# mechanic cards remain active game data; this panel is display-only.
	if not archive_page:
		draw_fixed_pilot_visual(char_id,accent)
	text_at("TAB / START : BACK   LEFT / RIGHT : PILOT",Vector2(28,341),accent)

func draw_cormii_status(p,accent):
	japanese("出力変動盤 / 瞬間最大火力",Vector2(29,78),20,Color("ffdbe5"))
	var phase=fposmod(elapsed,8.0)
	var labels=["最大出力","反動","安定","増幅予告"]
	var active=0 if phase<1.5 else (1 if phase<3.0 else (3 if phase>6.5 else 2))
	for i in range(4):
		# Reserve the far-right column for the fixed portrait without dropping the
		# live fourth phase card.
		var x=30+i*99
		var tint=accent if i==active else Color("593447")
		draw_rect(Rect2(x,120,88,105),Color("321a2b"))
		draw_rect(Rect2(x,120,88,105),tint,false,2)
		draw_rect(Rect2(x+12,173,64,13),Color("3b2638"))
		draw_rect(Rect2(x+12,173,64*(1.0 if i==active else .22),13),tint)
		japanese(labels[i],Vector2(x+10,150),12,WHITE)
		text_at("NOW" if i==active else "WAIT",Vector2(x+21,198),tint,1)
	japanese("現在："+Abilities.label(p,elapsed)+"   成長 Lv "+str(Abilities.level(p)+1),Vector2(38,263),17,Color("ffe9be"))
	japanese("大きく開花し、反動を越えて次の波を待つ。数値は試作調整中。",Vector2(38,302),14,WHITE)

func draw_jiyoza_status(p,accent):
	japanese("解析端末 / 精密・漸進成長",Vector2(29,78),20,Color("b9efff"))
	for i in range(8):
		draw_line(Vector2(42+i*53,110),Vector2(42+i*53,284),Color("1b5b79"),1)
	for i in range(7):
		draw_line(Vector2(42,110+i*25),Vector2(418,110+i*25),Color("1b5b79"),1)
	text_at("ANALYSIS LV "+str(Abilities.level(p)+1),Vector2(57,126),accent,2)
	for i in range(12):
		draw_rect(Rect2(57+i*29,164,22,16),accent if i<mini(12,int(p.experience)) else Color("173b58"))
	draw_arc(Vector2(360,224),57,0,TAU,40,Color("397b9b"),1)
	draw_arc(Vector2(360,224),45,-PI/2,-PI/2+TAU*float(Abilities.level(p)+1)/4.0,40,Color("d3f6ff"),3)
	draw_line(Vector2(302,224),Vector2(418,224),Color("85e7f4"),1)
	draw_line(Vector2(360,166),Vector2(360,282),Color("85e7f4"),1)
	japanese("取得経験 "+str(p.experience)+" / 次の解析 "+str((Abilities.level(p)+1)*8),Vector2(57,257),16,WHITE)
	japanese("敵の軌道を読み、撃破ごとに確実に出力を高める。",Vector2(57,303),14,Color("c8f2ff"))

func status_technique_name(technique:String)->String:
	var names={"none":"基本弾","fan":"散華三連","weave":"蛇行弾","dive":"急降下弾","orbit":"環状弾","petal":"散華扇","seed":"種子分裂","halo":"放射光","beam":"細光レーザー","pierce":"貫通ニードル"}
	return str(names.get(technique,"解析中"))

func draw_mafio_status(p,accent):
	japanese("融合器官 / 捕食・消化・変異",Vector2(29,78),20,Color("ffe6bd"))
	# Keep all actionable digestion data left of the dedicated character panel.
	draw_rect(Rect2(31,101,391,184),Color("352733"))
	draw_rect(Rect2(31,101,391,184),Color("dfba6a",.48),false,1)
	draw_line(Vector2(220,112),Vector2(220,274),Color("fff0d0"),2)
	var total=maxf(.1,float(p.get("digest_total",1.2)))
	var progress=1.0-clampf(float(p.digest)/total,0,1)
	draw_arc(Vector2(220,191),67,0,TAU,40,Color("e5d1af"),2)
	draw_arc(Vector2(220,191),65,-PI/2,-PI/2+progress*TAU,40,Color("9adeff"),4)
	japanese("消化中の技",Vector2(56,135),14,WHITE)
	japanese(status_technique_name(str(p.get("pending_technique","none"))) if p.digest>0 else status_technique_name(str(p.learned)),Vector2(56,173),20,Color("ffe5b4"))
	japanese("残り "+str(snappedf(p.digest,.1))+" 秒",Vector2(250,145),17,WHITE)
	japanese("捕食記録  "+str(mafio_archive.total_unlocked())+"/"+str(MafioArchive.ENTRIES.size()),Vector2(250,205),15,WHITE)
	text_at("E / X : ENEMY ARCHIVE",Vector2(250,255),Color("dfbdf7"))
	japanese("弱った敵へ近づき、バーストで捕食。消化後に敵技を再現。",Vector2(72,309),14,WHITE)

func draw_mafio_archive():
	japanese("マフィオの捕食図鑑",Vector2(23,78),20,Color("fff0d4"))
	text_at("E / X : STATUS",Vector2(476,67),Color("e0b8fc"))
	var index=clampi(archive_cursor,0,MafioArchive.ENTRIES.size()-1)
	archive_cursor=index
	var first=clampi(index-3,0,maxi(0,MafioArchive.ENTRIES.size()-8))
	for i in range(8):
		var j=first+i
		if j>=MafioArchive.ENTRIES.size(): break
		var item=MafioArchive.ENTRIES[j]
		var unlocked=mafio_archive.unlocked(str(item["id"]))
		var row_y=103+i*27
		if j==index:
			draw_rect(Rect2(18,row_y-16,298,25),Color("5b3e59"))
			draw_rect(Rect2(18,row_y-16,3,25),Color("f5c979"))
		japanese(str(item["id"])+"  "+(str(item["name"]) if unlocked else "？？？？？"),Vector2(28,row_y),13,WHITE if unlocked else Color("76849c"))
		if unlocked: text_at("x"+str(mafio_archive.captured.get(str(item["id"]),0)),Vector2(259,row_y-8),Color("aee7ec"))
	draw_rect(Rect2(326,86,295,231),Color("1b233b"))
	draw_rect(Rect2(326,86,295,231),Color("c8a8ce"),false,1)
	var chosen=MafioArchive.ENTRIES[index]
	if mafio_archive.unlocked(str(chosen["id"])):
		japanese(str(chosen["name"]),Vector2(348,116),20,Color("ffe4bd"))
		draw_circle(Vector2(473,173),35,Color("544066"))
		draw_arc(Vector2(473,173),30,0,TAU,24,Color("edc785"),2)
		draw_colored_polygon(PackedVector2Array([Vector2(473,148),Vector2(490,179),Vector2(457,179)]),Color("9fbcf5"))
		japanese("敵の攻撃："+str(chosen["attack"]),Vector2(343,242),13,WHITE)
		japanese("習得技："+str(chosen["ability"]),Vector2(343,268),13,Color("d8b4fc"))
	else:
		text_at("UNKNOWN",Vector2(372,135),Color("72809d"),2)
		draw_circle(Vector2(473,184),43,Color("30344a"))
		japanese("未捕食・詳細不明",Vector2(380,277),16,Color("91a1b7"))
	text_at("UP / DOWN : SELECT",Vector2(355,301),Color("a5aac0"))

func draw_hud():
	draw_rect(Rect2(0,0,640,43),Color("080f22"))
	draw_rect(Rect2(0,32,640,1),Color("2d4a62"))
	for i in range(count):
		var p=players[i]
		var x=12+i*138
		text_at("P"+str(i+1),Vector2(x,8),COLORS[i])
		japanese(PILOT_NAMES[p.character],Vector2(x,39),10,WHITE)
		if bio_route: japanese(Abilities.label(p,elapsed),Vector2(x+48,39),9,COLORS[i])
		for h in range(4): draw_rect(Rect2(x+22+h*10,8,7,5),COLORS[i] if h<p.hp else Color("26314b"))
		text_at(["CYAN","ROSE","GOLD"][p.color],Vector2(x+70,8),COLORS[p.color])
		draw_rect(Rect2(x,22,110,3),Color("26314b"))
		draw_rect(Rect2(x,22,p.charge*1.1,3),COLORS[i])
		if p.charge>=100: text_at("B",Vector2(x+115,19),WHITE)
	text_at("SCORE",Vector2(460,7),DIM)
	text_at("%07d"%score,Vector2(515,7),WHITE)
	text_at("RESERVE "+str(reserves),Vector2(460,21),COLORS[2])
	text_at("X"+str(combo),Vector2(585,21),COLORS[0])
	draw_rect(Rect2(0,337,640,23),Color("080f22"))
	japanese("第一境界：赤い残響（試作）" if bio_route else "旧試作：共鳴遺跡",Vector2(12,354),11,DIM)
	text_at("M SOUND "+("OFF" if muted else "ON"),Vector2(265,345),DIM)
	text_at("START PAUSE",Vector2(405,345),DIM)
	draw_rect(Rect2(500,347,125,2),Color("28374e"))
	draw_rect(Rect2(500,347,minf(125,travel/4800*125),2),COLORS[0])

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
	# Read top-to-bottom: mission -> ships -> launch. Keep the landing screen a title
	# card, but give the actionable parameters the same visual weight as the art.
	draw_rect(Rect2(12,10,616,42),Color("071122",.9))
	draw_rect(Rect2(12,10,616,42),Color("527e9c"),false,1)
	draw_rect(Rect2(18,16,4,30),COLORS[0])
	japanese("MISSION  //  RED ECHO",Vector2(30,27),12,Color("d9e8ec"))
	japanese("第1境界・生体宙域",Vector2(30,44),10,COLORS[2])
	draw_rect(Rect2(506,18,108,25),Color("10283e"))
	draw_rect(Rect2(506,18,108,25),Color(COLORS[0],.7),false,1)
	japanese("LOCAL  1 - 3P",Vector2(518,34),10,COLORS[0])
	# Chat UI-013 supplies a longer, uncut floral rule around the title.  It is
	# a presentation layer only: older builds retain the existing title assets.
	if chat_ui_atlas:
		draw_chat_ui_region(Rect2(48,0,1346,160),Rect2(16,51,608,72))
	elif title_logo_extended:
		draw_texture_rect(title_logo_extended,Rect2(50,42,540,180),false)
	elif title_logo:
		draw_texture_rect(title_logo,Rect2(121,57,396,90),false)
		centered("M  A  N  J  U  S  H  A  G  E",147,COLORS[0],2)
	else:
		japanese("曼珠沙華",Vector2(224,103),48,Color("203b59"))
		japanese("曼珠沙華",Vector2(221,100),48,WHITE)
		centered("MANJUSHAGE",116,COLORS[0],3)
	# Compact parameter strip: it names every setting that can change on this screen.
	draw_rect(Rect2(164,156,312,29),Color("08162b",.9))
	draw_rect(Rect2(164,156,312,29),Color("527e9c"),false,1)
	draw_line(Vector2(267,160),Vector2(267,181),Color("35536d"),1)
	draw_line(Vector2(373,160),Vector2(373,181),Color("35536d"),1)
	japanese("人数",Vector2(176,168),9,DIM)
	japanese(str(count)+" PILOTS",Vector2(176,180),11,WHITE)
	japanese("先導機",Vector2(280,168),9,DIM)
	japanese(PILOT_NAMES[pilot_offset],Vector2(280,180),11,COLORS[2])
	japanese("航路",Vector2(386,168),9,DIM)
	japanese("赤い残響" if bio_route else "共鳴遺跡",Vector2(386,180),11,COLORS[0])
	if art_v09 and bio_route:
		for i in range(3):
			visual.ship(self,{"pos":Vector2(240+i*80,202),"color":i,"character":i,"experience":0},i,0,1.15)
	else:
		ship(Vector2(319,202),COLORS[0],2)
		ship(Vector2(240,201),COLORS[1])
		ship(Vector2(397,201),COLORS[2])
	draw_rect(Rect2(183,219,274,25),Color("08162b",.94))
	draw_rect(Rect2(183,219,274,25),Color("35536d"),false,1)
	japanese("◀",Vector2(198,237),13,COLORS[0])
	japanese("▶",Vector2(438,237),13,COLORS[0])
	centered(str(count)+" 名編成",238,WHITE,2)
	# The launch control is deliberately the largest, brightest interactive surface.
	if chat_ui_atlas:
		# Crop the red selected button frame from the supplied four-state UI atlas.
		# Mask its source label, then place the live action label over it so this
		# remains an actual sortie control rather than a static mockup.
		draw_chat_ui_region(Rect2(123,224,188,49),Rect2(190,250,260,44))
		draw_rect(Rect2(202,258,236,27),Color("32152b",.88))
		draw_rect(Rect2(202,258,236,27),Color("ffc4cf",.48),false,1)
	elif launch_button:
		draw_texture_rect(launch_button,Rect2(175,230,290,82),false)
	else:
		draw_rect(Rect2(194,251,252,44),Color(COLORS[0],.16))
		draw_rect(Rect2(198,255,244,36),Color("0d3150"))
		draw_rect(Rect2(198,255,244,36),COLORS[0],false,2)
		draw_rect(Rect2(204,261,232,3),Color("f0fff6",.55))
	japanese("出　撃",Vector2(289,281),19,WHITE)
	japanese("A / ENTER",Vector2(373,281),10,COLORS[2])
	centered("左右：人数選択　　F4 / X：先導機　　F8 / B：航路",309,DIM)
	centered("GAMEPADS "+str(Input.get_connected_joypads().size())+"  //  BGM "+("OFF" if muted else "ON"),323,COLORS[2])
	japanese("F2：コントローラー設定",Vector2(22,341),10,COLORS[0])
	japanese("H：遊び方",Vector2(282,341),10,WHITE)
	japanese("最高 %07d"%high_scores[count-1],Vector2(510,341),10,COLORS[0])
	japanese("曼珠沙華 0.9 / 生体宇宙 試作",Vector2(22,354),10,Color("3e536f"))
	japanese("F6：音声テスト / F7：出力切替",Vector2(205,353),11,DIM)
	japanese("F11：全画面",Vector2(540,345),10,Color("3e536f"))
	if show_help:
		draw_rect(Rect2(45,42,550,270),Color("0c162c"))
		draw_rect(Rect2(45,42,550,270),COLORS[0],false,1)
		japanese("操縦説明",Vector2(278,61),18,COLORS[0])
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
	if result_delay>0:return
	draw_rect(Rect2(0,0,W,H),Color(0.015,.025,.08,.9))
	japanese("境界を越えた" if mode=="clear" else "通信が途切れた",Vector2(232 if mode=="clear" else 205,92),24,COLORS[0] if mode=="clear" else COLORS[1])
	if bio_route and mode=="clear":
		japanese("記憶の断片・仮稿：赤い光の向こうに、道が続いていた。",Vector2(96,126),13,WHITE)
	else: japanese("記憶の門が、もう一度ひらく。" if mode=="clear" else "態勢を整えて、もう一度。",Vector2(210,126),13,DIM)
	centered("%07d"%score,153,WHITE,4)
	centered(str(count)+" PILOTS / "+str(gates_done)+" RELAYS / "+str(int(elapsed))+" SECONDS",198,COLORS[2])
	centered("LOCAL BEST  %07d"%high_scores[count-1],223,DIM)
	if mode=="clear":
		centered("N : NEXT STAGE (IF INSTALLED)",249,COLORS[0])
	centered("ENTER / A : FLY AGAIN",269,WHITE)
	centered("ESC : TITLE",289,DIM)

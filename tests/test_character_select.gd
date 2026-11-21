extends SceneTree
# Character select: menu -> select -> swap-safe cycling -> launch with picks.
func _initialize(): run.call_deferred()

func key(code):
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	return event

func run():
	var g = load("res://main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	g.set_process(false)
	assert(g.mode == "menu")
	g.count = 2
	g.pilot_offset = 0
	g.slice_mode = false
	g.menu_stage = 1
	g._input(key(KEY_ENTER))
	assert(g.mode == "select", "Menu Enter must open character select")
	assert(g.briefing_chars == [0, 1, 2] and g.briefing_slot == 0)
	g._input(key(KEY_RIGHT)) # Slot 0: Cormii -> Jiyoza, holders swap.
	assert(g.briefing_chars == [1, 0, 2], "Cycling must swap, never duplicate")
	g._input(key(KEY_LEFT)) # Back to Cormii.
	assert(g.briefing_chars == [0, 1, 2])
	g._input(key(KEY_DOWN))
	assert(g.briefing_slot == 1)
	g._input(key(KEY_RIGHT)) # Slot 1: Jiyoza -> Mafio.
	assert(g.briefing_chars == [0, 2, 1])
	g._input(key(KEY_ENTER))
	assert(g.mode == "play", "Select Enter must launch")
	assert(g.players.size() == 2)
	assert(int(g.players[0].character) == 0 and int(g.players[1].character) == 2)
	# ESC from select returns to the menu.
	g.mode = "menu"
	g._input(key(KEY_ENTER))
	assert(g.mode == "select")
	g._input(key(KEY_ESCAPE))
	assert(g.mode == "menu")
	print("CHARACTER SELECT PASS: open, swap-safe cycling, slot navigation, launch with picks, ESC back")
	quit(0)

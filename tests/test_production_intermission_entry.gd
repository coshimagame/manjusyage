extends SceneTree
## Headless smoke check for the real game + stage-clear story bridge.
## Run with an isolated user-data directory:
## godot --headless --path . --script res://tests/test_production_intermission_entry.gd
const BridgeScene = preload("res://scenes/production_clear_intermission.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var bridge = BridgeScene.instantiate()
	root.add_child(bridge)
	await process_frame
	assert(is_instance_valid(bridge.game), "Production game must be instantiated")
	assert(str(bridge.game.get("mode")) == "menu", "Normal launch must start at title")
	assert(not is_instance_valid(bridge.overlay), "Story must not appear before clear")
	# Simulate the same mode transition used by the real stage-1 boss clear.
	bridge.game.set("mode", "clear")
	await process_frame
	await process_frame
	assert(is_instance_valid(bridge.overlay), "Clear must open the story overlay")
	assert(bridge.game.process_mode == Node.PROCESS_MODE_DISABLED, "Combat must pause during story")
	bridge._finish_clear_dialogue()
	await process_frame
	assert(bridge.game.process_mode == Node.PROCESS_MODE_INHERIT, "Combat processing must restore")
	assert(not is_instance_valid(bridge.overlay), "Story overlay must be removed")
	assert(str(bridge.game.get("mode")) == "clear", "Existing result screen must remain available")
	# Clear is still active; do not replay the story every frame.
	await process_frame
	assert(not is_instance_valid(bridge.overlay), "Story must not reopen without a new clear")
	print("PASS production intermission entry/exit")
	quit(0)

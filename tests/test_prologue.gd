extends SceneTree

func _initialize():
	run.call_deferred()

func run():
	var scene = load("res://prologue.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	scene.set_process(false)
	assert(scene.PAGES.size()==6)
	assert(scene.page==0)
	scene.age=0
	scene.advance()
	assert(scene.page==0 and scene.age==2.5)
	scene.advance()
	assert(scene.page==1)
	for i in range(4):
		scene.age=3
		scene.advance()
	assert(scene.page==5)
	scene.age=3
	scene.advance()
	await process_frame
	await process_frame
	assert(current_scene.get_script().resource_path=="res://game.gd")
	assert(current_scene.mode=="menu")
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("PROLOGUE PASS: six pages, reveal, next, title transition")
	quit()

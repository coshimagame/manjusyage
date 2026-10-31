extends SceneTree

func _initialize(): run.call_deferred()

func run():
	var scene=load("res://prologue.tscn").instantiate()
	root.add_child(scene)
	current_scene=scene
	await process_frame
	scene.set_process(false)
	assert(scene.PAGES.size()==8, "Prologue now contains eight story beats")
	assert(scene.page==0)
	scene.age=0
	scene.advance()
	assert(scene.page==0 and scene.age==2.5)
	scene.advance()
	assert(scene.page==1)
	for i in range(scene.PAGES.size()-2):
		scene.age=3.0
		scene.advance()
	assert(scene.page==7)
	# The eighth advance enters the title, without indexing page 8.
	scene.age=3.0
	scene.advance()
	await process_frame
	await process_frame
	assert(current_scene.get_script().resource_path=="res://game.gd")
	assert(current_scene.mode=="menu")
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("PROLOGUE PASS: eight pages, reveal, workshop dialogue and title transition")
	quit(0)

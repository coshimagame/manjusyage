extends SceneTree

func add_tree(packer:PCKPacker, folder:String):
	var directory=DirAccess.open(folder)
	assert(directory!=null)
	directory.list_dir_begin()
	var name=directory.get_next()
	while name!="":
		if not name.begins_with("."):
			var path=folder.path_join(name)
			if directory.current_is_dir():
				add_tree(packer,path)
			else:
				assert(packer.add_file(path,path)==OK)
		name=directory.get_next()
	directory.list_dir_end()

func _initialize():
	var packer=PCKPacker.new()
	var output="res://STARLINK-SQUAD.pck"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output=argument.trim_prefix("--output=")
	var result=packer.pck_start(ProjectSettings.globalize_path(output))
	if result!=OK:
		push_error("Cannot create Windows playtest pack: "+error_string(result))
		quit(1)
		return
	for path in ["project.godot","main.tscn","game.gd","visual_v09.gd","art_catalog.gd","ambient_stage_music.gd","biological_stage.gd","briefing_progress.gd","enemy_analysis.gd","jingle_cues.gd","mafio_archive.gd","pilot_abilities.gd","pilot_journals.gd","vertical_passage.gd","prologue.gd","prologue.tscn"]:
		assert(packer.add_file("res://"+path,"res://"+path)==OK)
	for folder in ["res://art","res://audio","res://scripts","res://ui","res://.godot/imported"]:
		add_tree(packer,folder)
	assert(packer.flush()==OK)
	print("PACKAGED ",output)
	quit()

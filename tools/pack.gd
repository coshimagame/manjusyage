extends SceneTree

func _initialize():
	var packer=PCKPacker.new()
	var result=packer.pck_start("res://STARLINK-SQUAD.pck")
	assert(result==OK)
	for path in ["project.godot","main.tscn","game.gd","biological_stage.gd","pilot_abilities.gd","vertical_passage.gd","prologue.gd","prologue.tscn"]:
		assert(packer.add_file("res://"+path,"res://"+path)==OK)
	for folder in ["audio", ".godot/imported"]:
		for name in DirAccess.get_files_at("res://"+folder):
			if folder==".godot/imported" and not name.ends_with(".sample"): continue
			var path="res://"+folder+"/"+name
			assert(packer.add_file(path,path)==OK)
	assert(packer.flush()==OK)
	print("PACKAGED STARLINK-SQUAD.pck")
	quit()

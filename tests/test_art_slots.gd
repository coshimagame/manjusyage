extends SceneTree
# Run with Godot 4.6: godot --headless --path . --script tests/test_art_slots.gd
const ArtCatalog=preload("res://art_catalog.gd")

func _initialize():
	var art=ArtCatalog.new()
	art.reload()
	assert(ArtCatalog.SLOTS.size()==13)
	for key in ArtCatalog.SLOTS:
		var texture=art.texture(key)
		assert(texture==null or (texture.get_width()>0 and texture.get_height()>0))
	assert(art.texture("non_existing_slot")==null)
	print("ART SLOTS PASS: optional textures, fallback, and dimensions")
	quit(0)

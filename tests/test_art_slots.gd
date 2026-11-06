extends SceneTree
# Run with Godot 4.6: godot --headless --path . --script tests/test_art_slots.gd
const ArtCatalog=preload("res://art_catalog.gd")

func _initialize():
	var art=ArtCatalog.new()
	art.reload()
	assert(ArtCatalog.SLOTS.size()==13)
	assert(ArtCatalog.ORGANIZED_PATHS.size()==8)
	assert(ArtCatalog.ORGANIZED_PATHS["ship_cormii"]=="res://art/characters/cormii/ship.png")
	assert(ArtCatalog.ORGANIZED_PATHS["enemy_bloom"]=="res://art/enemies/bloom/sprite.png")
	assert(ArtCatalog.ORGANIZED_PATHS["bio_backdrop"]=="res://art/backgrounds/stage_01/backdrop.png")
	for key in ArtCatalog.SLOTS:
		var texture=art.texture(key)
		assert(texture==null or (texture.get_width()>0 and texture.get_height()>0))
	assert(art.texture("non_existing_slot")==null)
	print("ART SLOTS PASS: optional textures, fallback, and dimensions")
	quit(0)

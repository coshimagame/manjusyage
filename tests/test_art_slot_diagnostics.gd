extends SceneTree
# Godot 4.6: godot --headless --path . --script tests/test_art_slot_diagnostics.gd
const ArtCatalog = preload("res://art_catalog.gd")

func _initialize() -> void:
	var art = ArtCatalog.new()
	art.reload()
	var missing = art.missing_slots()
	assert(missing.size() <= ArtCatalog.SLOTS.size())
	for key in ArtCatalog.SLOTS:
		assert(missing.has(key) == (art.texture(key) == null))
	print("ART DIAGNOSTICS PASS: missing optional PNG slots: ", missing)
	quit(0)

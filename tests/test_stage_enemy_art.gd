extends SceneTree
# Run: godot --headless --path . --script res://tests/test_stage_enemy_art.gd
# Checks both scrolling directions without requiring any unapproved PNGs.
const EnemyArt = preload("res://scripts/stage_enemy_art.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	var imported := 0
	var placeholders := 0
	for stage in range(1, 9):
		for variant in range(1, 4):
			var enemy_id: String = EnemyArt.enemy_id(stage, variant)
			if enemy_id.is_empty():
				failures.append("Missing ID: %d/%d" % [stage, variant])
			for vertical in [false, true]:
				var source: String = EnemyArt.resolved_sprite_path(stage, variant, vertical)
				var sprite: Sprite2D = EnemyArt.create_visual(stage, variant, vertical)
				if sprite == null:
					failures.append("Missing visual: %s vertical=%s" % [enemy_id, vertical])
					continue
				if sprite.texture == null or sprite.texture.get_width() <= 0 or sprite.texture.get_height() <= 0:
					failures.append("Invalid texture: " + enemy_id)
				if sprite.get_meta("enemy_art_id", "") != enemy_id:
					failures.append("Incorrect ID metadata: " + enemy_id)
				if sprite.get_meta("enemy_art_source", "") != source:
					failures.append("Incorrect source metadata: " + enemy_id)
				if sprite.get_meta("enemy_art_placeholder", not source.is_empty()) != source.is_empty():
					failures.append("Incorrect placeholder flag: " + enemy_id)
				if sprite.get_meta("enemy_art_direction", "") != ("vertical" if vertical else "horizontal"):
					failures.append("Incorrect direction metadata: " + enemy_id)
				if not is_zero_approx(sprite.rotation_degrees):
					failures.append("Direction art was rotated: " + enemy_id)
				if source.is_empty():
					placeholders += 1
				else:
					imported += 1
			# Release both imported and placeholder sprites after every check.
			if is_instance_valid(sprite):
				sprite.free()
	# Directional fallback silhouettes must actually differ in pixels, not only metadata.
	# Test the procedural textures directly even when optional imported art is installed.
	var horizontal_fallback: Texture2D = EnemyArt.make_placeholder(1, 1, false)
	var vertical_fallback: Texture2D = EnemyArt.make_placeholder(1, 1, true)
	if horizontal_fallback == null or vertical_fallback == null:
		failures.append("Directional fallback texture missing")
	else:
		var horizontal_image: Image = horizontal_fallback.get_image()
		var vertical_image: Image = vertical_fallback.get_image()
		if horizontal_image.get_size() != vertical_image.get_size():
			failures.append("Directional fallback dimensions differ unexpectedly")
		elif horizontal_image.get_data() == vertical_image.get_data():
			failures.append("Horizontal and vertical fallback art are identical")
	# Reject invalid variants as well as out-of-range stages.
	for variant in [0, 4]:
		if not EnemyArt.enemy_id(1, variant).is_empty():
			failures.append("Out-of-range variant accepted")
		var invalid_visual := EnemyArt.create_visual(1, variant)
		if invalid_visual != null:
			failures.append("Out-of-range variant visual accepted")
			invalid_visual.free()
	for stage in [0, 9]:
		if not EnemyArt.enemy_id(stage, 1).is_empty():
			failures.append("Out-of-range stage accepted")
		if EnemyArt.create_visual(stage, 1) != null:
			failures.append("Out-of-range visual accepted")
	if failures.size() > 0:
		for failure in failures:
			push_error(failure)
		quit(1)
		return
	print("PASS: 48 enemy direction visuals; imported=%d placeholders=%d" % [imported, placeholders])
	quit(0)

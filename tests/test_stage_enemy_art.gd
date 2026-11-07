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
				sprite.free()
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

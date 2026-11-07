extends RefCounted
class_name StageEnemyArtValidation

const EnemyArt = preload("res://scripts/stage_enemy_art.gd")

# Call from an editor test or debug menu; does not change saved games.
static func validate() -> PackedStringArray:
	var issues := PackedStringArray()
	for stage in range(1, 9):
		for variant in range(1, 4):
			var enemy_id := EnemyArt.enemy_id(stage, variant)
			if enemy_id.is_empty():
				issues.append("Missing enemy ID: %d/%d" % [stage, variant])
				continue
			var horizontal := EnemyArt.create_visual(stage, variant, false)
			var vertical := EnemyArt.create_visual(stage, variant, true)
			if horizontal == null or horizontal.texture == null:
				issues.append("Horizontal texture unavailable: " + enemy_id)
			if vertical == null or vertical.texture == null:
				issues.append("Vertical texture unavailable: " + enemy_id)
			if horizontal != null:
				horizontal.free()
			if vertical != null:
				vertical.free()
	return issues

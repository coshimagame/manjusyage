extends SceneTree
# Godot 4.6: godot --headless --path . --script res://tests/report_enemy_art_coverage.gd
# Read-only source audit: never substitutes placeholders for approved PNGs.
const EnemyArt = preload("res://scripts/stage_enemy_art.gd")
const REPORT_PATH := "user://enemy_art_coverage.csv"

func _initialize() -> void:
	var lines := PackedStringArray(["stage,variant,enemy_id,direction,status,resource_path,width,height"])
	var imported := 0
	var missing := 0
	var invalid := 0
	for stage in range(1, 9):
		for variant in range(1, 4):
			for vertical in [false, true]:
				var direction := "vertical" if vertical else "horizontal"
				var path: String = EnemyArt.resolved_sprite_path(stage, variant, vertical)
				var status := "missing"
				var width := 0
				var height := 0
				if not path.is_empty():
					var texture := ResourceLoader.load(path) as Texture2D
					if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
						status = "invalid"
						invalid += 1
					else:
						status = "imported_unapproved"
						width = texture.get_width()
						height = texture.get_height()
						imported += 1
				else:
					missing += 1
				lines.append("%d,%d,%s,%s,%s,%s,%d,%d" % [stage, variant, EnemyArt.enemy_id(stage, variant), direction, status, path, width, height])
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write enemy art coverage report: " + str(FileAccess.get_open_error()))
		quit(1)
		return
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("Enemy art coverage: imported=%d missing=%d invalid=%d total=48 report=%s" % [imported, missing, invalid, REPORT_PATH])
	# Missing assets are expected; only corrupt referenced textures fail this audit.
	quit(1 if invalid > 0 else 0)

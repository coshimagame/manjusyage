extends SceneTree
# Godot 4.6: godot --headless --path . --script res://tests/test_control_room_portraits.gd
# Regression for left/right placement, dynamic names, speaker focus and missing PNG fallback.
const PORTRAITS = preload("res://control_room_portraits.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui := PORTRAITS.instantiate() as Control
	root.add_child(ui)
	await process_frame
	var left := ui.get_node_or_null("PartnerPortrait") as PanelContainer
	var right := ui.get_node_or_null("MuPortrait") as PanelContainer
	if left == null or right == null:
		_fail("portrait panels missing")
		return
	if left.position.x >= right.position.x:
		_fail("portrait panel order reversed")
		return
	ui.set_portraits("", "", "コルミィ")
	if not _missing(left) or not _missing(right):
		_fail("empty paths must show missing labels")
		return
	if (left.get_child(0) as VBoxContainer).get_child(1).text != "コルミィ":
		_fail("partner name did not update")
		return
	ui.set_speaker("left")
	if not is_equal_approx(left.modulate.a, 1.0) or not is_equal_approx(right.modulate.a, 0.55):
		_fail("left speaker focus failed")
		return
	ui.set_speaker("right")
	if not is_equal_approx(left.modulate.a, 0.55) or not is_equal_approx(right.modulate.a, 1.0):
		_fail("right speaker focus failed")
		return
	ui.set_speaker("none")
	if not is_equal_approx(left.modulate.a, 1.0) or not is_equal_approx(right.modulate.a, 1.0):
		_fail("neutral focus failed")
		return
	ui.set_portraits("res://missing_partner_20261119.png", "res://missing_mu_20261119.png", "マフィオ")
	if not _missing(left) or not _missing(right):
		_fail("missing PNG paths must show fallback")
		return
	if (left.get_child(0) as VBoxContainer).get_child(1).text != "マフィオ":
		_fail("second partner name did not update")
		return
	print("CONTROL ROOM PORTRAITS PASS: placement, names, focus, missing images")
	ui.queue_free()
	quit(0)

func _missing(panel: PanelContainer) -> bool:
	var column := panel.get_child(0) as VBoxContainer
	var portrait := column.get_child(0) as TextureRect
	var label := portrait.get_node_or_null("MissingLabel") as Label
	return portrait.texture == null and label != null and label.visible

func _fail(message: String) -> void:
	push_error("CONTROL ROOM PORTRAITS FAIL: " + message)
	quit(1)

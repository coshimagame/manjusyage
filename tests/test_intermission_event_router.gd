extends SceneTree
const Router = preload("res://intermission_event_router.gd")

func _initialize() -> void:
	assert(Router.pick(1, 1).get("event_id") == "MU_HANGAR_01")
	assert(Router.pick(8, 1).get("event_id") == "MU_LAST_SIGNAL_07")
	assert(Router.pick(8, 2).get("event_id") == "MU_SURVIVED_09")
	assert(Router.pick(8, 4).get("status") == "proposal")
	assert(Router.pick(2, 1, false).is_empty())
	assert(Router.pick(0, 1).is_empty())
	assert(Router.pick(9, 1).is_empty())
	assert(Router.pick(1, 0).is_empty())
	assert(not Router.should_advance_after("MU_LAST_SIGNAL_07"))
	assert(Router.should_advance_after("MU_HANGAR_01"))
	print("intermission event router smoke OK")
	quit()

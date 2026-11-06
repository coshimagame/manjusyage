extends SceneTree

const Router = preload("res://stage_result_router.gd")

func _initialize() -> void:
	_check(Router.destination(1, "next", true) == {"kind": "stage", "stage": 2}, "next implemented")
	_check(Router.destination(1, "next", false).is_empty(), "no unimplemented next stage")
	_check(Router.destination(1, "briefing", false) == {"kind": "briefing", "stage": 2, "playable": false}, "briefing fallback")
	_check(Router.destination(8, "ending", false) == {"kind": "ending", "stage": 8}, "final ending")
	_check(Router.destination(8, "next", true).is_empty(), "no stage nine")
	_check(Router.destination(3, "retry", false) == {"kind": "stage", "stage": 3}, "retry")
	_check(Router.destination(3, "save", false) == {"kind": "save", "stage": 3}, "save action")
	_check(Router.destination(0, "retry", false).is_empty(), "invalid stage")
	print("PASS stage result routing")
	quit(0)

func _check(condition: bool, label: String) -> void:
	if not condition:
		push_error("FAIL " + label)
		quit(1)

extends RefCounted
## Bridges existing intermission dialogue data to the optional portrait scene.
## This adapter never substitutes an unapproved character portrait.
const PORTRAIT_SCENE := "res://control_room_portraits.tscn"
const PILOTS := ["コルミィ", "ジヨーザ", "マフィオ"]
const MU := "ムゥ"

static func find_portrait_scene() -> PackedScene:
	if not ResourceLoader.exists(PORTRAIT_SCENE):
		return null
	var resource := load(PORTRAIT_SCENE)
	return resource as PackedScene

static func create_overlay(parent: Node) -> Node:
	if parent == null:
		return null
	var scene := find_portrait_scene()
	if scene == null:
		return null
	var overlay := scene.instantiate()
	parent.add_child(overlay)
	return overlay

static func dialogue_partner(speaker: String, previous_partner: String = "コルミィ") -> String:
	if speaker in PILOTS:
		return speaker
	if previous_partner in PILOTS:
		return previous_partner
	return PILOTS[0]

static func apply_dialogue(overlay: Node, speaker: String, previous_partner: String = "コルミィ") -> String:
	var partner := dialogue_partner(speaker, previous_partner)
	if overlay == null:
		return partner
	# Existing portrait scene APIs are optional until their PR is integrated.
	# Never crash the story flow when an art/UI PR has not yet landed.
	if overlay.has_method("set_portraits"):
		overlay.call("set_portraits", partner, MU)
	if overlay.has_method("set_speaker"):
		overlay.call("set_speaker", speaker)
	return partner

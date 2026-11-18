extends RefCounted
## Optional intermission portrait adapter. No unapproved portrait is substituted.
const PORTRAIT_SCENE := "res://control_room_portraits.tscn"
const PILOTS := ["コルミィ", "ジヨーザ", "マフィオ"]
const MU := "ムゥ"

static func find_portrait_scene() -> PackedScene:
	if not ResourceLoader.exists(PORTRAIT_SCENE):
		return null
	return load(PORTRAIT_SCENE) as PackedScene

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

static func speaker_side(speaker: String, partner: String) -> String:
	if speaker == MU:
		return "right"
	if speaker == partner:
		return "left"
	return "none"

## Paths must be actual PNG resource paths, never character names.
## The empty defaults deliberately show the scene's missing-art indicator.
static func apply_dialogue(overlay: Node, speaker: String, previous_partner: String = "コルミィ", partner_png: String = "", mu_png: String = "") -> String:
	var partner := dialogue_partner(speaker, previous_partner)
	if overlay == null:
		return partner
	if overlay.has_method("set_portraits"):
		overlay.call("set_portraits", partner_png, mu_png, partner)
	if overlay.has_method("set_speaker"):
		overlay.call("set_speaker", speaker_side(speaker, partner))
	return partner

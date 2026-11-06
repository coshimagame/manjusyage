extends RefCounted
# Stable, optional portrait slots. Missing images must never break the game.
const ROOT = "res://art/active/portraits/"
const PILOTS = ["cormii", "jiyoza", "mafio"]
const EXPRESSIONS = ["neutral", "happy", "focused", "worried", "hurt", "digesting"]
var cache: Dictionary = {}

func get_portrait(pilot: int, expression: String) -> Texture2D:
	if pilot < 0 or pilot >= PILOTS.size():
		return null
	var state = expression if expression in EXPRESSIONS else "neutral"
	var paths = [
		ROOT + PILOTS[pilot] + "/" + state + ".png",
		ROOT + PILOTS[pilot] + "/neutral.png"
	]
	for path in paths:
		if cache.has(path):
			if cache[path] != null:
				return cache[path]
			continue
		var tex: Texture2D = null
		if ResourceLoader.exists(path, "Texture2D"):
			tex = load(path) as Texture2D
		cache[path] = tex
		if tex != null:
			return tex
	return null

func clear_cache() -> void:
	cache.clear()

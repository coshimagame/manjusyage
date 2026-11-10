extends Control
## Decorative petals rendered over the opaque backdrop and below dialogue/portrait.
## Preview-only original pixel effect; no canon character assets are replaced.
var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var region_height := size.y * 0.55
	for i in range(14):
		var phase := float(i) * 2.39996
		var x := fposmod(float(i) * 73.0 + sin(elapsed * 0.31 + phase) * 16.0, size.x)
		var y := fposmod(float(i) * 41.0 - elapsed * (5.0 + float(i % 4) * 2.0), region_height)
		var alpha := 0.11 + 0.09 * (0.5 + 0.5 * sin(elapsed + phase))
		var tone := Color(0.98, 0.26, 0.34, alpha)
		draw_rect(Rect2(Vector2(roundf(x), roundf(y)), Vector2(3.0, 2.0)), tone)
		draw_rect(Rect2(Vector2(roundf(x) + 1.0, roundf(y) - 1.0), Vector2(1.0, 4.0)), tone)

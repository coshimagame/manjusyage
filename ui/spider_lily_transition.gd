extends Control
## 第1面クリア後などに重ねられる、外部画像不要の仮・曼珠沙華花弁演出。
## 既存の正式キャラクター画像／ステージ描画を変更しない。
signal finished

@export_range(0.2, 6.0, 0.1) var duration: float = 1.6
@export_range(4, 64, 1) var petal_count: int = 24
@export var auto_start: bool = false
@export var bloom_color: Color = Color("#e84455")
@export var center_color: Color = Color("#fff0cf")
var _elapsed: float = 0.0
var _running: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if auto_start:
		play()

func play() -> void:
	_elapsed = 0.0
	_running = true
	visible = true
	set_process(true)
	queue_redraw()

func skip() -> void:
	if _running:
		_finish()

func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	if _elapsed >= duration:
		_finish()
	else:
		queue_redraw()

func _finish() -> void:
	_running = false
	set_process(false)
	visible = false
	finished.emit()

func _draw() -> void:
	if not _running:
		return
	var progress: float = clampf(_elapsed / maxf(duration, 0.01), 0.0, 1.0)
	var fade: float = minf(1.0, progress * 5.0) * minf(1.0, (1.0 - progress) * 4.0)
	var center: Vector2 = size * 0.5
	var spread: float = minf(size.x, size.y) * (0.08 + progress * 0.36)
	for i in range(petal_count):
		var angle: float = TAU * float(i) / float(petal_count) + progress * 0.35
		var radial: Vector2 = Vector2(cos(angle), sin(angle))
		var tangent: Vector2 = Vector2(-radial.y, radial.x)
		var seed: float = float((i * 37) % 19) / 19.0
		var tip: Vector2 = center + radial * spread * (0.6 + seed * 0.6)
		var root: Vector2 = center + radial * spread * 0.16
		var width: float = 3.0 + seed * 5.0
		var color: Color = bloom_color
		color.a = fade * (0.65 + seed * 0.35)
		draw_colored_polygon(PackedVector2Array([
			root, tip + tangent * width, tip + radial * (6.0 + seed * 7.0),
			tip - tangent * width
		]), color)
		draw_line(root, tip, center_color * Color(1, 1, 1, fade * 0.55), 1.0)
	draw_arc(center, 4.0 + progress * 10.0, 0.0, TAU, 24,
		Color(center_color.r, center_color.g, center_color.b, fade * 0.75), 1.0)

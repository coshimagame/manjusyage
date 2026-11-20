extends CanvasLayer
## Stage hazard / boss entrance warning. Add as a child of the gameplay scene.
## Call show_warning() when the stage director announces a boss or hazard.
## All artwork is drawn at runtime: no existing approved PNGs are replaced.

signal warning_finished

@export var default_duration: float = 1.8
@export var safe_margin: float = 24.0
@export var flash_frequency: float = 3.0
@export var warning_color: Color = Color(1.0, 0.20, 0.25, 0.85)

var _elapsed: float = 0.0
var _duration: float = 0.0
var _message: String = ""
var _active: bool = false
var _panel: Control

func _ready() -> void:
    layer = 20
    _panel = Control.new()
    _panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _panel.draw.connect(_draw_overlay)
    add_child(_panel)
    _panel.visible = false
    set_process(false)

func show_warning(message: String = "WARNING", duration: float = -1.0) -> void:
    _message = message.strip_edges()
    if _message.is_empty():
        _message = "WARNING"
    _duration = maxf(0.1, duration if duration > 0.0 else default_duration)
    _elapsed = 0.0
    _active = true
    _panel.visible = true
    set_process(true)
    _panel.queue_redraw()

func cancel_warning() -> void:
    if not _active:
        return
    _active = false
    _panel.visible = false
    set_process(false)
    warning_finished.emit()

func _process(delta: float) -> void:
    if not _active:
        return
    _elapsed += delta
    if _elapsed >= _duration:
        cancel_warning()
        return
    _panel.queue_redraw()

func _draw_overlay() -> void:
    if not _active:
        return
    var size := _panel.size
    if size.x <= 0.0 or size.y <= 0.0:
        return
    var blink := 0.55 + 0.45 * sin(_elapsed * TAU * flash_frequency)
    var color := warning_color
    color.a *= blink
    var band_height := minf(44.0, size.y * 0.15)
    var top := (size.y - band_height) * 0.5
    _panel.draw_rect(Rect2(0.0, top, size.x, band_height), Color(0.07, 0.02, 0.08, 0.85))
    _panel.draw_line(Vector2(safe_margin, top), Vector2(size.x - safe_margin, top), color, 2.0)
    _panel.draw_line(Vector2(safe_margin, top + band_height), Vector2(size.x - safe_margin, top + band_height), color, 2.0)
    var font := ThemeDB.fallback_font
    if font == null:
        return
    var font_size := 22
    var text_width := font.get_string_size(_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
    var pos := Vector2((size.x - text_width) * 0.5, top + band_height * 0.5 + font_size * 0.35)
    _panel.draw_string(font, pos, _message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

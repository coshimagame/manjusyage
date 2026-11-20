extends Control
## Reusable stage transition cue. Add as a child of a CanvasLayer.
## Call show_stage(stage_number) when the stage begins.
signal cue_finished

@export var duration: float = 2.0
@export var accent: Color = Color("#e84e61")
var remaining: float = 0.0
var stage_number: int = 1

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    visible = false

func show_stage(number: int) -> void:
    stage_number = clampi(number, 1, 8)
    remaining = maxf(duration, 0.1)
    visible = true
    queue_redraw()

func _process(delta: float) -> void:
    if remaining <= 0.0:
        return
    remaining = maxf(remaining - delta, 0.0)
    if remaining == 0.0:
        visible = false
        cue_finished.emit()
    queue_redraw()

func _draw() -> void:
    if remaining <= 0.0:
        return
    var width_px := size.x
    var height_px := size.y
    var elapsed := maxf(duration, 0.1) - remaining
    var fade := minf(1.0, elapsed * 4.0, remaining * 3.0)
    var panel := Color(0.02, 0.035, 0.09, 0.82 * fade)
    draw_rect(Rect2(0, height_px * 0.35, width_px, height_px * 0.3), panel)
    draw_rect(Rect2(0, height_px * 0.35, width_px, 2), Color(accent, fade))
    draw_rect(Rect2(0, height_px * 0.65 - 2, width_px, 2), Color(accent, fade))
    var font := ThemeDB.fallback_font
    var title := "STAGE %02d" % stage_number
    var font_size := 27
    var text_width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
    draw_string(font, Vector2((width_px - text_width) / 2.0, height_px * 0.52), title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 0.95, 0.93, fade))
    var subtitle := "MANJUSHAGE"
    var subtitle_width := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
    draw_string(font, Vector2((width_px - subtitle_width) / 2.0, height_px * 0.59), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.73, 0.83, 0.93, fade))

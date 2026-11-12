extends Control
## Original provisional pixel-workshop background. No approved character art is replaced.
## Drawn at native 640x360; dialogue panel is layered above this Control.
@export_file("*.png") var workshop_image_path := "res://art/active/interlude_workshop.png"
var workshop_texture: Texture2D
var elapsed := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    # Optional artwork: never overwrite the approved PNG or alter the fallback.
    if ResourceLoader.exists(workshop_image_path, "Texture2D"):
        workshop_texture = load(workshop_image_path) as Texture2D

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()

func _draw() -> void:
    if workshop_texture != null:
        var image_size := workshop_texture.get_size()
        if image_size.x > 0.0 and image_size.y > 0.0 and size.x > 0.0 and size.y > 0.0:
            # Cover, crop centrally; never stretch artwork out of proportion.
            var scale_factor: float = maxf(size.x / image_size.x, size.y / image_size.y)
            var draw_size: Vector2 = image_size * scale_factor
            var destination := Rect2((size - draw_size) * 0.5, draw_size)
            draw_texture_rect(workshop_texture, destination, false)
            return
    var sx := size.x / 640.0
    var sy := size.y / 360.0
    draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
    draw_rect(Rect2(0, 0, 640, 360), Color("#0b1327"))
    # Workshop gantry, diagnostic screens and maintenance bench.
    draw_rect(Rect2(0, 180, 640, 6), Color("#24354a"))
    for x in [50, 190, 450, 590]:
        draw_rect(Rect2(x, 0, 8, 240), Color("#27394b"))
        draw_rect(Rect2(x + 2, 10, 4, 190), Color("#43586b"))
    draw_rect(Rect2(80, 58, 120, 86), Color("#172d40"))
    draw_rect(Rect2(88, 66, 104, 70), Color("#10252e"))
    for i in range(5):
        var pulse := 3.0 + 3.0 * sin(elapsed * 2.2 + float(i))
        draw_rect(Rect2(98 + i * 17, 104 - pulse * 2.0, 8, 5 + pulse * 2.0), Color("#6cded4"))
    draw_rect(Rect2(320, 64, 142, 85), Color("#1c3147"))
    draw_rect(Rect2(329, 74, 124, 65), Color("#0d2433"))
    # Unidentified craft silhouette: deliberately not a protagonist's approved ship.
    var craft := PackedVector2Array([Vector2(275, 153), Vector2(326, 110), Vector2(380, 153), Vector2(340, 168), Vector2(306, 168)])
    draw_colored_polygon(craft, Color("#73869a"))
    draw_rect(Rect2(317, 137, 20, 12), Color("#8ad9e0"))
    draw_line(Vector2(326, 0), Vector2(326, 110), Color("#8798a6"), 3)
    draw_rect(Rect2(224, 169, 200, 12), Color("#4c5e70"))
    draw_rect(Rect2(218, 181, 12, 50), Color("#3c5063"))
    draw_rect(Rect2(414, 181, 12, 50), Color("#3c5063"))
    # Moving maintenance sparks, non-violent ambient effects.
    for i in range(7):
        var phase := fposmod(elapsed * (21.0 + float(i) * 3.0) + float(i) * 19.0, 68.0)
        var pos := Vector2(370 + float(i % 3) * 4.0 + phase * 0.3, 143 + phase * 0.65)
        draw_rect(Rect2(pos, Vector2(2, 2)), Color("#ffd68a", 1.0 - phase / 68.0))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

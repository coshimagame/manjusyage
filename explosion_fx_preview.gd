extends Node2D
## Independent 16-bit-inspired explosion preview. No existing art or gameplay modified.
## Press SPACE/ENTER or click to cycle through sizes. Runs at 640x360.
const PALETTE := [Color("#fff6be"), Color("#ffda62"), Color("#ff853d"), Color("#e83850"), Color("#82204e")]
const SIZES := [16.0, 30.0, 54.0, 86.0]
var particles: Array[Dictionary] = []
var burst_index := 0
var elapsed := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 20261106
    spawn_burst(Vector2(320, 180), SIZES[burst_index])

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        _next_burst()
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _next_burst()

func _next_burst() -> void:
    burst_index = (burst_index + 1) % SIZES.size()
    spawn_burst(Vector2(320, 180), SIZES[burst_index])

func spawn_burst(origin: Vector2, radius: float) -> void:
    # Deterministic radial particles, reusable for enemy/boss hits.
    for i in range(int(radius * 0.9) + 12):
        var a := rng.randf_range(0.0, TAU)
        var speed := rng.randf_range(radius * 0.6, radius * 2.2)
        var life := rng.randf_range(0.22, 0.72)
        particles.append({
            "origin": origin, "velocity": Vector2(cos(a), sin(a)) * speed,
            "age": 0.0, "life": life, "size": rng.randi_range(2, 6),
            "color": PALETTE[rng.randi_range(0, PALETTE.size() - 1)]
        })
    elapsed = 0.0
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    for i in range(particles.size() - 1, -1, -1):
        particles[i]["age"] += delta
        if particles[i]["age"] >= particles[i]["life"]:
            particles.remove_at(i)
    if particles.is_empty() and elapsed > 0.8:
        spawn_burst(Vector2(rng.randf_range(90.0, 550.0), rng.randf_range(75.0, 285.0)), SIZES[burst_index])
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(640, 360)), Color("#090b19"))
    for p in particles:
        var t: float = p["age"] / p["life"]
        var pos: Vector2 = p["origin"] + p["velocity"] * p["age"] * (1.0 - t * 0.28)
        var side: float = maxf(1.0, float(p["size"]) * (1.0 - t))
        var color: Color = p["color"]
        color.a = 1.0 - t
        draw_rect(Rect2(pos.snapped(Vector2.ONE), Vector2(side, side)), color)
    var label := "MANJUSHAGE  /  EXPLOSION FX PREVIEW   SPACE: NEXT   %d / 4" % (burst_index + 1)
    draw_string(ThemeDB.fallback_font, Vector2(12, 24), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d6e5ff"))

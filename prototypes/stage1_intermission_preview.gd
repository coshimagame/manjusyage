extends Node2D
## Isolated playable stage-1 intermission preview. Provisional dialogue; does not modify saves.
## Run: godot --path . res://prototypes/stage1_intermission_preview.tscn
const Intermission = preload("res://ui/stage_intermission_stage1.gd")

@export_range(1, 4) var worldline: int = 1
@export_range(1, 3) var active_players: int = 1

var overlay: Control

func _ready() -> void:
    overlay = Intermission.new()
    add_child(overlay)
    if not overlay.setup_after_stage(1, worldline, active_players):
        push_error("Stage 1 intermission dialogue is unavailable")
        return
    overlay.completed.connect(_finish)
    overlay.skipped.connect(_finish)

func _finish(_next_stage: int) -> void:
    # Preview returns to title; real stage-2 launch is a separate integration task.
    get_tree().change_scene_to_file("res://main.tscn")

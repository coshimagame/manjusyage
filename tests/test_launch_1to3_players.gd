extends SceneTree
# 1–3人の「出撃」初期化を実シーンで検査する。
# Godot 4.6: godot --headless --path . --script res://tests/test_launch_1to3_players.gd
# 既存のユーザーセーブと区別したプロファイルで実行すること。
# これは自動状態検査であり、人間の操作・音声・ボス撃破の保証ではない。

const GAME_SCENE := "res://main.tscn"

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("LAUNCH FLOW FAIL: " + message)
    quit(1)

func _run() -> void:
    var packed := load(GAME_SCENE) as PackedScene
    if packed == null:
        _fail("main.tscn cannot load")
        return
    var game := packed.instantiate()
    if game == null:
        _fail("main.tscn cannot instantiate")
        return
    root.add_child(game)
    await process_frame
    for n in range(1, 4):
        game.count = n
        game.briefing_custom_squad = false
        game.start_game()
        await process_frame
        if game.mode != "play":
            _fail("player count %d: mode is not play" % n)
            return
        if game.players.size() != n:
            _fail("player count %d: wrong ship count" % n)
            return
        if game.reserves != n * 3:
            _fail("player count %d: wrong reserve count" % n)
            return
        var characters := {}
        for pilot in game.players:
            if not pilot.has("character") or not pilot.has("hp") or not pilot.has("pos"):
                _fail("player count %d: missing playable state" % n)
                return
            if int(pilot.hp) <= 0:
                _fail("player count %d: player starts without HP" % n)
                return
            characters[int(pilot.character)] = true
        if characters.size() != n:
            _fail("player count %d: duplicate character assignment" % n)
            return
        if not game.bullets.is_empty() or not game.enemies.is_empty():
            _fail("player count %d: previous battle leaked into launch" % n)
            return
    print("LAUNCH FLOW PASS: 1P, 2P, 3P initial states (not full playthrough)")
    game.queue_free()
    quit(0)

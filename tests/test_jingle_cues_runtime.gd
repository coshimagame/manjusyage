extends SceneTree
# Godot 4.6 headless smoke test for the actual PCM launch/boss/clear/fail jingles.
# Run: godot --headless --path . --script res://tests/test_jingle_cues_runtime.gd
const Jingles = preload("res://jingle_cues.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	for cue in ["launch", "boss", "clear", "fail"]:
		var stream: AudioStreamWAV = Jingles.make_stream(cue)
		if stream == null:
			errors.append(cue + ": stream is null")
			continue
		if stream.format != AudioStreamWAV.FORMAT_16_BITS:
			errors.append(cue + ": not 16-bit PCM")
		if stream.mix_rate != Jingles.RATE:
			errors.append(cue + ": unexpected sample rate")
		if stream.stereo:
			errors.append(cue + ": unexpectedly stereo")
		if stream.data.is_empty() or stream.data.size() % 2 != 0:
			errors.append(cue + ": missing/odd-sized PCM data")
		if stream.get_length() <= 0.0:
			errors.append(cue + ": zero duration")
		var player := AudioStreamPlayer.new()
		root.add_child(player)
		player.stream = stream
		player.play()
		if not player.playing:
			errors.append(cue + ": AudioStreamPlayer did not start")
		player.stop()
		player.queue_free()
	if errors.is_empty():
		print("PASS: all four jingles produce playable 16-bit PCM streams")
		quit(0)
	else:
		for message in errors:
			push_error(message)
		quit(1)

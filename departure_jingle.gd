extends RefCounted
## Original short launch cue. Generated in memory so no external audio asset is overwritten.
## Called when the pilot selection transitions into stage 01.
const SAMPLE_RATE := 32000
const LENGTH := 0.82
const NOTES := [392.0, 523.25, 659.25, 783.99]
const NOTE_START := [0.0, 0.13, 0.26, 0.39]

static func play(parent: Node) -> void:
	var pcm := PackedByteArray()
	var sample_count := int(SAMPLE_RATE * LENGTH)
	pcm.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / SAMPLE_RATE
		var amplitude := 0.0
		for j in range(NOTES.size()):
			var local_t := t - NOTE_START[j]
			if local_t < 0.0 or local_t >= 0.32:
				continue
			var envelope := pow(1.0 - local_t / 0.32, 2.0)
			var phase := TAU * NOTES[j] * local_t
			# Warm triangle fundamental plus a quiet overtone.
			var triangle := (2.0 / PI) * asin(sin(phase))
			amplitude += envelope * (triangle * 0.23 + sin(phase * 2.0) * 0.045)
		var fade := minf(1.0, (LENGTH - t) / 0.15)
		var sample := int(clampf(amplitude * maxf(0.0, fade), -0.95, 0.95) * 32767.0)
		pcm[i * 2] = sample & 255
		pcm[i * 2 + 1] = (sample >> 8) & 255
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = pcm
	var player := AudioStreamPlayer.new()
	parent.add_child(player)
	player.stream = stream
	player.volume_db = -4.0
	player.finished.connect(player.queue_free)
	player.play()

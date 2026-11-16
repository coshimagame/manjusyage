extends AudioStreamPlayer
## Original, runtime-generated 16-bit PCM departure cue.
## Attach this node to a scene and call play_departure() on the 出撃 transition.
## No external samples or approved art are changed.

const SAMPLE_RATE := 22050
const CUE_SECONDS := 0.92
const NOTE_FREQUENCIES := [293.66, 369.99, 440.0, 587.33]
const NOTE_STARTS := [0.0, 0.16, 0.32, 0.51]

func _ready() -> void:
	stream = _build_cue()

func play_departure() -> void:
	if stream == null:
		stream = _build_cue()
	stop()
	play()

func _build_cue() -> AudioStreamWAV:
	var count := int(SAMPLE_RATE * CUE_SECONDS)
	var pcm := PackedByteArray()
	pcm.resize(count * 2)
	for i in range(count):
		var t := float(i) / float(SAMPLE_RATE)
		var sample := 0.0
		for n in range(NOTE_FREQUENCIES.size()):
			var elapsed := t - NOTE_STARTS[n]
			if elapsed < 0.0:
				continue
			var envelope := exp(-elapsed * 7.0) * minf(1.0, elapsed * 95.0)
			var freq: float = NOTE_FREQUENCIES[n]
			var fundamental := sin(TAU * freq * elapsed)
			var overtone := 0.23 * sin(TAU * freq * 2.0 * elapsed)
			sample += (fundamental + overtone) * envelope * 0.19
		var tail := maxf(0.0, 1.0 - t / CUE_SECONDS)
		var value := int(clampf(sample * tail, -1.0, 1.0) * 32767.0)
		pcm[i * 2] = value & 255
		pcm[i * 2 + 1] = (value >> 8) & 255
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = pcm
	return wav

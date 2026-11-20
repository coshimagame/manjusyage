extends AudioStreamPlayer
## Original 16-bit-style departure cue, generated at runtime without external assets.
## Add this node to a scene, then call play_departure() at launch.
## All pitches and rhythm here are newly composed for MANJUSHAGE.
const SAMPLE_RATE := 22050
const NOTES := [
	[0, 57, 0.16], [0.16, 64, 0.16], [0.32, 69, 0.24],
	[0.56, 72, 0.18], [0.74, 76, 0.34], [1.08, 69, 0.28]
]

func play_departure() -> void:
	stream = _build_cue()
	volume_db = -9.0
	play()

func _build_cue() -> AudioStreamWAV:
	var length_seconds := 1.55
	var sample_count := int(ceil(length_seconds * SAMPLE_RATE))
	var pcm := PackedByteArray()
	pcm.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / SAMPLE_RATE
		var signal := 0.0
		for note in NOTES:
			var start := float(note[0])
			var duration := float(note[2])
			var age := t - start
			if age < 0.0 or age >= duration:
				continue
			var frequency := 440.0 * pow(2.0, (float(note[1]) - 69.0) / 12.0)
			var phase := age * frequency
			var triangle := 2.0 * abs(2.0 * (phase - floor(phase + 0.5))) - 1.0
			var envelope := minf(1.0, age / 0.018) * minf(1.0, (duration - age) / 0.09)
			signal += triangle * envelope * 0.26
			signal += sin(TAU * phase * 0.5) * envelope * 0.07
		var value := clampi(int(round(clampf(signal, -1.0, 1.0) * 32767.0)), -32768, 32767)
		var unsigned := value & 0xffff
		pcm[i * 2] = unsigned & 0xff
		pcm[i * 2 + 1] = (unsigned >> 8) & 0xff
	var result := AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = SAMPLE_RATE
	result.stereo = false
	result.data = pcm
	return result

extends RefCounted
# Original procedural 8-bit jingles. No external samples or copyrighted melodies.
const RATE = 22050
const NOTES = {
	"launch": [[659.25,0.12],[783.99,0.12],[987.77,0.16],[1318.51,0.35]],
	"boss": [[196.00,0.17],[185.00,0.17],[293.66,0.17],[369.99,0.24],[392.00,0.36]],
	"clear": [[523.25,0.13],[659.25,0.13],[783.99,0.13],[1046.50,0.45]],
	"fail": [[392.00,0.18],[311.13,0.18],[246.94,0.40]]
}
static func make_stream(cue: String) -> AudioStreamWAV:
	var sequence: Array = NOTES.get(cue, NOTES["launch"])
	var pcm = PackedByteArray()
	for note in sequence:
		var freq: float = float(note[0])
		var duration: float = float(note[1])
		var samples: int = int(duration * RATE)
		for i in range(samples):
			var t: float = float(i) / RATE
			var envelope: float = minf(1.0,t/0.012) * minf(1.0,(duration-t)/0.06)
			var square: float = 1.0 if sin(TAU*freq*t)>=0.0 else -1.0
			var sub: float = sin(TAU*freq*0.5*t)
			var value: int = clampi(int((square*0.22+sub*0.11)*envelope*32767.0),-32768,32767)
			pcm.append(value & 255)
			pcm.append((value >> 8) & 255)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = pcm
	return stream

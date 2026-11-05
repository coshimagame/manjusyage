extends RefCounted
# Original ambient-electronica sketch: glassy arpeggios, soft pads, restrained beat.
# Generated in Godot; no external samples or borrowed melodies.
const RATE = 16000
const BPM = 112.0
const BEAT = 60.0 / BPM
const BARS = 8
const LENGTH = BARS * 4.0 * BEAT
const CHORDS = [[57,60,64,69],[53,57,60,64],[48,52,55,59],[55,59,62,67]]
static var cached: AudioStreamWAV

static func _hz(midi: int) -> float:
	return 440.0 * pow(2.0,(float(midi)-69.0)/12.0)

static func _tone(t: float, freq: float) -> float:
	return sin(TAU*freq*t) + 0.25*sin(TAU*freq*2.01*t)

static func make_stream() -> AudioStreamWAV:
	if cached != null: return cached
	var data = PackedByteArray()
	var total = int(LENGTH * RATE)
	data.resize(total*2)
	for i in range(total):
		var t = float(i)/RATE
		var beat = t/BEAT
		var bar = int(beat/4.0)
		var chord: Array = CHORDS[bar % CHORDS.size()]
		var local_beat = fmod(beat,4.0)
		# Slowly breathing harmonics, softened for long listening.
		var pad = 0.0
		for n in range(3):
			var f = _hz(int(chord[n]))
			pad += sin(TAU*f*t + 0.20*sin(TAU*0.17*t+n))*0.055
		var step = int(floor(beat*2.0)) % 8
		var note = int(chord[[0,2,1,3,2,1,0,2][step]]) + 12
		var phase = fmod(beat*2.0,1.0)
		var arp_env = pow(maxf(0.0,1.0-phase),2.4)
		var arp = _tone(t,_hz(note))*arp_env*0.095
		var bass = sin(TAU*_hz(int(chord[0])-24)*t)*0.11
		var kick_phase = fmod(beat,1.0)
		var kick = sin(TAU*(64.0-32.0*kick_phase)*kick_phase*BEAT)*exp(-kick_phase*18.0)*0.14
		var hat_phase = fmod(beat*2.0,1.0)
		var noise = sin(float(i)*12.9898)*sin(float(i)*78.233)
		var hat = noise*exp(-hat_phase*30.0)*0.012
		var intro = minf(1.0,t/1.4)
		var outro = minf(1.0,(LENGTH-t)/0.12)
		var value = clampi(int((pad+arp+bass+kick+hat)*intro*outro*21000.0),-32768,32767)
		data[i*2] = value & 255
		data[i*2+1] = (value >> 8) & 255
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total
	stream.data = data
	cached = stream
	return stream

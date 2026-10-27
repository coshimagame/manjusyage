"""Original heroic chiptunes. Run make_audio.py for SFX, then this for version 0.2 music."""
import math, wave, random, array
from pathlib import Path
OUT=Path(__file__).resolve().parents[1]/'audio'
OUT.mkdir(exist_ok=True)
RATE=22050
random.seed(92)
def freq(n): return 440*2**((n-69)/12)
def song(name,bpm,kind):
    step=60/bpm/4
    bars=16 if kind=='title' else 48
    out=[0.] * int(bars*16*step*RATE)
    # Original E minor / C / G / D hook; long answers alternate with ascending runs.
    melody=[[(0,76,2),(2,79,2),(4,83,3),(8,86,2),(10,83,2),(12,81,2),(14,79,2)],
            [(0,76,3),(4,79,2),(6,84,2),(8,83,4),(12,79,4)],
            [(0,79,2),(2,83,2),(4,86,3),(8,88,2),(10,86,2),(12,83,2),(14,81,2)],
            [(0,78,3),(4,81,2),(6,86,2),(8,83,2),(10,81,2),(12,78,4)],
            [(0,83,3),(4,86,2),(6,88,2),(8,90,3),(12,88,2),(14,86,2)],
            [(0,88,2),(2,86,2),(4,84,4),(8,83,2),(10,79,2),(12,76,4)],
            [(0,79,2),(2,81,2),(4,83,2),(6,86,2),(8,91,4),(12,86,2),(14,83,2)],
            [(0,81,2),(2,83,2),(4,86,4),(8,83,2),(10,81,2),(12,78,2),(14,74,2)]]
    roots=[40,36,43,38,40,36,43,38]
    thirds=[3,4,4,4,3,4,4,4]
    def add(start,duration,note,volume,voice,duty=.25):
        offset=int(start*RATE); length=int(duration*RATE); hz=freq(note)
        for i in range(min(length,len(out)-offset)):
            t=i/RATE
            env=min(1,i/65)*min(1,(length-i)/180)
            if voice=='pulse':
                phase=(t*hz+.003*math.sin(t*35))%1
                value=(1 if phase<duty else -1)*(.85+.15*math.exp(-t*10))
            elif voice=='triangle':value=1-4*abs((t*hz)%1-.5)
            elif voice=='kick':value=math.sin(2*math.pi*(48*t+2.6*(1-math.exp(-t*36))))*math.exp(-t*22)
            else:value=random.uniform(-1,1)*math.exp(-t*(65 if voice=='hat' else 22))
            out[offset+i]+=value*volume*env
    for bar in range(bars):
        section=bar//8
        root=roots[bar%8]; third=thirds[bar%8]
        offset=bar*16*step
        for start,note,duration in melody[bar%8]:
            pitch=note-12 if section==2 and kind!='title' else note
            if kind=='boss':pitch-=2
            add(offset+start*step,duration*step*.9,pitch,.23,'pulse',.125 if kind=='boss' else .25)
            if section in (1,4,5):add(offset+(start+.4)*step,duration*step*.72,pitch-12,.045,'pulse',.5)
        for s in range(16):
            t=offset+s*step
            chord=[0,third,7,12][s%4]
            add(t,step*.75,root+24+chord,.055,'pulse',.125)
            if s%2==0:add(t,step*1.75,root+(12 if s%4==2 else 0),.25,'triangle')
            if s in (0,6,8,14):add(t,.15,0,.36,'kick')
            if s in (4,12):add(t,.14,0,.25,'snare')
            if s%2==0 or kind=='boss':add(t,.035,0,.085,'hat')
            if bar%8==7 and s>=12:add(t,.08,0,.13,'snare')
    peak=max(abs(v) for v in out) or 1
    samples=array.array('h',(int(x*.86/peak*32767) for x in out))
    with wave.open(str(OUT/name),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(samples.tobytes())
    print(name,round(len(out)/RATE,1),'seconds')
song('title.wav',160,'title')
song('ruins.wav',176,'stage')
song('sentinel.wav',192,'boss')

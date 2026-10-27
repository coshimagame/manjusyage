import math, wave, random, struct
from pathlib import Path

OUT=Path(__file__).resolve().parents[1]/'audio'
OUT.mkdir(exist_ok=True)
RATE=22050
random.seed(91)

def freq(n): return 440*2**((n-69)/12)
def write(name,data):
    with wave.open(str(OUT/name),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,x))*27000)) for x in data))

def song(name,bpm,boss=False):
    step=60/bpm/4
    bars=32
    out=[0.]*(int(bars*16*step*RATE))
    roots=[40,36,43,38,40,36,45,38]
    # Original two-part melody, 16th-note pulse lead / arpeggio / triangle bass / noise drums.
    motifs=[[12,-1,19,24,22,19,15,19,12,-1,15,19,22,19,15,10],
            [12,15,19,-1,24,22,19,15,17,19,22,-1,19,15,14,10],
            [24,-1,22,19,15,19,22,24,26,24,22,19,22,19,15,19],
            [19,17,15,14,12,-1,10,14,15,19,22,19,14,10,7,-1]]
    def add(start,duration,note,volume,kind,duty=.25):
        start=int(start*RATE); length=int(duration*RATE)
        hz=freq(note)
        for i in range(min(length,len(out)-start)):
            t=i/RATE
            env=min(1,i/90)*min(1,(length-i)/260)
            phase=(t*hz)%1
            if kind=='pulse': v=(1 if phase<duty else -1)*.7
            elif kind=='triangle': v=1-4*abs(phase-.5)
            elif kind=='kick': v=math.sin(2*math.pi*(95*t-50*t*t))*math.exp(-t*28)
            else: v=random.uniform(-1,1)*math.exp(-t*(55 if kind=='hat' else 24))
            out[start+i]+=v*volume*env
    for bar in range(bars):
        root=roots[bar%8] + (0 if not boss else -2)
        motif=motifs[(bar//2)%4]
        for s in range(16):
            t=(bar*16+s)*step
            n=motif[s]
            if n>=0: add(t,step*.83,root+n+(12 if bar>=16 else 0),.15,'pulse',.125 if boss else .25)
            add(t,step*.65,root+24+[0,7,12,15][s%4],.055,'pulse',.125)
            if s%2==0: add(t,step*1.65,root+(12 if s%4==2 else 0),.21,'triangle')
            if s in (0,6,8,14): add(t,.13,0,.27,'kick')
            if s in (4,12): add(t,.13,0,.18,'snare')
            if s%2==0: add(t,.04,0,.07,'hat')
    write(name,out)

song('ruins.wav',150)
song('sentinel.wav',174,True)
for name,start,end,dur,vol in [('shot',1100,450,.055,.15),('switch',440,880,.12,.2),('hit',160,40,.22,.3),('burst',80,25,.5,.38),('gate',330,1320,.45,.23),('pickup',660,1320,.15,.2)]:
    a=[];phase=0
    for i in range(int(RATE*dur)):
        t=i/(RATE*dur);phase+=(start+(end-start)*t)/RATE
        v=(1 if phase%1<.25 else -1)
        if name in ('hit','burst'):v=.4*v+.6*random.uniform(-1,1)
        a.append(v*vol*(1-t)**1.5)
    write(name+'.wav',a)
print('Original music and six sound effects generated:',OUT)

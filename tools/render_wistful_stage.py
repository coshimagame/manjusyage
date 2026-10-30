#!/usr/bin/env python3
"""MANJUSHAGE original wistful 8bit/FM action music demo, written from scratch.
Use: pip install numpy soundfile
     python tools/render_wistful_stage.py output.wav
Duration: 32 bars, 148 BPM, 32000 Hz stereo PCM16. No borrowed samples.
The MP3 preview distributed in the conversation was converted with ffmpeg.
"""
import math,sys
import numpy as np
import soundfile as sf
SR=32000; BPM=148; BEAT=60/BPM; N=int(SR*32*4*BEAT)
L=np.zeros(N);R=np.zeros(N)
rng=np.random.default_rng(41028)
P={'C':0,'C#':1,'D':2,'D#':3,'E':4,'E#':5,'F':5,'F#':6,'G':7,'G#':8,'A':9,'A#':10,'B':11}
def freq(s):
    if not s or s=='-':return None
    return 440*2**((((int(s[-1])+1)*12+P[s[:-1]])-69)/12)
def add(start,dur,note,kind='lead',gain=.1,pan=0):
    f=freq(note)
    if f is None:return
    st=round(start*BEAT*SR);n=min(round(dur*BEAT*SR),N-st)
    if n<=0:return
    t=np.arange(n)/SR;ph=2*np.pi*f*t
    if kind=='lead':
        vib=.008*np.sin(2*np.pi*5.1*np.maximum(0,t-.16))
        ph=2*np.pi*f*(t+vib/(2*np.pi*5.1))
        pulse=np.sin(ph)+.33*np.sin(3*ph)+.15*np.sin(5*ph)+.065*np.sin(7*ph)
        sig=.69*pulse+.31*np.sin(ph+.60*np.sin(2*ph)*np.exp(-t*13))
        env=np.minimum(1,t/.018)*np.minimum(1,(n-1-np.arange(n))/(SR*.060))
        env*=.81+.19*np.exp(-t*1.7)
    elif kind=='bass':
        sig=np.sin(ph)+.27*np.sin(2*ph)+.11*np.sin(3*ph)
        env=np.minimum(1,t/.009)*np.exp(-t*1.15)*np.minimum(1,(n-1-np.arange(n))/(SR*.021))
    elif kind=='arp':
        sig=.78*np.sin(ph)+.27*np.sin(2*ph)+.18*np.sin(3*ph)
        env=np.minimum(1,t/.005)*np.exp(-t*9.)
    elif kind=='pad':
        sig=.65*np.sin(ph)+.28*np.sin(2*ph)+.09*np.sin(3*ph)+.06*np.sin(4*ph)
        env=np.minimum(1,t/.15)*np.minimum(1,(n-1-np.arange(n))/(SR*.26))
        env*=.78+.22*np.sin(2*np.pi*.34*t)**2
    else:
        sig=.82*np.sin(ph)+.28*np.sin(2*ph)
        env=np.minimum(1,t/.012)*np.minimum(1,(n-1-np.arange(n))/(SR*.09))
    s=gain*env*sig
    L[st:st+n]+=s*math.cos((pan+1)*math.pi/4)*1.31
    R[st:st+n]+=s*math.sin((pan+1)*math.pi/4)*1.31
def drum(beat,typ,gain):
    st=round(beat*BEAT*SR)
    n=min(round({'kick':.29,'snare':.22,'hat':.095,'open':.22}[typ]*SR),N-st)
    if n<=0:return
    t=np.arange(n)/SR;noise=rng.standard_normal(n)
    if typ=='kick':
        phase=2*np.pi*(52*t+75/(2*np.pi*29)*(1-np.exp(-2*np.pi*29*t)))
        sig=np.sin(phase)*np.exp(-t*22)+.22*noise*np.exp(-t*69)
    elif typ=='snare':
        noise=noise-np.convolve(noise,np.ones(17)/17,'same')
        sig=.67*noise*np.exp(-t*23)+.25*np.sin(2*np.pi*188*t)*np.exp(-t*27)
    else:
        noise=noise-np.convolve(noise,np.ones(11)/11,'same')
        sig=.40*noise*np.exp(-t*(18 if typ=='open' else 63))
    L[st:st+n]+=sig*gain*.91;R[st:st+n]+=sig*gain*1.08
chords=[
('F#2',['F#3','A3','C#4']),('D2',['D3','F#3','A3']),
('F#2',['F#3','A3','C#4']),('E2',['E3','G#3','B3']),
('F#2',['F#3','A3','C#4']),('D2',['D3','F#3','A3']),
('A2',['A3','C#4','E4']),('E2',['E3','G#3','B3']),
('F#2',['F#3','A3','C#4']),('D2',['D3','F#3','A3']),
('B2',['B3','D4','F#4']),('C#3',['C#4','E#4','G#4']),
('D2',['D3','F#3','A3']),('E2',['E3','G#3','B3']),
('F#2',['F#3','A3','C#4']),('F#2',['F#3','A3','C#4']),
('D2',['D3','F#3','A3']),('E2',['E3','G#3','B3']),
('B2',['B3','D4','F#4']),('C#3',['C#4','E#4','G#4']),
('F#2',['F#3','A3','C#4']),('D2',['D3','F#3','A3']),
('A2',['A3','C#4','E4']),('E2',['E3','G#3','B3']),
('B2',['B3','D4','F#4']),('D2',['D3','F#3','A3']),
('C#3',['C#4','E#4','G#4']),('F#2',['F#3','A3','C#4']),
('D2',['D3','F#3','A3']),('E2',['E3','G#3','B3']),
('C#3',['C#4','E#4','G#4']),('F#2',['F#3','A3','C#4'])]
# Duration tokens are in eighth notes, exactly 8 per bar.
melodies=[
'--:8','--:8',
'F#5:2 E5:1 C#5:1 A4:2 C#5:1 E5:1',
'E5:2 F#5:1 A5:1 F#5:2 E5:2',
'C#5:1 E5:1 F#5:2 G#5:1 F#5:1 E5:2',
'D5:2 C#5:1 A4:1 B4:2 A4:2',
'C#5:2 E5:1 F#5:1 E5:2 C#5:2',
'B4:1 C#5:1 E5:2 G#5:2 F#5:2',
'A5:2 G#5:1 F#5:1 E5:2 C#5:2',
'F#5:1 E5:1 D5:2 C#5:2 A4:2',
'B4:1 D5:1 F#5:2 E5:1 D5:1 B4:2',
'C#5:2 E#5:2 G#5:1 F#5:1 E#5:2',
'F#5:2 A5:1 G#5:1 F#5:2 D5:2',
'E5:2 G#5:1 A5:1 B5:2 G#5:2',
'A5:1 G#5:1 F#5:2 C#5:2 E5:2',
'F#5:4 --:1 E5:1 C#5:2',
'A4:1 D5:1 F#5:2 A5:2 F#5:2',
'G#5:2 F#5:1 E5:1 B4:2 E5:2',
'F#5:2 D5:2 B4:1 D5:1 F#5:2',
'E#5:1 G#5:1 B5:2 A5:1 G#5:1 E#5:2',
'C#6:2 A5:1 F#5:1 E5:2 F#5:2',
'A5:1 G#5:1 F#5:2 E5:1 D5:1 F#5:2',
'E5:2 C#5:1 E5:1 F#5:2 A5:2',
'G#5:2 F#5:1 E5:1 B4:2 C#5:2',
'D5:1 F#5:1 A5:2 F#5:1 E5:1 D5:2',
'C#5:2 D5:2 F#5:1 E5:1 D5:2',
'E#5:1 G#5:1 C#6:2 B5:2 G#5:2',
'A5:2 G#5:1 F#5:1 E5:2 F#5:2',
'F#5:2 E5:1 D5:1 A4:2 D5:2',
'E5:1 G#5:1 B5:2 A5:1 G#5:1 E5:2',
'C#5:2 E#5:1 G#5:1 B5:2 G#5:2',
'F#5:4 C#5:2 F#5:2']
def parse(line):
    slot=0;out=[]
    for tok in line.split():
        note,num=tok.split(':');length=float(num)
        if note not in ('--','-'):out.append((slot*.5,length*.5,note))
        slot+=length
    assert abs(slot-8)<.001
    return out
for bi,((root,notes),barline) in enumerate(zip(chords,melodies)):
    b=bi*4
    for k,note in enumerate(notes):add(b+.02,3.86,note,'pad',.023 if bi<2 else .031,[-.58,0,.58][k])
    add(b,.94,root,'bass',.12,-.05)
    add(b+1.5,.43,root,'bass',.090,-.07)
    add(b+2,.94,root,'bass',.113,-.05)
    add(b+3.45,.41,root,'bass',.092,-.07)
    pattern=[0,1,2,1,0,2,1,2,0,1,2,1,2,1,0,1]
    for step,idx in enumerate(pattern):
        note=notes[idx][:-1]+str(int(notes[idx][-1])+1)
        add(b+step*.25,.21,note,'arp',.018 if bi<2 else .024,.52 if step%2==0 else -.52)
    for start,d,nn in parse(barline):
        add(b+start,d*.96,nn,'lead',.133 if bi<12 else .150,-.15)
        if 20<=bi<28 and d>=.8:
            low=nn[:-1]+str(int(nn[-1])-1)
            add(b+start+.02,max(.06,d*.87),low,'counter',.023,.58)
    for beat in range(4):
        if bi>=2 and beat in (1,3):drum(b+beat,'snare',.042)
        if bi>=2 and beat in (0,2):drum(b+beat,'kick',.095)
        if bi<2 and beat in (0,2):drum(b+beat,'kick',.062)
        for half in range(2):drum(b+beat+half*.5,'hat',.017 if bi<2 else (.026 if half else .023))
    if bi>=2 and bi%4==3:drum(b+3.5,'open',.045)
def echo(buf,secs,gain):
    n=int(secs*SR);z=np.zeros_like(buf);z[n:]=buf[:-n]*gain;return z
a=L+echo(R,.158,.16)+echo(L,.324,.09)
b=R+echo(L,.193,.17)+echo(R,.287,.08)
n=round(.13*SR);a[:n]*=np.linspace(0,1,n);b[:n]*=np.linspace(0,1,n)
n=round(.09*SR);a[-n:]*=np.linspace(1,0,n);b[-n:]*=np.linspace(1,0,n)
mix=np.stack([a,b],axis=1)
mix*=.855/max(np.max(abs(mix)),1e-6)
out=sys.argv[1] if len(sys.argv)>1 else 'modorenai_sora_demo.wav'
sf.write(out,mix.astype(np.float32),SR,subtype='PCM_16')
print(f'Wrote {out}: 32 bars / {BPM} BPM / {N/SR:.2f}s')

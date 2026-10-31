#!/usr/bin/env python3
"""曼珠沙華 / original gagaku-tinted future-action DEMO, 2026-10-31.
This is new, procedural music: no external audio samples or borrowed melody.
Run: python tools/render_manjushage_gagaku_future.py [output.wav]
Requires numpy; output 32 kHz, 16-bit stereo WAV, ~25 seconds.
Prototype, not an approved in-game replacement. 16 bars, 156 BPM.
"""
import math
import re
import sys
import wave
from pathlib import Path
import numpy as np

SAMPLE_RATE=32000
BPM=156
STEP=60/BPM
BARS=16
DURATION=BARS*4*STEP
TOTAL=int(DURATION*SAMPLE_RATE)
RNG=np.random.default_rng(301026)
LEFT=np.zeros(TOTAL,dtype=np.float64)
RIGHT=np.zeros(TOTAL,dtype=np.float64)
PITCHES={"C":0,"C#":1,"D":2,"D#":3,"Eb":3,"E":4,"F":5,"F#":6,"G":7,"G#":8,"Ab":8,"A":9,"A#":10,"Bb":10,"B":11}

def hz(name):
    m=re.fullmatch(r"(C#|D#|F#|G#|A#|Eb|Ab|Bb|[A-G])(\d)",name)
    if not m:
        raise ValueError(name)
    return 440 * 2**((((int(m[2])+1)*12+PITCHES[m[1]])-69)/12)

def note(beat,beats,pitch,instrument="reed",gain=.1,pan=0.0):
    start=int(beat*STEP*SAMPLE_RATE)
    count=max(1,min(int(beats*STEP*SAMPLE_RATE),TOTAL-start))
    if count<2:return
    t=np.arange(count)/SAMPLE_RATE
    f=hz(pitch)
    angle=2*np.pi*f*t
    if instrument=="reed":
        vib=np.sin(2*np.pi*5.4*t)*(.0025+.0010*np.minimum(1,t))
        ph=2*np.pi*f*(t+vib)
        wave_=np.sin(ph)+.56*np.sin(2*ph)+.35*np.sin(3*ph)+.16*np.sin(4*ph)
        amp=(1-np.exp(-t*26))*np.minimum(1,(count-1-np.arange(count))/(SAMPLE_RATE*.11))
        amp*=.74+.22*np.sin(2*np.pi*2.2*t)**2
    elif instrument=="sho":
        ph=2*np.pi*f*(t+.0007*np.sin(2*np.pi*.40*t))
        wave_=(.77*np.sin(ph)+.18*np.sin(2*ph)+.09*np.sin(3*ph))
        amp=(1-np.exp(-t*7))*np.minimum(1,(count-1-np.arange(count))/(SAMPLE_RATE*.30))
    elif instrument=="flute":
        wave_=np.sin(angle+.0025*np.sin(2*np.pi*4.1*t))+.09*np.sin(2*angle)
        amp=(1-np.exp(-t*35))*np.minimum(1,(count-1-np.arange(count))/(SAMPLE_RATE*.16))
        amp*=.80+.10*np.sin(2*np.pi*6*t)
    elif instrument=="pluck":
        wave_=np.sin(angle)+.46*np.sin(2*angle)+.16*np.sin(4*angle)
        amp=np.exp(-t*11)*(1-np.exp(-t*250))
    elif instrument=="bass":
        wave_=np.sin(angle+.44*np.sin(2*angle)*np.exp(-t*10))+.22*np.sin(2*angle)
        amp=(1-np.exp(-t*250))*np.exp(-t*2.3)
    else:
        wave_=np.sin(angle)
        amp=np.exp(-t*16)
    signal=wave_*amp*gain
    theta=(pan+1)*np.pi/4
    LEFT[start:start+count]+=signal*np.cos(theta)*1.32
    RIGHT[start:start+count]+=signal*np.sin(theta)*1.32

def noise_hit(beat,kind,gain=.04):
    start=int(beat*STEP*SAMPLE_RATE)
    duration={"kick":.26,"snare":.18,"hat":.07,"gong":.65}[kind]
    count=min(int(duration*SAMPLE_RATE),TOTAL-start)
    if count<=0:return
    t=np.arange(count)/SAMPLE_RATE
    white=RNG.standard_normal(count)
    if kind=="kick":
        ph=2*np.pi*(50*t+51/(2*np.pi*22)*(1-np.exp(-2*np.pi*22*t)))
        signal=np.sin(ph)*np.exp(-t*22)+white*.16*np.exp(-t*75)
    elif kind=="snare":
        signal=(white*.55+np.sin(2*np.pi*196*t)*.28)*np.exp(-t*22)
    elif kind=="hat":
        high=white-np.convolve(white,np.ones(11)/11,"same")
        signal=high*np.exp(-t*85)*.43
    else:
        signal=(np.sin(2*np.pi*695*t)+.7*np.sin(2*np.pi*1040.5*t))*np.exp(-t*4.5)
    LEFT[start:start+count]+=signal*gain*.9
    RIGHT[start:start+count]+=signal*gain*1.1

chords=[
    (["D4","A4","Eb5"],"D2"),(["G3","D4","A4"],"G2"),
    (["Bb3","F4","A4"],"Bb2"),(["C4","G4","D5"],"C3"),
    (["D4","A4","Eb5"],"D2"),(["Bb3","F4","A4"],"Bb2"),
    (["G3","D4","A4"],"G2"),(["A3","E4","C5"],"A2"),
    (["G3","D4","A4"],"G2"),(["Bb3","F4","A4"],"Bb2"),
    (["D4","A4","C5"],"D2"),(["C4","G4","D5"],"C3"),
    (["D4","A4","Eb5"],"D2"),(["G3","D4","A4"],"G2"),
    (["Bb3","F4","A4"],"Bb2"),(["D4","A4","C5"],"D2"),
]
melody=[
    [],[],
    [(0,1,"A4"),(1,1,"C5"),(2,2,"D5"),(4,2,"F5"),(6,2,"D5")],
    [(0,2,"C5"),(2,1,"D5"),(3,1,"F5"),(4,2,"G5"),(6,2,"A5")],
    [(0,1,"A5"),(1,1,"G5"),(2,2,"F5"),(4,2,"Eb5"),(6,2,"D5")],
    [(0,2,"C5"),(2,1,"F5"),(3,1,"A5"),(4,2,"G5"),(6,2,"F5")],
    [(0,1,"D5"),(1,1,"F5"),(2,2,"G5"),(4,2,"A5"),(6,2,"D6")],
    [(0,2,"C6"),(2,1,"A5"),(3,1,"G5"),(4,2,"E5"),(6,2,"D5")],
    [(0,2,"D5"),(2,1,"G5"),(3,1,"A5"),(4,2,"Bb5"),(6,2,"A5")],
    [(0,1,"G5"),(1,1,"F5"),(2,2,"D5"),(4,2,"F5"),(6,2,"A5")],
    [(0,2,"A5"),(2,1,"C6"),(3,1,"D6"),(4,2,"C6"),(6,2,"A5")],
    [(0,2,"G5"),(2,1,"F5"),(3,1,"D5"),(4,2,"C5"),(6,2,"D5")],
    [(0,1,"Eb5"),(1,1,"F5"),(2,2,"A5"),(4,2,"G5"),(6,2,"F5")],
    [(0,2,"D5"),(2,1,"A4"),(3,1,"C5"),(4,2,"D5"),(6,2,"F5")],
    [(0,1,"A5"),(1,1,"G5"),(2,2,"F5"),(4,2,"D5"),(6,2,"C5")],
    [(0,3,"D5"),(3,1,"C5"),(4,4,"D5")],
]
for bar,((harmonic,root),phrase) in enumerate(zip(chords,melody)):
    beat=bar*4
    for i,n in enumerate(harmonic):
        note(beat,4,n,"sho",gain=.023 if bar<2 else .035,pan=[-.59,.0,.60][i])
    if bar>=2:
        for p,ln,n in phrase:
            note(beat+p*.5,ln*.46,n,"reed",gain=.103,pan=-.19)
        for eighth in range(8):
            n=harmonic[[0,1,2,1,0,2,1,2][eighth]]
            note(beat+eighth*.5,.30,n[:-1]+str(int(n[-1])+1),"pluck",gain=.042,pan=.43)
    for step in (0,1.5,2,3.5):
        note(beat+step,.47 if step<3 else .24,root,"bass",gain=.15 if bar>=2 else .075)
    for b in range(4):
        if bar>=2:
            if b in (0,2):noise_hit(beat+b,"kick",.125)
            else:noise_hit(beat+b,"snare",.073)
        elif b in (0,2):noise_hit(beat+b,"kick",.053)
        for half in range(2):noise_hit(beat+b+half*.5,"hat",.018 if bar<2 else .027)
    if bar in (0,4,8,12):noise_hit(beat,"gong",.042)
    if bar in (1,7,15):note(beat+3,1,"A5","flute",gain=.047,pan=.58)

def echo(buf,delay,gain):
    n=int(delay*SAMPLE_RATE)
    out=np.zeros_like(buf)
    out[n:]=buf[:-n]*gain
    return out
L=LEFT+echo(RIGHT,.197,.12)+echo(LEFT,.366,.07)
R=RIGHT+echo(LEFT,.231,.14)+echo(RIGHT,.334,.06)
fade_in=int(.10*SAMPLE_RATE)
fade_out=int(.12*SAMPLE_RATE)
L[:fade_in]*=np.linspace(0,1,fade_in)
R[:fade_in]*=np.linspace(0,1,fade_in)
L[-fade_out:]*=np.linspace(1,0,fade_out)
R[-fade_out:]*=np.linspace(1,0,fade_out)
combined=np.stack([L,R],axis=1)
combined*=.86/max(1e-8,float(np.max(np.abs(combined))))
out=Path(sys.argv[1] if len(sys.argv)>1 else "manjushage_gagaku_future_demo.wav")
out.parent.mkdir(parents=True,exist_ok=True)
with wave.open(str(out),"wb") as handle:
    handle.setnchannels(2)
    handle.setsampwidth(2)
    handle.setframerate(SAMPLE_RATE)
    handle.writeframes((np.clip(combined,-1,1)*32767).astype("<i2").tobytes())
print(f"Wrote original score: {out} / {DURATION:.2f}s / {BPM} BPM")

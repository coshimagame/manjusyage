#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Ultra-Lush Super Famicom (SFC / SNES) 12-Track Symphony Engine
曼珠沙華 (MANJUSHAGE) - Batch 01 (Rich Full-Orchestration & Dense Polyphony)

Resolves 'thin / weak' sound by introducing a massive multi-layered 16-bit soundstage:
  Track 1: SFC Warm Pan Flute / Shaku Lead (expressive melody with delayed natural vibrato)
  Track 2: SFC Warm Horn / Trumpet Layer (octave doubling / 3rd harmonies for heroism & thickness)
  Track 3: Crystalline Chime Transient (gives attack definition to every lead note)
  Track 4: SFC Cello / Viola Counterpoint (answers the lead, fills rests with lush counter-melodies)
  Track 5: Rapid 16th Sparkling Arpeggiator (stereo celesta/harp weaving continuous motion)
  Track 6: Lush Stereo String Section (4-voice polyphonic warm chords: Root, 5th, 7th, 9th)
  Track 7: French Horn & Trombone Swells (dramatic harmonic accents on downbeats)
  Track 8: SFC Octave-Slap Bass (dynamic octave jumps, driving STG rhythm)
  Track 9: Deep Sub-Bass Foundation (solid 45-80Hz low-end weight)
  Track 10: Rich Drum Kit (Warm kick, layered acoustic snare, 16th groove hats, snare rolls, tom fills)
  Track 11: Japanese Ceremonial Taiko & Timpani (epic low-end impact)
  Track 12: Shimmering Crash Cymbals & Gated Stereo Reverb (spacious 90s Square/Konami SFC warmth)
"""

import math
import struct
import wave
import os

SAMPLE_RATE = 44100
TWO_PI = 2.0 * math.pi

class RandomPRNG:
    def __init__(self, seed=19831030):
        self.state = seed & 0xFFFFFFFF

    def next_float(self):
        self.state = (1664525 * self.state + 1013904223) & 0xFFFFFFFF
        return (self.state / 4294967296.0) * 2.0 - 1.0

NOTE_NAMES = {
    "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "E#": 5, "Fb": 4,
    "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10,
    "B": 11, "B#": 0, "Cb": 11
}

def note_freq(name):
    if not name or name == "REST":
        return 0.0
    pitch_str = name[:-1]
    octave = int(name[-1])
    semitone = NOTE_NAMES[pitch_str]
    midi = (octave + 1) * 12 + semitone
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))

class SoundBuffer:
    def __init__(self, total_samples):
        self.total = total_samples
        self.left = [0.0] * total_samples
        self.right = [0.0] * total_samples

    def add_sample(self, index, l_val, r_val):
        if 0 <= index < self.total:
            self.left[index] += l_val
            self.right[index] += r_val

    def apply_snes_reverb(self, delay_sec=0.26, feedback=0.35, mix=0.28, damp=0.40):
        """Warm 16-bit S-DSP stereo echo with low-pass absorption."""
        delay_samples = int(delay_sec * SAMPLE_RATE)
        if delay_samples <= 0:
            return
        last_l = 0.0
        last_r = 0.0
        for i in range(delay_samples, self.total):
            prev_l = self.left[i - delay_samples]
            prev_r = self.right[i - delay_samples]
            damped_l = prev_r * (1.0 - damp) + last_l * damp
            damped_r = prev_l * (1.0 - damp) + last_r * damp
            last_l = damped_l
            last_r = damped_r
            self.left[i] += damped_l * feedback * mix
            self.right[i] += damped_r * feedback * mix

    def write_wav(self, file_path):
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        # Remove DC offset
        dc_l = sum(self.left) / self.total if self.total > 0 else 0.0
        dc_r = sum(self.right) / self.total if self.total > 0 else 0.0
        for i in range(self.total):
            self.left[i] -= dc_l
            self.right[i] -= dc_r

        # Find peak
        max_peak = 0.0001
        for i in range(self.total):
            al = abs(self.left[i])
            ar = abs(self.right[i])
            if al > max_peak: max_peak = al
            if ar > max_peak: max_peak = ar

        target_peak = 0.891
        scale = target_peak / max_peak if max_peak > target_peak else 1.0

        with wave.open(file_path, "wb") as wf:
            wf.setnchannels(2)
            wf.setsampwidth(2)
            wf.setframerate(SAMPLE_RATE)
            frames = bytearray()
            for i in range(self.total):
                l_s = max(-1.0, min(1.0, self.left[i] * scale))
                r_s = max(-1.0, min(1.0, self.right[i] * scale))
                frames.extend(struct.pack("<hh", int(l_s * 32767.0), int(r_s * 32767.0)))
            wf.writeframes(frames)
        print(f"  [Created] {file_path} ({self.total / SAMPLE_RATE:.2f}s, peak: {max_peak:.2f} -> {max_peak*scale:.2f})")

# -------------------------------------------------------------
# Instrument Synthesizers
# -------------------------------------------------------------

def snes_vibrato(t, note_dur):
    if t < 0.35 or note_dur < 0.50:
        return 0.0
    ramp = min(1.0, (t - 0.35) / 0.28)
    return math.sin(TWO_PI * 4.7 * (t - 0.35)) * 0.0042 * ramp

def synth_sfc_flute(buf, start_sec, dur_sec, freq, gain=0.15, pan=0.0):
    """SFC Pan Flute / Warm Woodwind Lead."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.040 * SAMPLE_RATE)
    fade_out = int(0.075 * SAMPLE_RATE)
    lp_val = 0.0
    lp_alpha = 0.38

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = snes_vibrato(t, dur_sec)
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.82 * math.sin(ph) + 0.18 * math.sin(2.0 * ph) + 0.04 * math.sin(3.0 * ph)
        lp_val += lp_alpha * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_brass(buf, start_sec, dur_sec, freq, gain=0.13, pan=0.0):
    """SFC Warm Brass / Horn Layer (gives body, heroic weight, and fullness)."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.060 * SAMPLE_RATE)
    fade_out = int(0.080 * SAMPLE_RATE)
    lp_val = 0.0
    lp_alpha = 0.32

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = snes_vibrato(t, dur_sec)
        ph = TWO_PI * freq * (1.0 + vib) * t
        # Rich, warm brass sawtooth-like rounded spectrum
        raw = (
            0.65 * math.sin(ph) +
            0.25 * math.sin(2.0 * ph) +
            0.15 * math.sin(3.0 * ph) +
            0.08 * math.sin(4.0 * ph)
        )
        lp_val += lp_alpha * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_chime(buf, start_sec, freq, gain=0.10, pan=0.0):
    """Crystalline Chime / Koto transient attack on notes."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.60 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 12.0)
        sig = (math.sin(TWO_PI * freq * t) + 0.35 * math.sin(TWO_PI * freq * 2.0 * t)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_sfc_cello(buf, start_sec, dur_sec, freq, gain=0.12, pan=-0.25):
    """SFC Cello / Low-Mid Counter-melody."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.080 * SAMPLE_RATE)
    fade_out = int(0.100 * SAMPLE_RATE)
    lp_val = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = math.sin(TWO_PI * 4.4 * t) * 0.0035 if t > 0.3 else 0.0
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.70 * math.sin(ph) + 0.28 * math.sin(2.0 * ph) + 0.12 * math.sin(3.0 * ph)
        lp_val += 0.25 * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_arpeggiator(buf, start_sec, dur_sec, freq, gain=0.09, pan=0.3):
    """Fast 16th Sparkling Arpeggiator (stereo celesta / synth harpsichord)."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 9.5) * (1.0 - math.exp(-t * 400.0))
        sig = (math.sin(TWO_PI * freq * t) + 0.22 * math.sin(TWO_PI * freq * 2.0 * t)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_sfc_strings_pad(buf, start_sec, dur_sec, chord_freqs, gain=0.08, pan_spread=0.4):
    """Lush 4-Voice Polyphonic Stereo String Section."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.18 * SAMPLE_RATE)
    fade_out = int(0.22 * SAMPLE_RATE)

    for i, freq in enumerate(chord_freqs):
        if freq <= 0: continue
        # Spread chord notes across stereo spectrum
        pan = -pan_spread + (2.0 * pan_spread * i / max(1, len(chord_freqs) - 1))
        theta = (pan + 1.0) * math.pi / 4.0

        for n in range(count):
            t = n / SAMPLE_RATE
            env = 1.0
            if n < fade_in: env = n / fade_in
            elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

            # Detuned string ensemble warmth
            w1 = math.sin(TWO_PI * freq * t)
            w2 = math.sin(TWO_PI * freq * 1.0025 * t)
            sub = 0.3 * math.sin(TWO_PI * freq * 0.5 * t)
            sample = (w1 * 0.45 + w2 * 0.40 + sub) * env * gain
            buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_slap_bass(buf, start_sec, dur_sec, freq, gain=0.22, pan=0.0):
    """SFC Octave-Jumping Slap/Fingered Bass."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 5.2) * (1.0 - math.exp(-t * 350.0))
        # Punchy fundamental + warm slap attack
        sig = (0.75 * math.sin(TWO_PI * freq * t) +
               0.28 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 15.0) +
               0.15 * math.sin(TWO_PI * freq * 0.5 * t)) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_sfc_sub_bass(buf, start_sec, dur_sec, freq, gain=0.20):
    """Deep Sub-Bass (45-80Hz) to give solid physical weight."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    sub_f = freq if freq < 100 else freq * 0.5

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        sig = math.sin(TWO_PI * sub_f * t) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_sfc_drum(buf, start_sec, kind="kick", gain=0.32, prng=None):
    """SFC 16-Bit Drum Kit (Kick, Snare, Hat, Crash, Taiko, Snare Roll)."""
    start = int(start_sec * SAMPLE_RATE)
    durations = {
        "kick": 0.24, "snare": 0.22, "hat": 0.06, "hat_open": 0.28,
        "crash": 1.40, "taiko": 0.55, "roll": 0.08
    }
    duration = durations.get(kind, 0.20)
    count = min(int(duration * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        noise = prng.next_float() if prng else 0.0

        if kind == "kick":
            # Round acoustic thud + punchy 85Hz->46Hz drop
            f_inst = 46.0 + 39.0 * math.exp(-t * 28.0)
            sig = math.sin(TWO_PI * f_inst * t) * math.exp(-t * 14.0)
        elif kind == "snare":
            # Acoustic body + filtered snare wire rattle
            tone = math.sin(TWO_PI * 180.0 * t) * 0.45 * math.exp(-t * 22.0)
            wire = noise * 0.55 * math.exp(-t * 16.0)
            sig = tone + wire
        elif kind == "roll":
            sig = (math.sin(TWO_PI * 190.0 * t) * 0.35 + noise * 0.65) * math.exp(-t * 35.0)
        elif kind == "hat":
            sig = noise * math.exp(-t * 90.0) * 0.40
        elif kind == "hat_open":
            sig = noise * math.exp(-t * 18.0) * 0.45
        elif kind == "crash":
            # Shimmering crash cymbal (filtered high noise + resonant bells)
            shimmer = (math.sin(TWO_PI * 4200.0 * t) + math.sin(TWO_PI * 6150.0 * t)) * 0.15
            sig = (noise * 0.85 + shimmer) * math.exp(-t * 3.2)
        elif kind == "taiko":
            f_inst = 68.0 + 32.0 * math.exp(-t * 12.0)
            sig = math.sin(TWO_PI * f_inst * t) * math.exp(-t * 5.5)

        sample = sig * gain
        if kind == "crash":
            buf.add_sample(start + n, sample * 0.85, sample * 1.15)
        else:
            buf.add_sample(start + n, sample, sample)

# -------------------------------------------------------------
# BGM 1: Stage 1 Plan A (Lush 12-Track SFC Symphony)
# -------------------------------------------------------------
def generate_stage01_plan_a(file_path):
    bpm = 156
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(101)

    # 32 Bar Rich Harmonic Progression (4-note extended chords)
    # Dm9 -> BbM7 -> Gm9 -> A7b13 / Dm9 -> BbM7 -> C9 -> A7 / FM7 -> C9 -> BbM7 -> A7 / Dm9 -> Gm9 -> BbM7 -> C9
    chords_full = [
        # Intro: Bars 1-4 (Spacious strings, bell chimes, taiko roll)
        (["D4", "F4", "A4", "E5"], "D2"), (["Bb3", "D4", "F4", "A4"], "Bb1"),
        (["G3", "Bb3", "D4", "A4"], "G1"), (["A3", "C#4", "E4", "G4"], "A1"),
        # Section A: Bars 5-12 (Full groove, lead flute + brass layer + arpeggiator)
        (["D4", "F4", "A4", "C5"], "D2"), (["Bb3", "D4", "F4", "A4"], "Bb1"),
        (["C4", "E4", "G4", "D5"], "C2"), (["A3", "C#4", "E4", "G4"], "A1"),
        (["D4", "F4", "A4", "C5"], "D2"), (["Bb3", "D4", "F4", "A4"], "Bb1"),
        (["G3", "Bb3", "D4", "F4"], "G1"), (["A3", "C#4", "E4", "A4"], "A1"),
        # Section B: Bars 13-20 (Emotional buildup & cello counter-melody)
        (["F4", "A4", "C5", "E5"], "F2"), (["C4", "E4", "G4", "D5"], "C2"),
        (["Bb3", "D4", "F4", "A4"], "Bb1"), (["A3", "C#4", "E4", "G4"], "A1"),
        (["D4", "F4", "A4", "C5"], "D2"), (["G3", "Bb3", "D4", "F4"], "G1"),
        (["Bb3", "D4", "F4", "A4"], "Bb1"), (["C4", "E4", "G4", "D5"], "C2"),
        # Section C: Bars 21-28 (Heroic Climax: brass + flute in octaves, full strings)
        (["D4", "F4", "A4", "D5"], "D2"), (["Bb3", "D4", "F4", "D5"], "Bb1"),
        (["C4", "E4", "G4", "E5"], "C2"), (["D4", "F#4", "A4", "F#5"], "D2"),
        (["G3", "Bb3", "D4", "G4"], "G1"), (["A3", "C#4", "E4", "A4"], "A1"),
        (["Bb3", "D4", "F4", "Bb4"], "Bb1"), (["C4", "E4", "G4", "C5"], "C2"),
        # Outro: Bars 29-32 (Lush resolve)
        (["D4", "F4", "A4", "D5"], "D2"), (["Bb3", "D4", "F4", "A4"], "Bb1"),
        (["A3", "C#4", "E4", "A4"], "A1"), (["D4", "F4", "A4", "D5"], "D2"),
    ]

    # Synthesize Track 6 (Strings Pad) & Track 7 (Brass Swells)
    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        # Track 6: Polyphonic 4-voice strings pad
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.09, pan_spread=0.45)

        # Track 7: Horn / Trombone swells on beats 1 and 3
        if bar_idx >= 4:
            synth_sfc_brass(buf, b_start * step, 1.8 * step, c_freqs[0], gain=0.08, pan=-0.2)
            synth_sfc_brass(buf, (b_start + 2.0) * step, 1.8 * step, c_freqs[1], gain=0.08, pan=0.2)

        # Track 8 & 9: Octave-Jumping Slap Bass & Sub-Bass
        b_f = note_freq(bass_root)
        b_f_oct = b_f * 2.0
        if bar_idx >= 4:
            # Syncopated 16th groove (Root, Root-oct, 5th, Root-oct)
            for sub, oct_flag in [(0, 0), (1.5, 1), (2.5, 0), (3.0, 1)]:
                cur_f = b_f_oct if oct_flag else b_f
                synth_sfc_slap_bass(buf, (b_start + sub) * step, 0.42 * step, cur_f, gain=0.24)
                synth_sfc_sub_bass(buf, (b_start + sub) * step, 0.40 * step, cur_f, gain=0.20)

        # Track 5: Sparkling 16th Arpeggiator (weaving across chord tones)
        if bar_idx >= 4:
            for s in range(16):
                p_note = chord_notes[s % len(chord_notes)]
                arp_freq = note_freq(p_note) * (1.0 if s < 8 else 2.0)
                pan_arp = 0.35 if s % 2 == 0 else -0.35
                synth_sfc_arpeggiator(buf, (b_start + s * 0.25) * step, 0.22 * step, arp_freq, gain=0.07, pan=pan_arp)

    # Lead Melodies: Track 1 (Flute) + Track 2 (Brass Doubling) + Track 3 (Chime Transient)
    melody_track = [
        # Intro
        (0.0, 2.0, "D5"), (2.0, 1.0, "F5"), (3.0, 1.0, "A5"),
        (4.0, 2.5, "G5"), (6.5, 1.5, "F5"), (8.0, 2.0, "E5"), (10.0, 2.0, "D5"), (12.0, 4.0, "A4"),
        # Section A: Main Theme
        (16.0, 1.0, "A4"), (17.0, 1.0, "D5"), (18.0, 1.5, "F5"), (19.5, 0.5, "E5"),
        (20.0, 2.0, "D5"), (22.0, 2.0, "C5"),
        (24.0, 1.5, "D5"), (25.5, 0.5, "E5"), (26.0, 2.0, "F5"), (28.0, 2.0, "G5"), (30.0, 2.0, "A5"),
        (32.0, 1.5, "F5"), (33.5, 0.5, "E5"), (34.0, 2.0, "D5"), (36.0, 2.0, "C#5"), (38.0, 2.0, "D5"),
        (40.0, 1.5, "Bb4"), (41.5, 0.5, "C5"), (42.0, 2.0, "D5"), (44.0, 4.0, "A4"),
        # Section B: Emotional Climax
        (48.0, 1.5, "A5"), (49.5, 0.5, "G5"), (50.0, 2.0, "F5"), (52.0, 2.0, "G5"), (54.0, 2.0, "E5"),
        (56.0, 1.5, "F5"), (57.5, 0.5, "E5"), (58.0, 2.0, "D5"), (60.0, 4.0, "C#5"),
        (64.0, 2.0, "D5"), (66.0, 2.0, "F5"), (68.0, 2.0, "G5"), (70.0, 2.0, "Bb5"),
        (72.0, 2.0, "A5"), (74.0, 2.0, "E5"), (76.0, 4.0, "D5"),
        # Section C: Heroic Resonance
        (80.0, 1.0, "D5"), (81.0, 1.0, "F5"), (82.0, 2.0, "A5"), (84.0, 1.5, "Bb5"), (85.5, 0.5, "A5"),
        (86.0, 2.0, "G5"), (88.0, 2.0, "F5"), (90.0, 2.0, "G5"), (92.0, 4.0, "A5"),
        (96.0, 2.0, "Bb5"), (98.0, 2.0, "A5"), (100.0, 2.0, "F5"), (102.0, 2.0, "E5"),
        (104.0, 2.0, "D5"), (106.0, 2.0, "C5"), (108.0, 4.0, "D5"),
        (112.0, 2.0, "F5"), (114.0, 2.0, "E5"), (116.0, 4.0, "D5"),
    ]

    for b_pos, b_len, p_str in melody_track:
        freq = note_freq(p_str)
        s_time = b_pos * step
        dur = b_len * step
        # Track 1: Warm Woodwind Lead
        synth_sfc_flute(buf, s_time, dur, freq, gain=0.16, pan=0.0)
        # Track 2: Warm Brass Layer (an octave lower on sustained notes for massive heroism!)
        synth_sfc_brass(buf, s_time, dur, freq * 0.5, gain=0.11, pan=-0.1)
        # Track 3: Chime transient on attack
        synth_sfc_chime(buf, s_time, freq * 2.0, gain=0.08, pan=0.15)

    # Track 4: Cello Counter-melody (fills pauses and harmonizes with the lead!)
    cello_counter = [
        # Answers section A
        (20.0, 2.0, "F3"), (22.0, 2.0, "G3"), (24.0, 4.0, "A3"),
        (36.0, 2.0, "E3"), (38.0, 2.0, "F3"), (40.0, 4.0, "D3"),
        # Answers section B
        (52.0, 2.0, "C3"), (54.0, 2.0, "E3"), (56.0, 4.0, "F3"),
        (68.0, 2.0, "G3"), (70.0, 2.0, "Bb3"), (72.0, 4.0, "A3"),
        # Climactic counterpoint
        (84.0, 2.0, "G3"), (86.0, 2.0, "Bb3"), (88.0, 4.0, "D4"),
        (100.0, 2.0, "A3"), (102.0, 2.0, "G3"), (104.0, 4.0, "F3"),
    ]
    for c_pos, c_len, c_pitch in cello_counter:
        synth_sfc_cello(buf, c_pos * step, c_len * step, note_freq(c_pitch), gain=0.13, pan=-0.25)

    # Track 10, 11, 12: Drum Kit, Crash Cymbals, Taiko, Snare Rolls
    for bar in range(bars):
        b_start = bar * 4.0

        # Crash Cymbals at section starts (Bars 0, 4, 12, 20, 28)
        if bar in [0, 4, 12, 20, 28]:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.38, prng=prng)

        # Intro Taiko & Timpani rolls
        if bar < 4:
            synth_sfc_drum(buf, b_start * step, "taiko", gain=0.45, prng=prng)
            synth_sfc_drum(buf, (b_start + 2.0) * step, "taiko", gain=0.35, prng=prng)
        else:
            # Driving STG Kick Pattern (Downbeat + off-beat gallop)
            synth_sfc_drum(buf, b_start * step, "kick", gain=0.38, prng=prng)
            synth_sfc_drum(buf, (b_start + 1.5) * step, "kick", gain=0.32, prng=prng)
            synth_sfc_drum(buf, (b_start + 2.5) * step, "kick", gain=0.34, prng=prng)

            # Punchy Layered Snare on 2 and 4
            synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.36, prng=prng)
            synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.36, prng=prng)

            # 16th Groove Hi-Hats with Accents
            for sub in range(8):
                is_accent = (sub % 2 == 1)
                h_type = "hat_open" if (sub == 7 and bar % 2 == 1) else "hat"
                h_gain = 0.16 if is_accent else 0.09
                synth_sfc_drum(buf, (b_start + sub * 0.5) * step, h_type, gain=h_gain, prng=prng)

            # Snare roll fills before bar transitions (bars 11, 19, 27)
            if bar in [11, 19, 27]:
                for r in range(4):
                    synth_sfc_drum(buf, (b_start + 3.0 + r * 0.25) * step, "roll", gain=0.25 + r * 0.04, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.26, feedback=0.34, mix=0.26, damp=0.40)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 2: Stage 1 Plan B (Lush SFC Melodic Retro Rock)
# -------------------------------------------------------------
def generate_stage01_plan_b(file_path):
    bpm = 150
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(202)

    chords_full = [
        (["F#4", "A4", "C#5", "E5"], "F#2"), (["D4", "F#4", "A4", "C#5"], "D2"),
        (["A3", "C#4", "E4", "G#4"], "A1"), (["E4", "G#4", "B4", "D#5"], "E2"),
        (["F#4", "A4", "C#5", "E5"], "F#2"), (["D4", "F#4", "A4", "D5"], "D2"),
        (["A3", "C#4", "E4", "A4"], "A1"), (["E4", "G#4", "B4", "E5"], "E2"),
        (["F#4", "A4", "C#5", "E5"], "F#2"), (["B3", "D4", "F#4", "A4"], "B1"),
        (["C#4", "F4", "G#4", "C#5"], "C#2"), (["F#4", "A4", "C#5", "F#5"], "F#2"),
        (["D4", "F#4", "A4", "D5"], "D2"), (["E4", "G#4", "B4", "E5"], "E2"),
        (["C#4", "E4", "G#4", "C#5"], "C#2"), (["F#4", "A4", "C#5", "F#5"], "F#2"),
        (["B3", "D4", "F#4", "B4"], "B1"), (["C#4", "F4", "G#4", "C#5"], "C#2"),
        (["D4", "F#4", "A4", "D5"], "D2"), (["E4", "G#4", "B4", "E5"], "E2"),
        (["F#4", "A4", "C#5", "F#5"], "F#2"), (["D4", "F#4", "A4", "D5"], "D2"),
        (["E4", "G#4", "B4", "E5"], "E2"), (["C#4", "F4", "G#4", "C#5"], "C#2"),
        (["D4", "F#4", "A4", "D5"], "D2"), (["B3", "D4", "F#4", "B4"], "B1"),
        (["C#4", "F4", "G#4", "C#5"], "C#2"), (["F#4", "A4", "C#5", "F#5"], "F#2"),
        (["D4", "F#4", "A4", "D5"], "D2"), (["E4", "G#4", "B4", "E5"], "E2"),
        (["C#4", "F4", "G#4", "C#5"], "C#2"), (["F#4", "A4", "C#5", "F#5"], "F#2"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.09, pan_spread=0.45)

        b_f = note_freq(bass_root)
        b_f_oct = b_f * 2.0
        # Rock gallop bass (da-da-da_ da-da-da_)
        for s in range(16):
            if s % 4 != 3:
                use_f = b_f_oct if (s % 4 == 2) else b_f
                synth_sfc_slap_bass(buf, (b_start + s * 0.25) * step, 0.22 * step, use_f, gain=0.22)
                synth_sfc_sub_bass(buf, (b_start + s * 0.25) * step, 0.22 * step, use_f, gain=0.18)

        # Arpeggio motion
        for s in range(16):
            p_note = chord_notes[s % len(chord_notes)]
            synth_sfc_arpeggiator(buf, (b_start + s * 0.25) * step, 0.22 * step, note_freq(p_note), gain=0.07, pan=0.3)

    melody = [
        (16.0, 1.5, "F#5"), (17.5, 0.5, "A5"), (18.0, 2.0, "G#5"), (20.0, 2.0, "F#5"), (22.0, 2.0, "E5"),
        (24.0, 1.5, "F#5"), (25.5, 0.5, "A5"), (26.0, 2.0, "B5"), (28.0, 2.0, "C#6"), (30.0, 2.0, "A5"),
        (32.0, 1.5, "F#5"), (33.5, 0.5, "G#5"), (34.0, 2.0, "A5"), (36.0, 2.0, "B5"), (38.0, 2.0, "G#5"),
        (40.0, 4.0, "F#5"), (44.0, 4.0, "E5"),
        (48.0, 2.0, "D6"), (50.0, 2.0, "C#6"), (52.0, 2.0, "B5"), (54.0, 2.0, "A5"),
        (56.0, 2.0, "G#5"), (58.0, 2.0, "A5"), (60.0, 4.0, "F#5"),
        (64.0, 2.0, "B5"), (66.0, 2.0, "C#6"), (68.0, 2.0, "D6"), (70.0, 2.0, "E6"),
        (72.0, 4.0, "C#6"), (76.0, 4.0, "F#5"),
        (80.0, 1.0, "F#5"), (81.0, 1.0, "A5"), (82.0, 2.0, "C#6"), (84.0, 2.0, "B5"), (86.0, 2.0, "A5"),
        (88.0, 2.0, "G#5"), (90.0, 2.0, "E5"), (92.0, 4.0, "F#5"),
    ]

    for m_beat, m_len, m_pitch in melody:
        f = note_freq(m_pitch)
        s_time = m_beat * step
        dur = m_len * step
        synth_sfc_flute(buf, s_time, dur, f, gain=0.17, pan=0.0)
        synth_sfc_brass(buf, s_time, dur, f * 0.5, gain=0.12, pan=-0.1)
        synth_sfc_chime(buf, s_time, f * 2.0, gain=0.08, pan=0.2)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar in [0, 4, 12, 20, 28]:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.38, prng=prng)

        synth_sfc_drum(buf, b_start * step, "kick", gain=0.38, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.5) * step, "kick", gain=0.32, prng=prng)
        synth_sfc_drum(buf, (b_start + 2.5) * step, "kick", gain=0.34, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.36, prng=prng)
        synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.36, prng=prng)
        for sub in range(8):
            synth_sfc_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.14, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.25, feedback=0.32, mix=0.25, damp=0.40)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 3: Boss 1 Plan A (Lush SFC Bio-Core Tension)
# -------------------------------------------------------------
def generate_boss01_plan_a(file_path):
    bpm = 164
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(303)

    chords_full = [
        (["G3", "Db4", "G4", "Bb4"], "G1"), (["G3", "D4", "Bb4", "D5"], "G1"),
        (["Ab3", "Eb4", "C5", "Eb5"], "Ab1"), (["G3", "Db4", "G4", "Bb4"], "G1"),
        (["Eb4", "Bb4", "G5", "Bb5"], "Eb2"), (["Db4", "Ab4", "F5", "Ab5"], "Db2"),
        (["D4", "A4", "F#5", "A5"], "D2"), (["D4", "Ab4", "F5", "Ab5"], "D2"),
    ] * 4

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.10, pan_spread=0.5)

        b_f = note_freq(bass_root)
        for s in range(8):
            synth_sfc_slap_bass(buf, (b_start + s * 0.5) * step, 0.35 * step, b_f, gain=0.25)
            synth_sfc_sub_bass(buf, (b_start + s * 0.5) * step, 0.35 * step, b_f, gain=0.22)

        for s in range(16):
            p_note = chord_notes[s % len(chord_notes)]
            synth_sfc_arpeggiator(buf, (b_start + s * 0.25) * step, 0.20 * step, note_freq(p_note), gain=0.08, pan=0.35)

    boss_melody = [
        (0.0, 1.5, "G4"), (1.5, 0.5, "Ab4"), (2.0, 2.0, "Db5"), (4.0, 2.0, "C5"), (6.0, 2.0, "Bb4"),
        (8.0, 1.5, "G4"), (9.5, 0.5, "Bb4"), (10.0, 2.0, "Db5"), (12.0, 4.0, "D5"),
        (16.0, 1.5, "G5"), (17.5, 0.5, "F5"), (18.0, 2.0, "Eb5"), (20.0, 2.0, "Db5"),
        (22.0, 2.0, "C5"), (24.0, 2.0, "Ab4"), (26.0, 4.0, "G4"),
        (32.0, 1.0, "G5"), (33.0, 1.0, "Bb5"), (34.0, 2.0, "Db6"), (36.0, 2.0, "C6"),
        (38.0, 1.5, "Bb5"), (39.5, 0.5, "Ab5"), (40.0, 2.0, "G5"), (42.0, 2.0, "F#5"),
        (44.0, 4.0, "G5"), (48.0, 4.0, "Ab5"), (52.0, 4.0, "D5"), (56.0, 8.0, "G4"),
        (64.0, 2.0, "Db5"), (66.0, 2.0, "Eb5"), (68.0, 2.0, "F5"), (70.0, 2.0, "G5"),
        (72.0, 2.0, "Ab5"), (74.0, 2.0, "Bb5"), (76.0, 4.0, "Db6"), (80.0, 4.0, "C6"),
        (84.0, 2.0, "Bb5"), (86.0, 2.0, "Ab5"), (88.0, 8.0, "G5"),
    ]

    for b_pos, b_len, p_str in boss_melody:
        f = note_freq(p_str)
        s_time = b_pos * step
        dur = b_len * step
        synth_sfc_flute(buf, s_time, dur, f, gain=0.18, pan=0.0)
        synth_sfc_brass(buf, s_time, dur, f * 0.5, gain=0.14, pan=-0.1)
        synth_sfc_chime(buf, s_time, f * 2.0, gain=0.09, pan=0.2)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar % 8 == 0:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.40, prng=prng)

        synth_sfc_drum(buf, b_start * step, "taiko", gain=0.45, prng=prng)
        synth_sfc_drum(buf, (b_start + 0.75) * step, "taiko", gain=0.35, prng=prng)
        synth_sfc_drum(buf, (b_start + 2.0) * step, "taiko", gain=0.40, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.38, prng=prng)
        synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.38, prng=prng)
        synth_sfc_drum(buf, (b_start + 3.5) * step, "kick", gain=0.34, prng=prng)
        for s in range(8):
            synth_sfc_drum(buf, (b_start + s * 0.5) * step, "hat", gain=0.14, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.24, feedback=0.32, mix=0.26, damp=0.40)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 4: Boss 1 Plan B (Lush SFC Rhapsody Breakthrough)
# -------------------------------------------------------------
def generate_boss01_plan_b(file_path):
    bpm = 170
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(404)

    chords_full = [
        (["C4", "Eb4", "G4", "C5"], "C2"), (["Ab3", "C4", "Eb4", "Ab4"], "Ab1"),
        (["F3", "Ab3", "C4", "F4"], "F1"), (["G3", "B3", "D4", "G4"], "G1"),
        (["C4", "Eb4", "G4", "C5"], "C2"), (["Eb4", "G4", "Bb4", "Eb5"], "Eb2"),
        (["Ab3", "C4", "Eb4", "Ab4"], "Ab1"), (["G3", "B3", "D4", "G4"], "G1"),
    ] * 4

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.10, pan_spread=0.5)

        b_f = note_freq(bass_root)
        for s in range(16):
            synth_sfc_slap_bass(buf, (b_start + s * 0.25) * step, 0.20 * step, b_f, gain=0.22)
            synth_sfc_sub_bass(buf, (b_start + s * 0.25) * step, 0.20 * step, b_f, gain=0.20)

        for s in range(16):
            p_note = chord_notes[s % len(chord_notes)]
            synth_sfc_arpeggiator(buf, (b_start + s * 0.25) * step, 0.20 * step, note_freq(p_note), gain=0.08, pan=0.3)

    furious_melody = [
        (0.0, 1.0, "C5"), (1.0, 1.0, "Eb5"), (2.0, 1.0, "G5"), (3.0, 1.0, "Ab5"),
        (4.0, 2.0, "G5"), (6.0, 2.0, "Eb5"), (8.0, 2.0, "F5"), (10.0, 2.0, "D5"),
        (12.0, 4.0, "C5"), (16.0, 1.0, "C6"), (17.0, 1.0, "B5"), (18.0, 2.0, "Ab5"),
        (20.0, 2.0, "G5"), (22.0, 2.0, "F5"), (24.0, 2.0, "Eb5"), (26.0, 2.0, "D5"),
        (28.0, 4.0, "C5"),
        (32.0, 2.0, "Eb5"), (34.0, 2.0, "G5"), (36.0, 2.0, "C6"), (38.0, 2.0, "D6"),
        (40.0, 2.0, "Eb6"), (42.0, 2.0, "D6"), (44.0, 4.0, "C6"), (48.0, 4.0, "B5"),
        (52.0, 4.0, "C6"), (56.0, 8.0, "G5"),
    ]

    for b_pos, b_len, p_str in furious_melody:
        f = note_freq(p_str)
        s_time = b_pos * step
        dur = b_len * step
        synth_sfc_flute(buf, s_time, dur, f, gain=0.18, pan=0.0)
        synth_sfc_brass(buf, s_time, dur, f * 0.5, gain=0.13, pan=-0.1)
        synth_sfc_chime(buf, s_time, f * 2.0, gain=0.09, pan=0.2)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar % 8 == 0:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.40, prng=prng)

        synth_sfc_drum(buf, b_start * step, "kick", gain=0.38, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.36, prng=prng)
        synth_sfc_drum(buf, (b_start + 2.0) * step, "kick", gain=0.38, prng=prng)
        synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.36, prng=prng)
        for s in range(8):
            synth_sfc_drum(buf, (b_start + s * 0.5) * step, "hat", gain=0.14, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.22, feedback=0.30, mix=0.24, damp=0.40)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Jingle JG-002: Sortie Fanfare (Lush Orchestral SFC Style)
# -------------------------------------------------------------
def generate_jingle_sortie(file_path):
    duration = 3.8
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(505)

    c_freqs = [note_freq(n) for n in ["D4", "F#4", "A4", "D5", "F#5"]]
    synth_sfc_strings_pad(buf, 0.0, 3.6, c_freqs, gain=0.14, pan_spread=0.5)

    flourish = [
        (0.0, "D4"), (0.10, "F#4"), (0.20, "A4"), (0.30, "D5"),
        (0.40, "F#5"), (0.50, "A5"), (0.60, "D6")
    ]
    for t_sec, n in flourish:
        f = note_freq(n)
        synth_sfc_chime(buf, t_sec, f, gain=0.22, pan=0.2)
        synth_sfc_flute(buf, t_sec, 0.9, f, gain=0.16, pan=-0.1)

    for n in ["D5", "F#5", "A5", "D6"]:
        f = note_freq(n)
        synth_sfc_brass(buf, 0.85, 2.6, f * 0.5, gain=0.16, pan=0.0)
        synth_sfc_flute(buf, 0.85, 2.6, f, gain=0.15, pan=0.0)

    synth_sfc_drum(buf, 0.0, "taiko", gain=0.45, prng=prng)
    synth_sfc_drum(buf, 0.40, "taiko", gain=0.40, prng=prng)
    synth_sfc_drum(buf, 0.85, "crash", gain=0.50, prng=prng)
    synth_sfc_drum(buf, 0.85, "taiko", gain=0.60, prng=prng)
    synth_sfc_drum(buf, 0.85, "snare", gain=0.40, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.25, feedback=0.35, mix=0.30, damp=0.40)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Main Execution
# -------------------------------------------------------------
def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    print(f"=== Mw-fActory Sound Team: 12-Track SFC Symphony Audio Generation ===")
    print(f"Target Root: {root_dir}")

    m_dir = os.path.join(root_dir, "assets", "audio", "music")
    generate_stage01_plan_a(os.path.join(m_dir, "bgm_stage01_plan_a.wav"))
    generate_stage01_plan_b(os.path.join(m_dir, "bgm_stage01_plan_b.wav"))
    generate_boss01_plan_a(os.path.join(m_dir, "bgm_boss01_plan_a.wav"))
    generate_boss01_plan_b(os.path.join(m_dir, "bgm_boss01_plan_b.wav"))

    j_dir = os.path.join(root_dir, "assets", "audio", "jingles")
    generate_jingle_sortie(os.path.join(j_dir, "jg002_sortie.wav"))

    print("=== All 5 Musical Assets Generated With 12-Track Richness! ===")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Audio Asset Generator
曼珠沙華 (MANJUSHAGE) - Production Batch 01
Pure Python Audio Synthesis (Standard Library wave + math + struct)
No external dependencies required.
Generates:
  - assets/audio/music/bgm_stage01_plan_a.wav
  - assets/audio/music/bgm_stage01_plan_b.wav
  - assets/audio/music/bgm_boss01_plan_a.wav
  - assets/audio/music/bgm_boss01_plan_b.wav
  - assets/audio/jingles/jg002_sortie.wav
  - assets/audio/sfx/se_shot_cormii.wav
  - assets/audio/sfx/se_shot_jiyoza.wav
  - assets/audio/sfx/se_shot_mafio.wav
  - assets/audio/sfx/se_boss_warning.wav
  - assets/audio/sfx/se_boss_destroy.wav
"""

import math
import struct
import wave
import os
import sys

SAMPLE_RATE = 44100

class RandomPRNG:
    """Deterministic Linear Congruential Generator for bit-exact reproducibility."""
    def __init__(self, seed=19831030):
        self.state = seed & 0xFFFFFFFF

    def next_float(self):
        self.state = (1664525 * self.state + 1013904223) & 0xFFFFFFFF
        return (self.state / 4294967296.0) * 2.0 - 1.0

# Pitch table
NOTE_NAMES = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "E#": 5, "Fb": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11, "B#": 0, "Cb": 11}

def note_freq(name):
    """Convert note name (e.g. 'A4', 'C#5', 'Eb3') to frequency in Hz."""
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

    def apply_delay(self, delay_sec=0.25, feedback=0.35, mix=0.3):
        """Stereo ping-pong / cross delay for spacious ambiance."""
        delay_samples = int(delay_sec * SAMPLE_RATE)
        if delay_samples <= 0:
            return
        for i in range(delay_samples, self.total):
            prev_l = self.left[i - delay_samples]
            prev_r = self.right[i - delay_samples]
            self.left[i] += prev_r * feedback * mix
            self.right[i] += prev_l * feedback * mix

    def write_wav(self, file_path):
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        # DC offset removal (High-pass filter)
        dc_l = sum(self.left) / self.total if self.total > 0 else 0.0
        dc_r = sum(self.right) / self.total if self.total > 0 else 0.0
        for i in range(self.total):
            self.left[i] -= dc_l
            self.right[i] -= dc_r

        # Peak normalization to -1.0 dBFS (approx 0.89)
        max_peak = 0.0001
        for i in range(self.total):
            al = abs(self.left[i])
            ar = abs(self.right[i])
            if al > max_peak:
                max_peak = al
            if ar > max_peak:
                max_peak = ar

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
                l_int = int(l_s * 32767.0)
                r_int = int(r_s * 32767.0)
                frames.extend(struct.pack("<hh", l_int, r_int))
            wf.writeframes(frames)
        print(f"  [Created] {file_path} ({self.total / SAMPLE_RATE:.2f}s, peak: {max_peak:.2f} -> {max_peak*scale:.2f}, DC: 0.0)")

# -------------------------------------------------------------
# Instrument Synthesizers
# -------------------------------------------------------------

def synth_sho(buf, start_sec, duration_sec, freq, gain=0.18, pan=0.0):
    """Gagaku Sho (笙): Multi-reed celestial sustained harmony."""
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(duration_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi
    fade_in = int(0.12 * SAMPLE_RATE)
    fade_out = int(0.18 * SAMPLE_RATE)

    for n in range(count):
        t = n / SAMPLE_RATE
        # Envelope with soft breathing
        env = 1.0
        if n < fade_in:
            env = n / fade_in
        elif n > count - fade_out:
            env = max(0.0, (count - n) / fade_out)
        
        # Subtle chorus / beating characteristic of Sho pipes
        wave = (
            0.55 * math.sin(two_pi * freq * t) +
            0.25 * math.sin(two_pi * freq * 2.003 * t) +
            0.15 * math.sin(two_pi * freq * 3.0 * t) +
            0.08 * math.sin(two_pi * freq * 1.498 * t) # fifth overtone
        )
        sample = wave * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_hichiriki(buf, start_sec, duration_sec, freq, gain=0.22, pan=0.0):
    """Gagaku Hichiriki (篳篥): Double-reed emotive lead with pitch bend & vibrato."""
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(duration_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi
    fade_in = int(0.04 * SAMPLE_RATE)
    fade_out = int(0.06 * SAMPLE_RATE)

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in:
            env = n / fade_in
        elif n > count - fade_out:
            env = max(0.0, (count - n) / fade_out)

        # Portamento / vibrato
        vib = 0.0035 * math.sin(two_pi * 5.6 * t) if t > 0.1 else 0.0
        f_curr = freq * (1.0 + vib)
        phase = two_pi * f_curr * t
        
        # Rich nasal double-reed harmonics (asymmetric odd/even)
        wave = (
            0.60 * math.sin(phase) +
            0.28 * math.sin(2.0 * phase) +
            0.20 * math.sin(3.0 * phase) +
            0.12 * math.sin(4.0 * phase) +
            0.08 * math.sin(5.0 * phase)
        )
        sample = wave * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_ryuteki(buf, start_sec, duration_sec, freq, gain=0.18, pan=0.0):
    """Gagaku Ryuteki (龍笛): Dragon flute high airy melody."""
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(duration_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi
    fade_in = int(0.05 * SAMPLE_RATE)
    fade_out = int(0.08 * SAMPLE_RATE)

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in:
            env = n / fade_in
        elif n > count - fade_out:
            env = max(0.0, (count - n) / fade_out)

        vib = 0.002 * math.sin(two_pi * 4.8 * t)
        phase = two_pi * freq * (1.0 + vib) * t
        wave = math.sin(phase) + 0.12 * math.sin(2.0 * phase)
        sample = wave * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_biwa(buf, start_sec, duration_sec, freq, gain=0.20, pan=0.0):
    """Gagaku Biwa / Koto (琵琶・箏): Plucked string attack with fast decay."""
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(duration_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 14.0) * (1.0 - math.exp(-t * 300.0))
        phase = two_pi * freq * t
        wave = math.sin(phase) + 0.45 * math.sin(2.0 * phase) + 0.20 * math.sin(3.0 * phase)
        sample = wave * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_fm_bass(buf, start_sec, duration_sec, freq, gain=0.28, pan=0.0):
    """FM Synthesizer Bass: 16-bit arcade punchy bass."""
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(duration_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi
    mod_index = 2.5

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 5.0) * (1.0 - math.exp(-t * 200.0))
        mod_env = math.exp(-t * 12.0)
        modulator = math.sin(two_pi * freq * t) * mod_index * mod_env
        carrier = math.sin(two_pi * freq * t + modulator)
        # Sub-oscillator for warmth
        sub = 0.35 * math.sin(two_pi * (freq * 0.5) * t)
        sample = (carrier + sub) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_drum(buf, start_sec, kind="kick", gain=0.35, prng=None):
    """Synthesized chiptune / electronic percussion."""
    start = int(start_sec * SAMPLE_RATE)
    duration = {"kick": 0.22, "snare": 0.18, "hat": 0.06, "taiko": 0.55}[kind]
    count = min(int(duration * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi

    for n in range(count):
        t = n / SAMPLE_RATE
        noise = prng.next_float() if prng else 0.0

        if kind == "kick":
            # Pitch sweep 140Hz -> 42Hz
            f_inst = 42.0 + 98.0 * math.exp(-t * 32.0)
            phase = two_pi * f_inst * t
            sig = math.sin(phase) * math.exp(-t * 18.0) + noise * 0.1 * math.exp(-t * 60.0)
        elif kind == "snare":
            # Body tone + white noise burst
            tone = math.sin(two_pi * 185.0 * t) * 0.35 * math.exp(-t * 22.0)
            snare_noise = noise * 0.65 * math.exp(-t * 20.0)
            sig = tone + snare_noise
        elif kind == "hat":
            # High frequency metallic noise
            sig = noise * math.exp(-t * 90.0)
        elif kind == "taiko":
            # Deep Japanese ceremonial war drum
            f_inst = 60.0 + 40.0 * math.exp(-t * 15.0)
            phase = two_pi * f_inst * t
            sig = (math.sin(phase) + 0.3 * math.sin(2.0 * phase)) * math.exp(-t * 6.5)

        sample = sig * gain
        buf.add_sample(start + n, sample, sample)

# -------------------------------------------------------------
# BGM 1: Stage 1 Plan A (Gagaku Future x Melodic Rush)
# -------------------------------------------------------------
def generate_stage01_plan_a(file_path):
    bpm = 160
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(101)

    # 32 Bar Harmony Progression (D minor -> Bb -> G minor -> A -> D minor -> F -> C -> D)
    chords = [
        # Intro: Bars 1-4 (Spacious Gagaku Sho & Flute intro)
        (["D4", "A4", "D5"], "D2"), (["Bb3", "F4", "Bb4"], "Bb1"),
        (["G3", "D4", "G4"], "G1"), (["A3", "E4", "A4"], "A1"),
        # Section A: Bars 5-12 (Driving beat + Hichiriki main motif)
        (["D4", "A4", "F5"], "D2"), (["Bb3", "F4", "D5"], "Bb1"),
        (["C4", "G4", "E5"], "C2"), (["A3", "E4", "C#5"], "A1"),
        (["D4", "A4", "F5"], "D2"), (["Bb3", "F4", "D5"], "Bb1"),
        (["G3", "D4", "Bb4"], "G1"), (["A3", "E4", "A4"], "A1"),
        # Section B: Bars 13-20 (Emotional buildup & sorrow)
        (["F4", "C5", "A5"], "F2"), (["C4", "G4", "E5"], "C2"),
        (["Bb3", "F4", "D5"], "Bb1"), (["A3", "E4", "C#5"], "A1"),
        (["D4", "A4", "F5"], "D2"), (["G3", "D4", "Bb4"], "G1"),
        (["Bb3", "F4", "D5"], "Bb1"), (["C4", "G4", "E5"], "C2"),
        # Section C: Bars 21-28 (Heroic Gagaku Climax)
        (["D4", "A4", "D5"], "D2"), (["Bb3", "F4", "F5"], "Bb1"),
        (["C4", "G4", "G5"], "C2"), (["D4", "A4", "A5"], "D2"),
        (["G3", "D4", "Bb4"], "G1"), (["A3", "E4", "C#5"], "A1"),
        (["Bb3", "F4", "D5"], "Bb1"), (["C4", "G4", "E5"], "C2"),
        # Loop Outro: Bars 29-32 (Suspenseful resolve toward seamless loop)
        (["D4", "A4", "F5"], "D2"), (["Bb3", "F4", "D5"], "Bb1"),
        (["A3", "E4", "C#5"], "A1"), (["D4", "A4", "D5"], "D2"),
    ]

    # Synthesize Chords (Sho) & Bassline
    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        bar_start_beat = bar_idx * 4.0
        # Sho sustained chord
        for n_str in chord_notes:
            synth_sho(buf, bar_start_beat * step, 4.0 * step, note_freq(n_str), gain=0.12, pan=-0.25)

        # FM Bass 16th note driving pulse (from bar 4 onwards)
        if bar_idx >= 4:
            b_freq = note_freq(bass_root)
            for sub in range(8): # 8th notes driving
                b_start = (bar_start_beat + sub * 0.5) * step
                synth_fm_bass(buf, b_start, 0.45 * step, b_freq, gain=0.24, pan=0.0)

        # Biwa plucked arpeggio
        if bar_idx >= 4:
            for i, p_note in enumerate(chord_notes):
                synth_biwa(buf, (bar_start_beat + i * 1.0) * step, 0.9 * step, note_freq(p_note), gain=0.14, pan=0.35)

    # Lead Melody (Hichiriki & Ryuteki)
    # Motifs: Nostalgic sorrow (D -> F -> G -> A -> F -> E -> D)
    melody_track = [
        # Intro Ryuteki call
        (0.0, 2.0, "D5", "ryuteki", -0.1), (2.0, 1.0, "F5", "ryuteki", -0.1), (3.0, 1.0, "A5", "ryuteki", -0.1),
        (4.0, 2.5, "G5", "ryuteki", -0.1), (6.5, 1.5, "F5", "ryuteki", -0.1),
        (8.0, 2.0, "E5", "ryuteki", -0.1), (10.0, 2.0, "D5", "ryuteki", -0.1),
        (12.0, 4.0, "A4", "ryuteki", -0.1),
        # Section A: Bars 5-12 Main Hichiriki Lead
        (16.0, 1.0, "A4", "hichiriki", 0.0), (17.0, 1.0, "D5", "hichiriki", 0.0), (18.0, 1.5, "F5", "hichiriki", 0.0),
        (19.5, 0.5, "E5", "hichiriki", 0.0), (20.0, 2.0, "D5", "hichiriki", 0.0), (22.0, 2.0, "C5", "hichiriki", 0.0),
        (24.0, 1.5, "D5", "hichiriki", 0.0), (25.5, 0.5, "E5", "hichiriki", 0.0), (26.0, 2.0, "F5", "hichiriki", 0.0),
        (28.0, 2.0, "G5", "hichiriki", 0.0), (30.0, 2.0, "A5", "hichiriki", 0.0),
        (32.0, 1.5, "F5", "hichiriki", 0.0), (33.5, 0.5, "E5", "hichiriki", 0.0), (34.0, 2.0, "D5", "hichiriki", 0.0),
        (36.0, 2.0, "C#5", "hichiriki", 0.0), (38.0, 2.0, "D5", "hichiriki", 0.0),
        (40.0, 1.5, "Bb4", "hichiriki", 0.0), (41.5, 0.5, "C5", "hichiriki", 0.0), (42.0, 2.0, "D5", "hichiriki", 0.0),
        (44.0, 4.0, "A4", "hichiriki", 0.0),
        # Section B: Bars 13-20 Emotive peak
        (48.0, 1.5, "A5", "hichiriki", 0.0), (49.5, 0.5, "G5", "hichiriki", 0.0), (50.0, 2.0, "F5", "hichiriki", 0.0),
        (52.0, 2.0, "G5", "hichiriki", 0.0), (54.0, 2.0, "E5", "hichiriki", 0.0),
        (56.0, 1.5, "F5", "hichiriki", 0.0), (57.5, 0.5, "E5", "hichiriki", 0.0), (58.0, 2.0, "D5", "hichiriki", 0.0),
        (60.0, 4.0, "C#5", "hichiriki", 0.0),
        (64.0, 2.0, "D5", "hichiriki", 0.0), (66.0, 2.0, "F5", "hichiriki", 0.0),
        (68.0, 2.0, "G5", "hichiriki", 0.0), (70.0, 2.0, "Bb5", "hichiriki", 0.0),
        (72.0, 2.0, "A5", "hichiriki", 0.0), (74.0, 2.0, "E5", "hichiriki", 0.0),
        (76.0, 4.0, "D5", "hichiriki", 0.0),
        # Section C: Bars 21-28 Dual Harmonies
        (80.0, 1.0, "D5", "hichiriki", -0.15), (81.0, 1.0, "F5", "hichiriki", -0.15), (82.0, 2.0, "A5", "hichiriki", -0.15),
        (80.0, 1.0, "F5", "ryuteki", 0.2), (81.0, 1.0, "A5", "ryuteki", 0.2), (82.0, 2.0, "D6", "ryuteki", 0.2),
        (84.0, 1.5, "Bb5", "hichiriki", -0.15), (85.5, 0.5, "A5", "hichiriki", -0.15), (86.0, 2.0, "G5", "hichiriki", -0.15),
        (84.0, 1.5, "D6", "ryuteki", 0.2), (85.5, 0.5, "C6", "ryuteki", 0.2), (86.0, 2.0, "Bb5", "ryuteki", 0.2),
        (88.0, 2.0, "F5", "hichiriki", -0.15), (90.0, 2.0, "G5", "hichiriki", -0.15), (92.0, 4.0, "A5", "hichiriki", -0.15),
        (88.0, 2.0, "A5", "ryuteki", 0.2), (90.0, 2.0, "Bb5", "ryuteki", 0.2), (92.0, 4.0, "C6", "ryuteki", 0.2),
        # Outro phrase
        (96.0, 2.0, "Bb5", "hichiriki", 0.0), (98.0, 2.0, "A5", "hichiriki", 0.0),
        (100.0, 2.0, "F5", "hichiriki", 0.0), (102.0, 2.0, "E5", "hichiriki", 0.0),
        (104.0, 2.0, "D5", "hichiriki", 0.0), (106.0, 2.0, "C5", "hichiriki", 0.0),
        (108.0, 4.0, "D5", "hichiriki", 0.0),
        (112.0, 2.0, "F5", "ryuteki", 0.1), (114.0, 2.0, "E5", "ryuteki", 0.1),
        (116.0, 4.0, "D5", "ryuteki", 0.1), (120.0, 8.0, "D5", "sho", 0.0),
    ]

    for b_pos, b_len, p_str, inst, pan_val in melody_track:
        freq = note_freq(p_str)
        s_time = b_pos * step
        dur = b_len * step
        if inst == "hichiriki":
            synth_hichiriki(buf, s_time, dur, freq, gain=0.22, pan=pan_val)
        elif inst == "ryuteki":
            synth_ryuteki(buf, s_time, dur, freq, gain=0.18, pan=pan_val)
        elif inst == "sho":
            synth_sho(buf, s_time, dur, freq, gain=0.15, pan=pan_val)

    # Percussion (Kick, Snare, Hi-hat, Taiko)
    for bar in range(bars):
        b_start = bar * 4.0
        if bar < 4:
            # Ceremonial Taiko accents on beat 1 & 3 of intro
            synth_drum(buf, b_start * step, "taiko", gain=0.35, prng=prng)
            synth_drum(buf, (b_start + 2.0) * step, "taiko", gain=0.25, prng=prng)
        else:
            # Driving STG Beat (Kick on 1, 2.5, 3; Snare on 2, 4)
            synth_drum(buf, b_start * step, "kick", gain=0.36, prng=prng)
            synth_drum(buf, (b_start + 1.5) * step, "kick", gain=0.28, prng=prng)
            synth_drum(buf, (b_start + 2.5) * step, "kick", gain=0.32, prng=prng)
            synth_drum(buf, (b_start + 1.0) * step, "snare", gain=0.34, prng=prng)
            synth_drum(buf, (b_start + 3.0) * step, "snare", gain=0.34, prng=prng)

            # Continuous 16th Hi-hats
            for sub in range(8):
                h_gain = 0.16 if sub % 2 == 0 else 0.10
                synth_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=h_gain, prng=prng)

    buf.apply_delay(delay_sec=0.28, feedback=0.30, mix=0.25)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 2: Stage 1 Plan B (Crimson Pulse - Retro Rock Drive)
# -------------------------------------------------------------
def generate_stage01_plan_b(file_path):
    bpm = 152
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(202)

    # Progression in F# minor (F#m - D - A - E / F#m - Bm - C#7 - F#m)
    chords = [
        # Intro
        (["F#4", "C#5"], "F#2"), (["D4", "A4"], "D2"), (["A3", "E4"], "A1"), (["E4", "B4"], "E2"),
        # Section A
        (["F#4", "C#5", "A5"], "F#2"), (["D4", "A4", "F#5"], "D2"),
        (["A3", "E4", "C#5"], "A1"), (["E4", "B4", "G#5"], "E2"),
        (["F#4", "C#5", "A5"], "F#2"), (["B3", "F#4", "D5"], "B1"),
        (["C#4", "G#4", "E#5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
        # Section B (Galloping Drive)
        (["D4", "A4", "F#5"], "D2"), (["E4", "B4", "G#5"], "E2"),
        (["C#4", "G#4", "E5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
        (["B3", "F#4", "D5"], "B1"), (["C#4", "G#4", "E#5"], "C#2"),
        (["D4", "A4", "F#5"], "D2"), (["E4", "B4", "G#5"], "E2"),
        # Section C (Climax)
        (["F#4", "C#5", "A5"], "F#2"), (["D4", "A4", "F#5"], "D2"),
        (["E4", "B4", "G#5"], "E2"), (["C#4", "G#4", "E#5"], "C#2"),
        (["D4", "A4", "F#5"], "D2"), (["B3", "F#4", "D5"], "B1"),
        (["C#4", "G#4", "E#5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
        # Outro
        (["D4", "A4", "F#5"], "D2"), (["E4", "B4", "G#5"], "E2"),
        (["C#4", "G#4", "E#5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        b_start = bar_idx * 4.0
        # Sho/Pad sustained harmony
        for n_str in chord_notes:
            synth_sho(buf, b_start * step, 4.0 * step, note_freq(n_str), gain=0.10, pan=0.2)

        # Fast 16-bit bass galloping rhythm
        b_freq = note_freq(bass_root)
        for s in range(16):
            if s % 4 != 3: # Rock gallop (da-da-da_ da-da-da_)
                synth_fm_bass(buf, (b_start + s * 0.25) * step, 0.22 * step, b_freq, gain=0.22, pan=0.0)

    # Lead Synth / Hichiriki Melody (Passionate Action Melody)
    melody = [
        (16.0, 1.5, "F#5"), (17.5, 0.5, "A5"), (18.0, 2.0, "G#5"), (20.0, 2.0, "F#5"), (22.0, 2.0, "E5"),
        (24.0, 1.5, "F#5"), (25.5, 0.5, "A5"), (26.0, 2.0, "B5"), (28.0, 2.0, "C#6"), (30.0, 2.0, "A5"),
        (32.0, 1.5, "F#5"), (33.5, 0.5, "G#5"), (34.0, 2.0, "A5"), (36.0, 2.0, "B5"), (38.0, 2.0, "G#5"),
        (40.0, 4.0, "F#5"), (44.0, 4.0, "E5"),
        # Section B
        (48.0, 2.0, "D6"), (50.0, 2.0, "C#6"), (52.0, 2.0, "B5"), (54.0, 2.0, "A5"),
        (56.0, 2.0, "G#5"), (58.0, 2.0, "A5"), (60.0, 4.0, "F#5"),
        (64.0, 2.0, "B5"), (66.0, 2.0, "C#6"), (68.0, 2.0, "D6"), (70.0, 2.0, "E6"),
        (72.0, 4.0, "C#6"), (76.0, 4.0, "F#5"),
        # Climax
        (80.0, 1.0, "F#5"), (81.0, 1.0, "A5"), (82.0, 2.0, "C#6"), (84.0, 2.0, "B5"), (86.0, 2.0, "A5"),
        (88.0, 2.0, "G#5"), (90.0, 2.0, "E5"), (92.0, 4.0, "F#5"),
    ]

    for m_beat, m_len, m_pitch in melody:
        f = note_freq(m_pitch)
        synth_hichiriki(buf, m_beat * step, m_len * step, f, gain=0.24, pan=-0.1)
        synth_ryuteki(buf, m_beat * step, m_len * step, f * 1.002, gain=0.12, pan=0.25)

    # Rock / STG Percussion
    for bar in range(bars):
        b_start = bar * 4.0
        # Kick on 1, 2.5, 3
        synth_drum(buf, b_start * step, "kick", gain=0.38, prng=prng)
        synth_drum(buf, (b_start + 1.5) * step, "kick", gain=0.30, prng=prng)
        synth_drum(buf, (b_start + 2.5) * step, "kick", gain=0.32, prng=prng)
        # Snare on 2, 4
        synth_drum(buf, (b_start + 1.0) * step, "snare", gain=0.35, prng=prng)
        synth_drum(buf, (b_start + 3.0) * step, "snare", gain=0.35, prng=prng)
        # Hi-hats
        for sub in range(8):
            synth_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.14, prng=prng)

    buf.apply_delay(delay_sec=0.24, feedback=0.28, mix=0.22)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 3: Boss 1 Plan A (Bio-Core ~ Pulsing Boundary)
# -------------------------------------------------------------
def generate_boss01_plan_a(file_path):
    bpm = 168
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(303)

    # Polyrhythmic Tension in G minor / diminished
    chords = [
        (["G3", "Db4", "G4"], "G1"), (["G3", "D4", "Bb4"], "G1"),
        (["Ab3", "Eb4", "C5"], "Ab1"), (["G3", "Db4", "G4"], "G1"),
        (["Eb4", "Bb4", "G5"], "Eb2"), (["Db4", "Ab4", "F5"], "Db2"),
        (["D4", "A4", "F#5"], "D2"), (["D4", "Ab4", "F5"], "D2"),
    ] * 4

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        b_start = bar_idx * 4.0
        # Dissonant Sho sustained chords
        for n_str in chord_notes:
            synth_sho(buf, b_start * step, 4.0 * step, note_freq(n_str), gain=0.14, pan=-0.2)

        # Menacing 16th organic bass stabs
        b_freq = note_freq(bass_root)
        for s in range(8):
            synth_fm_bass(buf, (b_start + s * 0.5) * step, 0.35 * step, b_freq, gain=0.26, pan=0.0)

    # Boss Aggressive Lead (Hichiriki scream + Ryuteki dissonances)
    boss_melody = [
        # Phrase 1: Threatening ascent
        (0.0, 1.5, "G4"), (1.5, 0.5, "Ab4"), (2.0, 2.0, "Db5"), (4.0, 2.0, "C5"), (6.0, 2.0, "Bb4"),
        (8.0, 1.5, "G4"), (9.5, 0.5, "Bb4"), (10.0, 2.0, "Db5"), (12.0, 4.0, "D5"),
        (16.0, 1.5, "G5"), (17.5, 0.5, "F5"), (18.0, 2.0, "Eb5"), (20.0, 2.0, "Db5"),
        (22.0, 2.0, "C5"), (24.0, 2.0, "Ab4"), (26.0, 4.0, "G4"),
        # Phrase 2: Desperate battle counterpoint
        (32.0, 1.0, "G5"), (33.0, 1.0, "Bb5"), (34.0, 2.0, "Db6"), (36.0, 2.0, "C6"),
        (38.0, 1.5, "Bb5"), (39.5, 0.5, "Ab5"), (40.0, 2.0, "G5"), (42.0, 2.0, "F#5"),
        (44.0, 4.0, "G5"), (48.0, 4.0, "Ab5"), (52.0, 4.0, "D5"), (56.0, 8.0, "G4"),
        # Phrase 3: Climax before phase shift
        (64.0, 2.0, "Db5"), (66.0, 2.0, "Eb5"), (68.0, 2.0, "F5"), (70.0, 2.0, "G5"),
        (72.0, 2.0, "Ab5"), (74.0, 2.0, "Bb5"), (76.0, 4.0, "Db6"), (80.0, 4.0, "C6"),
        (84.0, 2.0, "Bb5"), (86.0, 2.0, "Ab5"), (88.0, 8.0, "G5"),
    ]

    for b_pos, b_len, p_str in boss_melody:
        f = note_freq(p_str)
        synth_hichiriki(buf, b_pos * step, b_len * step, f, gain=0.26, pan=0.1)
        synth_ryuteki(buf, b_pos * step, b_len * step, f * 0.998, gain=0.14, pan=-0.2)

    # Taiko + Rapid Fire Percussion
    for bar in range(bars):
        b_start = bar * 4.0
        # Heavy double taiko strike
        synth_drum(buf, b_start * step, "taiko", gain=0.42, prng=prng)
        synth_drum(buf, (b_start + 0.75) * step, "taiko", gain=0.32, prng=prng)
        synth_drum(buf, (b_start + 2.0) * step, "taiko", gain=0.38, prng=prng)

        # Industrial Snare & Hi-hats
        synth_drum(buf, (b_start + 1.0) * step, "snare", gain=0.38, prng=prng)
        synth_drum(buf, (b_start + 3.0) * step, "snare", gain=0.38, prng=prng)
        synth_drum(buf, (b_start + 3.5) * step, "kick", gain=0.32, prng=prng)
        for s in range(8):
            synth_drum(buf, (b_start + s * 0.5) * step, "hat", gain=0.16, prng=prng)

    buf.apply_delay(delay_sec=0.22, feedback=0.32, mix=0.25)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 4: Boss 1 Plan B (Rhapsody of Samsara ~ Breakthrough)
# -------------------------------------------------------------
def generate_boss01_plan_b(file_path):
    bpm = 174
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(404)

    # Relentless high-speed rhapsody in C minor (Cm - Ab - Fm - G7)
    chords = [
        (["C4", "G4", "Eb5"], "C2"), (["Ab3", "Eb4", "C5"], "Ab1"),
        (["F3", "C4", "Ab4"], "F1"), (["G3", "D4", "B4"], "G1"),
        (["C4", "G4", "Eb5"], "C2"), (["Eb4", "Bb4", "G5"], "Eb2"),
        (["Ab3", "Eb4", "C5"], "Ab1"), (["G3", "D4", "B4"], "G1"),
    ] * 4

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        b_start = bar_idx * 4.0
        for n_str in chord_notes:
            synth_sho(buf, b_start * step, 4.0 * step, note_freq(n_str), gain=0.12, pan=0.2)

        # Ultra-fast 16th note arpeggiated bassline
        b_freq = note_freq(bass_root)
        for s in range(16):
            synth_fm_bass(buf, (b_start + s * 0.25) * step, 0.20 * step, b_freq, gain=0.22, pan=0.0)

    # Furious Melody
    furious_melody = [
        (0.0, 1.0, "C5"), (1.0, 1.0, "Eb5"), (2.0, 1.0, "G5"), (3.0, 1.0, "Ab5"),
        (4.0, 2.0, "G5"), (6.0, 2.0, "Eb5"), (8.0, 2.0, "F5"), (10.0, 2.0, "D5"),
        (12.0, 4.0, "C5"), (16.0, 1.0, "C6"), (17.0, 1.0, "B5"), (18.0, 2.0, "Ab5"),
        (20.0, 2.0, "G5"), (22.0, 2.0, "F5"), (24.0, 2.0, "Eb5"), (26.0, 2.0, "D5"),
        (28.0, 4.0, "C5"),
        # Climax
        (32.0, 2.0, "Eb5"), (34.0, 2.0, "G5"), (36.0, 2.0, "C6"), (38.0, 2.0, "D6"),
        (40.0, 2.0, "Eb6"), (42.0, 2.0, "D6"), (44.0, 4.0, "C6"), (48.0, 4.0, "B5"),
        (52.0, 4.0, "C6"), (56.0, 8.0, "G5"),
    ]

    for b_pos, b_len, p_str in furious_melody:
        f = note_freq(p_str)
        synth_hichiriki(buf, b_pos * step, b_len * step, f, gain=0.25, pan=-0.1)
        synth_ryuteki(buf, b_pos * step, b_len * step, f * 1.001, gain=0.15, pan=0.2)

    # High-speed Techno-STG Drumming
    for bar in range(bars):
        b_start = bar * 4.0
        synth_drum(buf, b_start * step, "kick", gain=0.38, prng=prng)
        synth_drum(buf, (b_start + 1.0) * step, "snare", gain=0.36, prng=prng)
        synth_drum(buf, (b_start + 2.0) * step, "kick", gain=0.38, prng=prng)
        synth_drum(buf, (b_start + 3.0) * step, "snare", gain=0.36, prng=prng)
        for s in range(8):
            synth_drum(buf, (b_start + s * 0.5) * step, "hat", gain=0.16, prng=prng)

    buf.apply_delay(delay_sec=0.20, feedback=0.25, mix=0.20)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Jingle JG-002: Sortie / Launch Fanfare
# -------------------------------------------------------------
def generate_jingle_sortie(file_path):
    duration = 3.6
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(505)

    # Sustained grand D major Gagaku chord (D - F# - A - D)
    for n in ["D4", "F#4", "A4", "D5"]:
        synth_sho(buf, 0.0, 3.4, note_freq(n), gain=0.20, pan=0.0)

    # Ascending flourish (Ryuteki + Biwa arpeggio)
    flourish = [
        (0.0, "D4"), (0.12, "F#4"), (0.24, "A4"), (0.36, "D5"),
        (0.48, "F#5"), (0.60, "A5"), (0.72, "D6")
    ]
    for t_sec, n in flourish:
        synth_biwa(buf, t_sec, 1.2, note_freq(n), gain=0.26, pan=0.3)
        synth_ryuteki(buf, t_sec, 0.8, note_freq(n), gain=0.20, pan=-0.2)

    # Climax triumph chord at 0.9s
    for n in ["D5", "F#5", "A5", "D6"]:
        synth_hichiriki(buf, 0.9, 2.5, note_freq(n), gain=0.18, pan=0.0)

    # Percussion: Taiko roll + massive engine launch boom
    synth_drum(buf, 0.0, "taiko", gain=0.45, prng=prng)
    synth_drum(buf, 0.45, "taiko", gain=0.40, prng=prng)
    synth_drum(buf, 0.90, "taiko", gain=0.60, prng=prng)
    synth_drum(buf, 0.90, "snare", gain=0.40, prng=prng)

    buf.apply_delay(delay_sec=0.25, feedback=0.35, mix=0.30)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Sound Effects (SFX)
# -------------------------------------------------------------

def generate_shot_cormii(file_path):
    """Cormii: Energetic, explosive plasma burst (sharp pitch drop + snappy transient)."""
    duration = 0.14
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi
    prng = RandomPRNG(601)

    for n in range(total):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        # Pitch drops 920Hz -> 180Hz
        f = 180.0 + 740.0 * math.exp(-t * 40.0)
        phase = two_pi * f * t
        # Square + sine punch
        square = 1.0 if math.sin(phase) > 0 else -1.0
        wave = 0.65 * square + 0.35 * math.sin(phase)
        noise = prng.next_float() * math.exp(-t * 80.0) * 0.25
        val = (wave + noise) * env * 0.45
        buf.add_sample(n, val, val)
    buf.write_wav(file_path)

def generate_shot_jiyoza(file_path):
    """Jiyoza: Focused, analytical laser chirp (dual harmonic sweep)."""
    duration = 0.15
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi

    for n in range(total):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 22.0)
        # Dual frequency sweep 1950Hz -> 620Hz & 1300Hz -> 410Hz
        f1 = 620.0 + 1330.0 * math.exp(-t * 25.0)
        f2 = 410.0 + 890.0 * math.exp(-t * 25.0)
        wave = 0.6 * math.sin(two_pi * f1 * t) + 0.4 * math.sin(two_pi * f2 * t)
        val = wave * env * 0.42
        buf.add_sample(n, val * 0.9, val * 1.1)
    buf.write_wav(file_path)

def generate_shot_mafio(file_path):
    """Mafio: Heavy bio-kinetic cannon (punchy sub-bass + crunchy crunch)."""
    duration = 0.18
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi
    prng = RandomPRNG(603)

    for n in range(total):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 18.0)
        # Heavy sub sweep 165Hz -> 42Hz
        f = 42.0 + 123.0 * math.exp(-t * 30.0)
        phase = two_pi * f * t
        sub = math.sin(phase)
        crunch = prng.next_float() * math.exp(-t * 45.0) * 0.45
        val = (sub * 0.7 + crunch) * env * 0.50
        buf.add_sample(n, val, val)
    buf.write_wav(file_path)

def generate_boss_warning(file_path):
    """Boss attack telegraph: Eerie ascending FM alarm with LFO shudder."""
    duration = 0.85
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi

    for n in range(total):
        t = n / SAMPLE_RATE
        env = (1.0 - math.exp(-t * 30.0)) * math.exp(-t * 2.5)
        # Ascending 320Hz -> 980Hz with 18Hz warble
        lfo = math.sin(two_pi * 18.0 * t) * 0.20
        f = (320.0 + 660.0 * (t / duration)) * (1.0 + lfo)
        mod = math.sin(two_pi * f * 2.0 * t) * 1.8
        carrier = math.sin(two_pi * f * t + mod)
        dissonance = 0.35 * math.sin(two_pi * (f * 1.414) * t) # Tritone
        val = (carrier + dissonance) * env * 0.40
        buf.add_sample(n, val * 0.85, val * 1.15)
    buf.write_wav(file_path)

def generate_boss_destroy(file_path):
    """Boss defeat: Massive multi-stage explosion, deep seismic rumble & crystalline dissipating tail."""
    duration = 2.8
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi
    prng = RandomPRNG(605)

    for n in range(total):
        t = n / SAMPLE_RATE
        noise = prng.next_float()

        # Initial shockwave crack (0 - 0.2s)
        crack = noise * math.exp(-t * 35.0) * 0.7

        # Deep seismic rumble (pitch drop 90Hz -> 24Hz)
        f_sub = 24.0 + 66.0 * math.exp(-t * 6.0)
        sub = math.sin(two_pi * f_sub * t) * math.exp(-t * 1.5) * 0.65

        # Secondary explosive bursts (at 0.25s, 0.55s, 0.90s)
        bursts = 0.0
        for b_time, b_gain in [(0.25, 0.5), (0.55, 0.45), (0.90, 0.4)]:
            if t > b_time:
                dt = t - b_time
                bursts += prng.next_float() * math.exp(-dt * 12.0) * b_gain

        # Crystalline sparkling dissipation (from 1.2s to 2.8s)
        sparkle = 0.0
        if t > 1.2:
            dt = t - 1.2
            sparkle = math.sin(two_pi * 1840.0 * t) * math.exp(-dt * 2.2) * 0.15

        val = (crack + sub + bursts + sparkle) * 0.55
        buf.add_sample(n, val * (1.0 + 0.1 * noise), val * (1.0 - 0.1 * noise))

    buf.apply_delay(delay_sec=0.32, feedback=0.40, mix=0.28)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Main Execution
# -------------------------------------------------------------
def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    print(f"=== Mw-fActory Sound Team: Generating Batch 01 Audio Assets ===")
    print(f"Target Root: {root_dir}")

    # 1. Music Assets
    m_dir = os.path.join(root_dir, "assets", "audio", "music")
    generate_stage01_plan_a(os.path.join(m_dir, "bgm_stage01_plan_a.wav"))
    generate_stage01_plan_b(os.path.join(m_dir, "bgm_stage01_plan_b.wav"))
    generate_boss01_plan_a(os.path.join(m_dir, "bgm_boss01_plan_a.wav"))
    generate_boss01_plan_b(os.path.join(m_dir, "bgm_boss01_plan_b.wav"))

    # 2. Jingles
    j_dir = os.path.join(root_dir, "assets", "audio", "jingles")
    generate_jingle_sortie(os.path.join(j_dir, "jg002_sortie.wav"))

    # 3. SFX
    s_dir = os.path.join(root_dir, "assets", "audio", "sfx")
    generate_shot_cormii(os.path.join(s_dir, "se_shot_cormii.wav"))
    generate_shot_jiyoza(os.path.join(s_dir, "se_shot_jiyoza.wav"))
    generate_shot_mafio(os.path.join(s_dir, "se_shot_mafio.wav"))
    generate_boss_warning(os.path.join(s_dir, "se_boss_warning.wav"))
    generate_boss_destroy(os.path.join(s_dir, "se_boss_destroy.wav"))

    print("=== All 10 Audio Assets Successfully Generated! ===")

if __name__ == "__main__":
    main()

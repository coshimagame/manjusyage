#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Stage 2 (Sea of Reminiscence) & Stage 3 (Solitary Garden / Ruins)
Super Famicom 12-Track Symphony Engine

Generates:
  - assets/audio/music/bgm_stage02_plan_a.wav (Sea of Reminiscence - Subaquatic Afterglow)
  - assets/audio/music/bgm_stage02_plan_b.wav (Sea of Reminiscence - Current Serenade)
  - assets/audio/music/bgm_stage03_plan_a.wav (Solitary Garden - Rusted Gears & Spider Lilies)
  - assets/audio/music/bgm_stage03_plan_b.wav (Solitary Garden - Corridor of Silence)
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

    def apply_snes_reverb(self, delay_sec=0.28, feedback=0.35, mix=0.30, damp=0.45):
        delay_samples = int(delay_sec * SAMPLE_RATE)
        if delay_samples <= 0: return
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
        dc_l = sum(self.left) / self.total if self.total > 0 else 0.0
        dc_r = sum(self.right) / self.total if self.total > 0 else 0.0
        for i in range(self.total):
            self.left[i] -= dc_l
            self.right[i] -= dc_r

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
# Sound Synthesis Tools
# -------------------------------------------------------------

def snes_vibrato(t, note_dur):
    if t < 0.35 or note_dur < 0.50: return 0.0
    ramp = min(1.0, (t - 0.35) / 0.28)
    return math.sin(TWO_PI * 4.6 * (t - 0.35)) * 0.0042 * ramp

def synth_sfc_lead(buf, start_sec, dur_sec, freq, gain=0.16, pan=0.0):
    """SFC Warm Lead (Mellow woodwind / reed)."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.040 * SAMPLE_RATE)
    fade_out = int(0.075 * SAMPLE_RATE)
    lp_val = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = snes_vibrato(t, dur_sec)
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.82 * math.sin(ph) + 0.18 * math.sin(2.0 * ph) + 0.05 * math.sin(3.0 * ph)
        lp_val += 0.35 * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_brass_layer(buf, start_sec, dur_sec, freq, gain=0.11, pan=-0.1):
    """Warm brass octave / 3rd layer to thicken lead."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.060 * SAMPLE_RATE)
    fade_out = int(0.080 * SAMPLE_RATE)
    lp_val = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = snes_vibrato(t, dur_sec)
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.65 * math.sin(ph) + 0.25 * math.sin(2.0 * ph) + 0.12 * math.sin(3.0 * ph)
        lp_val += 0.30 * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_chime(buf, start_sec, freq, gain=0.08, pan=0.15):
    """Crystal attack transient."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.50 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 14.0)
        sig = (math.sin(TWO_PI * freq * t) + 0.3 * math.sin(TWO_PI * freq * 2.0 * t)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_sfc_cello(buf, start_sec, dur_sec, freq, gain=0.12, pan=-0.25):
    """Warm low-mid counterpoint."""
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
        raw = 0.70 * math.sin(ph) + 0.28 * math.sin(2.0 * ph) + 0.10 * math.sin(3.0 * ph)
        lp_val += 0.25 * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_strings_pad(buf, start_sec, dur_sec, chord_freqs, gain=0.08, pan_spread=0.45):
    """Lush 4-voice polyphonic strings pad."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.20 * SAMPLE_RATE)
    fade_out = int(0.24 * SAMPLE_RATE)

    for i, freq in enumerate(chord_freqs):
        if freq <= 0: continue
        pan = -pan_spread + (2.0 * pan_spread * i / max(1, len(chord_freqs) - 1))
        theta = (pan + 1.0) * math.pi / 4.0

        for n in range(count):
            t = n / SAMPLE_RATE
            env = 1.0
            if n < fade_in: env = n / fade_in
            elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

            w1 = math.sin(TWO_PI * freq * t)
            w2 = math.sin(TWO_PI * freq * 1.0025 * t)
            sub = 0.25 * math.sin(TWO_PI * freq * 0.5 * t)
            sample = (w1 * 0.45 + w2 * 0.40 + sub) * env * gain
            buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sfc_bass(buf, start_sec, dur_sec, freq, gain=0.22):
    """SFC warm punchy bass."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 5.0) * (1.0 - math.exp(-t * 300.0))
        sig = (0.75 * math.sin(TWO_PI * freq * t) +
               0.25 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 12.0) +
               0.15 * math.sin(TWO_PI * freq * 0.5 * t)) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_sfc_sub(buf, start_sec, dur_sec, freq, gain=0.18):
    """Sub-bass bottom end."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    sub_f = freq if freq < 90 else freq * 0.5

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        sig = math.sin(TWO_PI * sub_f * t) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_bubble_drop(buf, start_sec, freq=650.0, gain=0.10, pan=0.2):
    """Water bubble / aquatic drop sound for Stage 2."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.18 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        # Rising pitch chirp like a bubble popping
        f = freq * (1.0 + 1.2 * math.exp(-t * 30.0) - 0.4 * math.sin(TWO_PI * 18.0 * t))
        env = math.exp(-t * 22.0)
        sig = math.sin(TWO_PI * f * t) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_clockwork_tick(buf, start_sec, gain=0.08, pan=-0.2):
    """Mechanical gear / clockwork tick for Stage 3 ruins."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.04 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 120.0)
        # Resonant metallic wood click
        sig = (math.sin(TWO_PI * 2200.0 * t) + 0.4 * math.sin(TWO_PI * 3400.0 * t)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_sfc_drum(buf, start_sec, kind="kick", gain=0.32, prng=None):
    start = int(start_sec * SAMPLE_RATE)
    durations = {"kick": 0.24, "snare": 0.22, "hat": 0.05, "crash": 1.40, "taiko": 0.55}
    count = min(int(durations.get(kind, 0.20) * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        noise = prng.next_float() if prng else 0.0
        if kind == "kick":
            f_inst = 46.0 + 38.0 * math.exp(-t * 28.0)
            sig = math.sin(TWO_PI * f_inst * t) * math.exp(-t * 14.0)
        elif kind == "snare":
            tone = math.sin(TWO_PI * 175.0 * t) * 0.45 * math.exp(-t * 24.0)
            wire = noise * 0.55 * math.exp(-t * 18.0)
            sig = tone + wire
        elif kind == "hat":
            sig = noise * math.exp(-t * 90.0) * 0.35
        elif kind == "crash":
            shimmer = (math.sin(TWO_PI * 4000.0 * t) + math.sin(TWO_PI * 5800.0 * t)) * 0.15
            sig = (noise * 0.85 + shimmer) * math.exp(-t * 3.0)
        elif kind == "taiko":
            f_inst = 65.0 + 35.0 * math.exp(-t * 12.0)
            sig = math.sin(TWO_PI * f_inst * t) * math.exp(-t * 5.5)

        sample = sig * gain
        if kind == "crash":
            buf.add_sample(start + n, sample * 0.85, sample * 1.15)
        else:
            buf.add_sample(start + n, sample, sample)

# -------------------------------------------------------------
# STAGE 2: 追憶の海 (Sea of Reminiscence) - Plan A
# Subaquatic Afterglow: F minor, 136 BPM, Floating, Ethereal, Deep Ocean
# -------------------------------------------------------------
def generate_stage02_plan_a(file_path):
    bpm = 136
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(201)

    # Progression: Fm9 -> DbM7 -> Bbm9 -> C7b9 / Fm9 -> AbM7 -> Bbm7 -> C7
    chords_full = [
        # Intro: Bars 1-4 (Deep water drone, bubble drops, soft bell)
        (["F3", "Ab3", "C4", "G4"], "F1"), (["Db3", "F3", "Ab3", "Eb4"], "Db1"),
        (["Bb2", "Db3", "F3", "C4"], "Bb0"), (["C3", "E3", "G3", "Bb3"], "C1"),
        # Section A: Bars 5-12 (Aquatic strings, flute melody, gentle groove)
        (["F3", "Ab3", "C4", "Eb4"], "F1"), (["Db3", "F3", "Ab3", "C4"], "Db1"),
        (["Eb3", "G3", "Bb3", "F4"], "Eb1"), (["C3", "E3", "G3", "Bb3"], "C1"),
        (["F3", "Ab3", "C4", "Eb4"], "F1"), (["Db3", "F3", "Ab3", "C4"], "Db1"),
        (["Bb2", "Db3", "F3", "Ab3"], "Bb0"), (["C3", "E3", "G3", "C4"], "C1"),
        # Section B: Bars 13-20 (Current swells & sorrowful longing)
        (["Ab3", "C4", "Eb4", "G4"], "Ab1"), (["Eb3", "G3", "Bb3", "F4"], "Eb1"),
        (["Db3", "F3", "Ab3", "C4"], "Db1"), (["C3", "E3", "G3", "Bb3"], "C1"),
        (["F3", "Ab3", "C4", "Eb4"], "F1"), (["Bb2", "Db3", "F3", "Ab3"], "Bb0"),
        (["Db3", "F3", "Ab3", "C4"], "Db1"), (["Eb3", "G3", "Bb3", "Db4"], "Eb1"),
        # Section C: Bars 21-28 (Luminous subaquatic climax)
        (["F3", "Ab3", "C4", "F4"], "F1"), (["Db3", "F3", "Ab3", "F4"], "Db1"),
        (["Eb3", "G3", "Bb3", "G4"], "Eb1"), (["F3", "A3", "C4", "A4"], "F1"),
        (["Bb2", "Db3", "F3", "Bb3"], "Bb0"), (["C3", "E3", "G3", "C4"], "C1"),
        (["Db3", "F3", "Ab3", "Db4"], "Db1"), (["Eb3", "G3", "Bb3", "Eb4"], "Eb1"),
        # Outro: Bars 29-32
        (["F3", "Ab3", "C4", "F4"], "F1"), (["Db3", "F3", "Ab3", "C4"], "Db1"),
        (["C3", "E3", "G3", "Bb3"], "C1"), (["F3", "Ab3", "C4", "F4"], "F1"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        # Strings pad (warm aquatic swell)
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.08, pan_spread=0.5)

        # Bubble drops at varied intervals
        if bar_idx >= 2:
            for b_offset in [0.75, 2.25, 3.5]:
                pan_b = -0.3 + 0.6 * prng.next_float()
                synth_bubble_drop(buf, (b_start + b_offset) * step, freq=500.0 + 300.0 * prng.next_float(), gain=0.09, pan=pan_b)

        # Bass groove (from bar 4)
        if bar_idx >= 4:
            b_f = note_freq(bass_root)
            for sub, oct_flag in [(0, 0), (1.5, 1), (2.0, 0), (3.0, 1)]:
                use_f = b_f * 2.0 if oct_flag else b_f
                synth_sfc_bass(buf, (b_start + sub) * step, 0.45 * step, use_f, gain=0.22)
                synth_sfc_sub(buf, (b_start + sub) * step, 0.45 * step, use_f, gain=0.18)

    # Mournful, floating sea melody (Pan flute + soft brass + chime)
    sea_melody = [
        # Intro
        (0.0, 2.0, "C5"), (2.0, 2.0, "Ab4"), (4.0, 2.0, "Bb4"), (6.0, 2.0, "G4"),
        (8.0, 3.0, "F4"), (11.0, 1.0, "G4"), (12.0, 4.0, "Ab4"),
        # Section A: Main lyrical theme
        (16.0, 1.5, "C5"), (17.5, 0.5, "Db5"), (18.0, 2.0, "C5"), (20.0, 2.0, "Ab4"),
        (22.0, 2.0, "Bb4"), (24.0, 1.5, "Ab4"), (25.5, 0.5, "G4"), (26.0, 2.0, "F4"),
        (28.0, 2.0, "G4"), (30.0, 2.0, "Eb4"), (32.0, 2.0, "F4"), (34.0, 2.0, "Ab4"),
        (36.0, 2.0, "G4"), (38.0, 2.0, "E4"), (40.0, 4.0, "F4"),
        # Section B: Deep emotional crest
        (48.0, 1.5, "Eb5"), (49.5, 0.5, "F5"), (50.0, 2.0, "Eb5"), (52.0, 2.0, "C5"),
        (54.0, 2.0, "Db5"), (56.0, 1.5, "C5"), (57.5, 0.5, "Bb4"), (58.0, 2.0, "Ab4"),
        (60.0, 4.0, "G4"), (64.0, 2.0, "F4"), (66.0, 2.0, "Ab4"),
        (68.0, 2.0, "C5"), (70.0, 2.0, "Eb5"), (72.0, 4.0, "Db5"), (76.0, 4.0, "C5"),
        # Section C: Climax
        (80.0, 1.5, "F5"), (81.5, 0.5, "G5"), (82.0, 2.0, "Ab5"), (84.0, 2.0, "G5"),
        (86.0, 2.0, "Eb5"), (88.0, 2.0, "F5"), (90.0, 2.0, "C5"), (92.0, 4.0, "Db5"),
        (96.0, 2.0, "Bb4"), (98.0, 2.0, "C5"), (100.0, 2.0, "Ab4"), (102.0, 2.0, "G4"),
        (104.0, 4.0, "F4"), (108.0, 4.0, "C5"), (112.0, 4.0, "F4"),
    ]

    for m_pos, m_len, m_pitch in sea_melody:
        f = note_freq(m_pitch)
        s_time = m_pos * step
        dur = m_len * step
        synth_sfc_lead(buf, s_time, dur, f, gain=0.17, pan=0.0)
        synth_sfc_brass_layer(buf, s_time, dur, f * 0.5, gain=0.10, pan=-0.1)
        synth_sfc_chime(buf, s_time, f * 2.0, gain=0.08, pan=0.2)

    # Cello counterpoint
    sea_cello = [
        (20.0, 2.0, "F3"), (22.0, 2.0, "Db3"), (24.0, 4.0, "Eb3"),
        (36.0, 2.0, "C3"), (38.0, 2.0, "E3"), (40.0, 4.0, "F3"),
        (52.0, 2.0, "Ab3"), (54.0, 2.0, "Eb3"), (56.0, 4.0, "F3"),
        (68.0, 2.0, "Bb3"), (70.0, 2.0, "G3"), (72.0, 4.0, "Ab3"),
        (84.0, 2.0, "Eb3"), (86.0, 2.0, "C3"), (88.0, 4.0, "Db3"),
        (100.0, 2.0, "C3"), (102.0, 2.0, "Bb2"), (104.0, 4.0, "F2"),
    ]
    for c_pos, c_len, c_pitch in sea_cello:
        synth_sfc_cello(buf, c_pos * step, c_len * step, note_freq(c_pitch), gain=0.12, pan=-0.2)

    # Gentle aquatic percussion (gentle kick, warm snare, silky hi-hat, soft crash)
    for bar in range(bars):
        b_start = bar * 4.0
        if bar in [0, 4, 12, 20, 28]:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.32, prng=prng)

        if bar >= 4:
            synth_sfc_drum(buf, b_start * step, "kick", gain=0.34, prng=prng)
            synth_sfc_drum(buf, (b_start + 2.0) * step, "kick", gain=0.28, prng=prng)
            synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.30, prng=prng)
            synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.30, prng=prng)
            for sub in range(8):
                synth_sfc_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.09, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.32, feedback=0.38, mix=0.32, damp=0.45)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# STAGE 2: 追憶の海 (Sea of Reminiscence) - Plan B
# Current Serenade: Bb minor (Dorian), 142 BPM, Flowing currents, energetic waves
# -------------------------------------------------------------
def generate_stage02_plan_b(file_path):
    bpm = 142
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(203)

    chords_full = [
        (["Bb3", "Db4", "F4", "Ab4"], "Bb1"), (["Gb3", "Bb3", "Db4", "F4"], "Gb1"),
        (["Ab3", "C4", "Eb4", "G4"], "Ab1"), (["F3", "A3", "C4", "Eb4"], "F1"),
        (["Bb3", "Db4", "F4", "Ab4"], "Bb1"), (["Gb3", "Bb3", "Db4", "Gb4"], "Gb1"),
        (["Eb3", "Gb3", "Bb3", "Db4"], "Eb1"), (["F3", "A3", "C4", "F4"], "F1"),
        (["Gb3", "Bb3", "Db4", "F4"], "Gb1"), (["Ab3", "C4", "Eb4", "Ab4"], "Ab1"),
        (["F3", "A3", "C4", "Eb4"], "F1"), (["Bb3", "Db4", "F4", "Bb4"], "Bb1"),
        (["Eb3", "Gb3", "Bb3", "Eb4"], "Eb1"), (["F3", "A3", "C4", "F4"], "F1"),
        (["Gb3", "Bb3", "Db4", "Gb4"], "Gb1"), (["Ab3", "C4", "Eb4", "Ab4"], "Ab1"),
        (["Bb3", "Db4", "F4", "Bb4"], "Bb1"), (["Gb3", "Bb3", "Db4", "Gb4"], "Gb1"),
        (["Ab3", "C4", "Eb4", "Ab4"], "Ab1"), (["F3", "A3", "C4", "F4"], "F1"),
        (["Eb3", "Gb3", "Bb3", "Eb4"], "Eb1"), (["F3", "A3", "C4", "F4"], "F1"),
        (["Gb3", "Bb3", "Db4", "Gb4"], "Gb1"), (["Ab3", "C4", "Eb4", "Ab4"], "Ab1"),
        (["Bb3", "Db4", "F4", "Bb4"], "Bb1"), (["Gb3", "Bb3", "Db4", "Gb4"], "Gb1"),
        (["F3", "A3", "C4", "F4"], "F1"), (["Bb3", "Db4", "F4", "Bb4"], "Bb1"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.08, pan_spread=0.45)

        # Flowing 16th arpeggios like streaming underwater bubbles
        for s in range(16):
            p_note = chord_notes[s % len(chord_notes)]
            f_arp = note_freq(p_note)
            pan_arp = 0.3 if s % 2 == 0 else -0.3
            # bell/harp sound
            start_s = (b_start + s * 0.25) * step
            synth_sfc_chime(buf, start_s, f_arp, gain=0.06, pan=pan_arp)

        b_f = note_freq(bass_root)
        for s in [0, 1.5, 2.5, 3.0]:
            synth_sfc_bass(buf, (b_start + s) * step, 0.40 * step, b_f, gain=0.22)
            synth_sfc_sub(buf, (b_start + s) * step, 0.40 * step, b_f, gain=0.18)

    melody = [
        (16.0, 1.5, "F5"), (17.5, 0.5, "Gb5"), (18.0, 2.0, "F5"), (20.0, 2.0, "Db5"),
        (22.0, 2.0, "Eb5"), (24.0, 1.5, "Db5"), (25.5, 0.5, "C5"), (26.0, 2.0, "Bb4"),
        (28.0, 2.0, "C5"), (30.0, 2.0, "Ab4"), (32.0, 2.0, "Bb4"), (34.0, 2.0, "Db5"),
        (36.0, 2.0, "C5"), (38.0, 2.0, "A4"), (40.0, 4.0, "Bb4"),
        (48.0, 1.5, "Db5"), (49.5, 0.5, "Eb5"), (50.0, 2.0, "F5"), (52.0, 2.0, "Gb5"),
        (54.0, 2.0, "Ab5"), (56.0, 2.0, "F5"), (58.0, 2.0, "Eb5"), (60.0, 4.0, "F5"),
        (64.0, 2.0, "Gb5"), (66.0, 2.0, "F5"), (68.0, 2.0, "Eb5"), (70.0, 2.0, "Db5"),
        (72.0, 4.0, "C5"), (76.0, 4.0, "F4"),
        (80.0, 1.0, "Bb5"), (81.0, 1.0, "Ab5"), (82.0, 2.0, "Gb5"), (84.0, 2.0, "F5"),
        (86.0, 2.0, "Eb5"), (88.0, 2.0, "Db5"), (90.0, 2.0, "C5"), (92.0, 4.0, "Bb4"),
    ]

    for m_pos, m_len, m_pitch in melody:
        f = note_freq(m_pitch)
        s_time = m_pos * step
        dur = m_len * step
        synth_sfc_lead(buf, s_time, dur, f, gain=0.17, pan=0.0)
        synth_sfc_brass_layer(buf, s_time, dur, f * 0.5, gain=0.10, pan=-0.1)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar in [0, 4, 12, 20, 28]:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.35, prng=prng)

        synth_sfc_drum(buf, b_start * step, "kick", gain=0.36, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.5) * step, "kick", gain=0.30, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.32, prng=prng)
        synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.32, prng=prng)
        for sub in range(8):
            synth_sfc_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.11, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.28, feedback=0.34, mix=0.28, damp=0.40)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# STAGE 3: 孤独な庭 (Solitary Garden / Mechanical Ruins) - Plan A
# Rusted Gears and Spider Lilies: A minor / Insen Modal, 144 BPM
# Clockwork mechanical ticks, overgrown flowers, eerie delicate koto, nostalgic sorrow
# -------------------------------------------------------------
def generate_stage03_plan_a(file_path):
    bpm = 144
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(301)

    # Insen / Hirajoshi flavor in A minor (A - Bb - D - E - F - A)
    # Am -> BbM7 -> Dm9 -> E7b9 / Am -> F#dim -> F -> E7 / Dm -> Am -> Bb -> E7
    chords_full = [
        # Intro: Bars 1-4 (Clockwork ticking, delicate koto plucks, eerie strings)
        (["A3", "C4", "E4", "A4"], "A1"), (["Bb3", "D4", "F4", "Bb4"], "Bb1"),
        (["D4", "F4", "A4", "D5"], "D2"), (["E4", "G#4", "B4", "E5"], "E2"),
        # Section A: Bars 5-12 (Mechanical groove, solitary flute melody)
        (["A3", "C4", "E4", "B4"], "A1"), (["Bb3", "D4", "F4", "A4"], "Bb1"),
        (["D4", "F4", "A4", "C5"], "D2"), (["E3", "G#3", "B3", "E4"], "E1"),
        (["A3", "C4", "E4", "B4"], "A1"), (["F3", "A3", "C4", "E4"], "F1"),
        (["D3", "F3", "A3", "D4"], "D1"), (["E3", "G#3", "B3", "D4"], "E1"),
        # Section B: Bars 13-20 (Overgrown garden sorrow)
        (["D4", "F4", "A4", "D5"], "D2"), (["A3", "C4", "E4", "A4"], "A1"),
        (["Bb3", "D4", "F4", "Bb4"], "Bb1"), (["E3", "G#3", "B3", "E4"], "E1"),
        (["F3", "A3", "C4", "F4"], "F1"), (["D3", "F3", "A3", "D4"], "D1"),
        (["Bb2", "D3", "F3", "Bb3"], "Bb0"), (["E3", "G#3", "B3", "E4"], "E1"),
        # Section C: Bars 21-28 (Passionate ruined climax)
        (["A3", "C4", "E4", "A4"], "A1"), (["Bb3", "D4", "F4", "D5"], "Bb1"),
        (["D4", "F4", "A4", "F5"], "D2"), (["E4", "G#4", "B4", "E5"], "E2"),
        (["F3", "A3", "C4", "A4"], "F1"), (["D3", "F3", "A3", "F4"], "D1"),
        (["Bb2", "D3", "F3", "D4"], "Bb0"), (["E3", "G#3", "B3", "E4"], "E1"),
        # Outro: Bars 29-32
        (["A3", "C4", "E4", "A4"], "A1"), (["Bb3", "D4", "F4", "Bb4"], "Bb1"),
        (["E3", "G#3", "B3", "E4"], "E1"), (["A3", "C4", "E4", "A4"], "A1"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        # Eerie strings pad
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.08, pan_spread=0.45)

        # Clockwork mechanical gear ticks (continuous 16th texture on right and left)
        for s in range(16):
            if s % 2 == 0:
                synth_clockwork_tick(buf, (b_start + s * 0.25) * step, gain=0.07, pan=-0.3)
            else:
                synth_clockwork_tick(buf, (b_start + s * 0.25) * step, gain=0.05, pan=0.3)

        # Delicate koto/harp arpeggio (weaving Japanese Insen scale tones)
        for s in range(16):
            p_note = chord_notes[s % len(chord_notes)]
            synth_sfc_chime(buf, (b_start + s * 0.25) * step, note_freq(p_note), gain=0.07, pan=0.25)

        # Bass groove (from bar 4)
        if bar_idx >= 4:
            b_f = note_freq(bass_root)
            for sub in [0, 1.5, 2.5, 3.0]:
                synth_sfc_bass(buf, (b_start + sub) * step, 0.42 * step, b_f, gain=0.22)
                synth_sfc_sub(buf, (b_start + sub) * step, 0.40 * step, b_f, gain=0.18)

    # Solitary Flute / Hichiriki Lead (Japanese Insen modal melody)
    garden_melody = [
        # Intro
        (0.0, 2.0, "E5"), (2.0, 1.0, "F5"), (3.0, 1.0, "E5"), (4.0, 2.0, "Bb4"),
        (6.0, 2.0, "A4"), (8.0, 2.0, "D5"), (10.0, 2.0, "E5"), (12.0, 4.0, "A4"),
        # Section A: Solitary theme
        (16.0, 1.5, "A4"), (17.5, 0.5, "Bb4"), (18.0, 2.0, "D5"), (20.0, 2.0, "E5"),
        (22.0, 2.0, "F5"), (24.0, 1.5, "E5"), (25.5, 0.5, "D5"), (26.0, 2.0, "Bb4"),
        (28.0, 2.0, "A4"), (30.0, 2.0, "E4"), (32.0, 2.0, "A4"), (34.0, 2.0, "D5"),
        (36.0, 2.0, "C5"), (38.0, 2.0, "B4"), (40.0, 4.0, "A4"),
        # Section B: Longing for the absent master
        (48.0, 2.0, "D5"), (50.0, 2.0, "F5"), (52.0, 2.0, "A5"), (54.0, 2.0, "Bb5"),
        (56.0, 1.5, "A5"), (57.5, 0.5, "F5"), (58.0, 2.0, "E5"), (60.0, 4.0, "D5"),
        (64.0, 2.0, "F5"), (66.0, 2.0, "E5"), (68.0, 2.0, "D5"), (70.0, 2.0, "Bb4"),
        (72.0, 4.0, "A4"), (76.0, 4.0, "E5"),
        # Section C: Climax
        (80.0, 1.5, "A5"), (81.5, 0.5, "Bb5"), (82.0, 2.0, "A5"), (84.0, 2.0, "F5"),
        (86.0, 2.0, "E5"), (88.0, 2.0, "D5"), (90.0, 2.0, "Bb4"), (92.0, 4.0, "A4"),
        (96.0, 2.0, "F5"), (98.0, 2.0, "E5"), (100.0, 2.0, "D5"), (102.0, 2.0, "Bb4"),
        (104.0, 4.0, "A4"), (108.0, 4.0, "E4"), (112.0, 4.0, "A4"),
    ]

    for m_pos, m_len, m_pitch in garden_melody:
        f = note_freq(m_pitch)
        s_time = m_pos * step
        dur = m_len * step
        synth_sfc_lead(buf, s_time, dur, f, gain=0.17, pan=0.0)
        synth_sfc_brass_layer(buf, s_time, dur, f * 0.5, gain=0.10, pan=-0.1)

    # Cello counter-melody
    garden_cello = [
        (20.0, 2.0, "F3"), (22.0, 2.0, "D3"), (24.0, 4.0, "E3"),
        (36.0, 2.0, "D3"), (38.0, 2.0, "E3"), (40.0, 4.0, "A2"),
        (52.0, 2.0, "D3"), (54.0, 2.0, "F3"), (56.0, 4.0, "G3"),
        (68.0, 2.0, "Bb3"), (70.0, 2.0, "A3"), (72.0, 4.0, "E3"),
        (84.0, 2.0, "D3"), (86.0, 2.0, "Bb2"), (88.0, 4.0, "A2"),
    ]
    for c_pos, c_len, c_pitch in garden_cello:
        synth_sfc_cello(buf, c_pos * step, c_len * step, note_freq(c_pitch), gain=0.12, pan=-0.25)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar in [0, 4, 12, 20, 28]:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.36, prng=prng)

        if bar < 4:
            synth_sfc_drum(buf, b_start * step, "taiko", gain=0.38, prng=prng)
        else:
            synth_sfc_drum(buf, b_start * step, "kick", gain=0.36, prng=prng)
            synth_sfc_drum(buf, (b_start + 1.5) * step, "kick", gain=0.30, prng=prng)
            synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.34, prng=prng)
            synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.34, prng=prng)
            for sub in range(8):
                synth_sfc_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.10, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.28, feedback=0.35, mix=0.30, damp=0.42)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# STAGE 3: 孤独な庭 (Solitary Garden / Mechanical Ruins) - Plan B
# Corridor of Silence: E minor, 138 BPM, Mysterious clockwork STG drive
# -------------------------------------------------------------
def generate_stage03_plan_b(file_path):
    bpm = 138
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(302)

    chords_full = [
        (["E3", "G3", "B3", "E4"], "E1"), (["C3", "E3", "G3", "C4"], "C1"),
        (["A2", "C3", "E3", "A3"], "A0"), (["B2", "D#3", "F#3", "B3"], "B0"),
        (["E3", "G3", "B3", "E4"], "E1"), (["C3", "E3", "G3", "E4"], "C1"),
        (["D3", "F#3", "A3", "D4"], "D1"), (["B2", "D#3", "F#3", "B3"], "B0"),
        (["C3", "E3", "G3", "C4"], "C1"), (["D3", "F#3", "A3", "D4"], "D1"),
        (["B2", "D#3", "F#3", "B3"], "B0"), (["E3", "G3", "B3", "E4"], "E1"),
        (["A2", "C3", "E3", "A3"], "A0"), (["B2", "D#3", "F#3", "B3"], "B0"),
        (["C3", "E3", "G3", "C4"], "C1"), (["D3", "F#3", "A3", "D4"], "D1"),
        (["E3", "G3", "B3", "E4"], "E1"), (["C3", "E3", "G3", "C4"], "C1"),
        (["D3", "F#3", "A3", "D4"], "D1"), (["B2", "D#3", "F#3", "B3"], "B0"),
        (["A2", "C3", "E3", "A3"], "A0"), (["B2", "D#3", "F#3", "B3"], "B0"),
        (["C3", "E3", "G3", "C4"], "C1"), (["D3", "F#3", "A3", "D4"], "D1"),
        (["E3", "G3", "B3", "E4"], "E1"), (["C3", "E3", "G3", "C4"], "C1"),
        (["B2", "D#3", "F#3", "B3"], "B0"), (["E3", "G3", "B3", "E4"], "E1"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords_full):
        b_start = bar_idx * 4.0
        c_freqs = [note_freq(n) for n in chord_notes]
        synth_sfc_strings_pad(buf, b_start * step, 4.0 * step, c_freqs, gain=0.08, pan_spread=0.45)

        for s in range(16):
            if s % 2 == 0:
                synth_clockwork_tick(buf, (b_start + s * 0.25) * step, gain=0.06, pan=0.3)

        b_f = note_freq(bass_root)
        for s in [0, 1.5, 2.5, 3.0]:
            synth_sfc_bass(buf, (b_start + s) * step, 0.42 * step, b_f, gain=0.22)
            synth_sfc_sub(buf, (b_start + s) * step, 0.40 * step, b_f, gain=0.18)

    melody = [
        (16.0, 1.5, "B4"), (17.5, 0.5, "C5"), (18.0, 2.0, "B4"), (20.0, 2.0, "G4"),
        (22.0, 2.0, "A4"), (24.0, 1.5, "G4"), (25.5, 0.5, "F#4"), (26.0, 2.0, "E4"),
        (28.0, 2.0, "F#4"), (30.0, 2.0, "D4"), (32.0, 2.0, "E4"), (34.0, 2.0, "G4"),
        (36.0, 2.0, "F#4"), (38.0, 2.0, "D#4"), (40.0, 4.0, "E4"),
        (48.0, 1.5, "G5"), (49.5, 0.5, "A5"), (50.0, 2.0, "B5"), (52.0, 2.0, "C6"),
        (54.0, 2.0, "B5"), (56.0, 2.0, "G5"), (58.0, 2.0, "A5"), (60.0, 4.0, "B5"),
        (64.0, 2.0, "C6"), (66.0, 2.0, "B5"), (68.0, 2.0, "A5"), (70.0, 2.0, "G5"),
        (72.0, 4.0, "F#5"), (76.0, 4.0, "B4"),
        (80.0, 1.5, "E5"), (81.5, 0.5, "F#5"), (82.0, 2.0, "G5"), (84.0, 2.0, "A5"),
        (86.0, 2.0, "B5"), (88.0, 2.0, "C6"), (90.0, 2.0, "D6"), (92.0, 4.0, "E6"),
    ]

    for m_pos, m_len, m_pitch in melody:
        f = note_freq(m_pitch)
        s_time = m_pos * step
        dur = m_len * step
        synth_sfc_lead(buf, s_time, dur, f, gain=0.17, pan=0.0)
        synth_sfc_brass_layer(buf, s_time, dur, f * 0.5, gain=0.10, pan=-0.1)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar in [0, 4, 12, 20, 28]:
            synth_sfc_drum(buf, b_start * step, "crash", gain=0.35, prng=prng)

        synth_sfc_drum(buf, b_start * step, "kick", gain=0.36, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.5) * step, "kick", gain=0.30, prng=prng)
        synth_sfc_drum(buf, (b_start + 1.0) * step, "snare", gain=0.32, prng=prng)
        synth_sfc_drum(buf, (b_start + 3.0) * step, "snare", gain=0.32, prng=prng)
        for sub in range(8):
            synth_sfc_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.11, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.28, feedback=0.34, mix=0.28, damp=0.40)
    buf.write_wav(file_path)

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    m_dir = os.path.join(root_dir, "assets", "audio", "music")
    print(f"=== Synthesizing Stage 2 (Sea) and Stage 3 (Ruins/Garden) Audio Assets ===")
    generate_stage02_plan_a(os.path.join(m_dir, "bgm_stage02_plan_a.wav"))
    generate_stage02_plan_b(os.path.join(m_dir, "bgm_stage02_plan_b.wav"))
    generate_stage03_plan_a(os.path.join(m_dir, "bgm_stage03_plan_a.wav"))
    generate_stage03_plan_b(os.path.join(m_dir, "bgm_stage03_plan_b.wav"))
    print("=== Stage 2 and Stage 3 BGM Generated Successfully! ===")

if __name__ == "__main__":
    main()

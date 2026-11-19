#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Stage 4 (Forking Skies) & Stage 5 (Fortress of Oblivion)
High-Speed Thrilling STG BGM Engine

Generates:
  - assets/audio/music/bgm_stage04_plan_a.wav (分岐する空 〜 碧落の疾走 / Azure Gale, 165 BPM)
  - assets/audio/music/bgm_stage04_plan_b.wav (分岐する空 〜 乱気流のロンド / Turbulence Rondo, 158 BPM)
  - assets/audio/music/bgm_stage05_plan_a.wav (忘却の要塞 〜 鋼鉄の残影 / Iron Echoes, 148 BPM)
  - assets/audio/music/bgm_stage05_plan_b.wav (忘却の要塞 〜 機械仕掛けの記憶 / Clockwork Citadel, 152 BPM)
"""

import math
import struct
import wave
import os

SAMPLE_RATE = 44100
TWO_PI = 2.0 * math.pi

class RandomPRNG:
    def __init__(self, seed=20261120):
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

    def apply_snes_reverb(self, delay_sec=0.28, feedback=0.36, mix=0.32, damp=0.45):
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


# =============================================================================
# Instruments for Stage 4 (Sky & Speed) and Stage 5 (Heavy Fortress)
# =============================================================================

def synth_sky_brass_lead(buf, start_sec, dur_sec, freq, gain=0.20, pan=0.0):
    """Heroic, piercing sky brass lead (high energy shmup rush)."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.025 * SAMPLE_RATE)
    fade_out = int(0.060 * SAMPLE_RATE)
    lp = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = math.sin(TWO_PI * 5.2 * t) * 0.0045 if t > 0.20 else 0.0
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.65 * math.sin(ph) + 0.35 * math.sin(2.0 * ph) + 0.18 * math.sin(3.0 * ph) + 0.10 * math.sin(4.0 * ph)
        lp += 0.45 * (raw - lp)
        sample = lp * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_sparkling_arp(buf, start_sec, dur_sec, freq, gain=0.12, pan=0.0):
    """High-speed sparkling 16th arpeggio (rushing wind & clouds)."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 9.0) * (1.0 - math.exp(-t * 300.0))
        sig = (math.sin(TWO_PI * freq * t) + 0.35 * math.sin(TWO_PI * freq * 2.0 * t)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_slap_drive_bass(buf, start_sec, dur_sec, freq, gain=0.24):
    """Punchy slap drive bass with octave thumb pop."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 6.5) * (1.0 - math.exp(-t * 400.0))
        sig = (0.70 * math.sin(TWO_PI * freq * t) +
               0.35 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 14.0) +
               0.15 * math.sin(TWO_PI * freq * 0.5 * t)) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_industrial_fm_bass(buf, start_sec, dur_sec, freq, gain=0.25):
    """Heavy industrial metallic FM bass for fortress."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 4.5) * (1.0 - math.exp(-t * 250.0))
        mod = math.sin(TWO_PI * freq * 3.5 * t) * 1.6 * math.exp(-t * 12.0)
        sig = math.sin(TWO_PI * freq * t + mod) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_heavy_snare(buf, start_sec, gain=0.26, prng=None):
    """Explosive rock/shmup snare with crisp crack."""
    if prng is None: prng = RandomPRNG()
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.24 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    lp = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        tone = math.sin(TWO_PI * 185.0 * math.exp(-t * 22.0) * t) * 0.4
        noise = prng.next_float()
        lp += 0.35 * (noise - lp)
        env = math.exp(-t * 16.0)
        sig = (tone + lp * 0.7) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_punch_kick(buf, start_sec, gain=0.32):
    """Deep solid punch kick."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.25 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        f = 135.0 * math.exp(-t * 28.0) + 42.0
        env = math.exp(-t * 7.5)
        sig = math.sin(TWO_PI * f * t) * env * gain
        buf.add_sample(start + n, sig, sig)


# =============================================================================
# STAGE 4 PLAN A: 分岐する空 〜 碧落の疾走 (Azure Gale)
# 165 BPM / E minor -> G Major / Uplifting High-Speed Shmup Drive
# =============================================================================

def render_stage04_plan_a():
    print("=== Rendering Stage 4 Plan A: 分岐する空 〜 碧落の疾走 (165 BPM Azure Gale) ===")
    bpm = 165.0
    beat = 60.0 / bpm
    sixteenth = beat / 4.0
    measure = beat * 4.0
    total_measures = 16
    total_sec = measure * total_measures + 2.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))
    prng = RandomPRNG(19870505)

    # Em -> C -> D -> Bm -> C -> Am -> B7 -> Em
    chords = [
        ["E3", "G3", "B3"],    # Em
        ["C3", "E3", "G3"],    # C
        ["D3", "F#3", "A3"],   # D
        ["B2", "D#3", "F#3"],  # Bm
        ["C3", "E3", "G3"],    # C
        ["A2", "C3", "E3"],    # Am
        ["B2", "D#3", "F#3", "A3"], # B7
        ["E3", "G3", "B3"],    # Em
        # Climax
        ["C3", "E3", "G3", "B3"],   # Cmaj7
        ["D3", "F#3", "A3", "C4"],  # D7
        ["G3", "B3", "D4"],         # G
        ["E3", "G3", "B3"],         # Em
        ["C3", "E3", "G3"],         # C
        ["D3", "F#3", "A3"],        # D
        ["E3", "G3", "B3", "E4"],   # Em
        ["E3", "B3", "E4", "G4"],   # Em power
    ]

    for m in range(total_measures):
        m_start = m * measure
        c_names = chords[m % len(chords)]

        # 1. High-speed 16th sparkling arpeggios
        for s in range(16):
            n_idx = (s * 3) % len(c_names)
            f = note_freq(c_names[n_idx]) * 2.0
            pan = -0.3 + 0.6 * ((s % 4) / 3.0)
            synth_sparkling_arp(buf, m_start + s * sixteenth, sixteenth * 1.5, f, gain=0.11, pan=pan)

        # 2. Driving 8th-note slap bass
        r_f = note_freq(c_names[0])
        for b in range(8):
            f_b = r_f if (b % 4 != 3) else r_f * 2.0 # Octave slap pop
            synth_slap_drive_bass(buf, m_start + b * (beat * 0.5), (beat * 0.5) * 0.9, f_b, gain=0.22)

        # 3. High-energy drums (Kick on 1 & 3, Snare on 2 & 4)
        synth_punch_kick(buf, m_start, gain=0.32)
        synth_heavy_snare(buf, m_start + beat, gain=0.26, prng=prng)
        synth_punch_kick(buf, m_start + beat * 2.0, gain=0.32)
        synth_heavy_snare(buf, m_start + beat * 3.0, gain=0.26, prng=prng)
        if m % 4 == 0:
            synth_heavy_snare(buf, m_start, gain=0.30, prng=prng)

    # Piercing Sky Brass Lead (Heroic, exhilarating shmup flight)
    lead_notes = [
        ("B4", 0.0, beat * 2.0), ("C5", beat * 2.0, beat * 1.0), ("D5", beat * 3.0, beat * 1.0),
        ("E5", measure * 1.0, beat * 2.5), ("D5", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("A4", measure * 2.0, beat * 2.0), ("B4", measure * 2.0 + beat * 2.0, beat * 2.0),
        ("G4", measure * 3.0, beat * 3.5),
        ("E5", measure * 4.0, beat * 2.0), ("F#5", measure * 4.0 + beat * 2.0, beat * 1.0), ("G5", measure * 4.0 + beat * 3.0, beat * 1.0),
        ("A5", measure * 5.0, beat * 2.5), ("G5", measure * 5.0 + beat * 2.5, beat * 1.5),
        ("F#5", measure * 6.0, beat * 3.0),
        ("E5", measure * 7.0, beat * 4.0),
        # Climax
        ("G5", measure * 8.0, beat * 2.0), ("A5", measure * 8.0 + beat * 2.0, beat * 1.0), ("B5", measure * 8.0 + beat * 3.0, beat * 1.0),
        ("A5", measure * 9.0, beat * 2.5), ("F#5", measure * 9.0 + beat * 2.5, beat * 1.5),
        ("G5", measure * 10.0, beat * 2.5), ("D5", measure * 10.0 + beat * 2.5, beat * 1.5),
        ("E5", measure * 11.0, beat * 3.5),
        ("C5", measure * 12.0, beat * 2.0), ("D5", measure * 12.0 + beat * 2.0, beat * 2.0),
        ("B4", measure * 13.0, beat * 2.0), ("D5", measure * 13.0 + beat * 2.0, beat * 2.0),
        ("E5", measure * 14.0, beat * 4.0),
        ("E5", measure * 15.0, beat * 4.0),
    ]
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_sky_brass_lead(buf, start_t, dur_t, f, gain=0.22, pan=0.0)

    buf.apply_snes_reverb(delay_sec=0.25, feedback=0.35, mix=0.30, damp=0.45)
    buf.write_wav("assets/audio/music/bgm_stage04_plan_a.wav")


# =============================================================================
# STAGE 4 PLAN B: 分岐する空 〜 乱気流のロンド (Turbulence Rondo)
# 158 BPM / A minor / Fast Triplet Air Combat
# =============================================================================

def render_stage04_plan_b():
    print("=== Rendering Stage 4 Plan B: 分岐する空 〜 乱気流のロンド (158 BPM Turbulence Rondo) ===")
    bpm = 158.0
    beat = 60.0 / bpm
    measure = beat * 4.0
    total_measures = 16
    total_sec = measure * total_measures + 2.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))
    prng = RandomPRNG(19870606)

    # Am -> F -> G -> Em -> F -> Dm -> E7 -> Am
    chords = [
        ["A2", "C3", "E3"],
        ["F2", "A2", "C3"],
        ["G2", "B2", "D3"],
        ["E2", "G2", "B2"],
        ["F2", "A2", "C3"],
        ["D2", "F2", "A2"],
        ["E2", "G#2", "B2"],
        ["A2", "C3", "E3"],
    ] * 2

    for m in range(total_measures):
        m_start = m * measure
        c_names = chords[m % len(chords)]
        # Triplet arpeggios (12 notes per measure)
        for t_step in range(12):
            f = note_freq(c_names[t_step % len(c_names)]) * 2.0
            synth_sparkling_arp(buf, m_start + t_step * (measure / 12.0), (measure / 12.0) * 1.2, f, gain=0.10, pan=-0.2 + 0.4 * (t_step % 2))
        # Gallop bass
        r_f = note_freq(c_names[0])
        for b in range(4):
            synth_slap_drive_bass(buf, m_start + b * beat, beat * 0.45, r_f, gain=0.22)
            synth_slap_drive_bass(buf, m_start + b * beat + beat * 0.5, beat * 0.45, r_f, gain=0.20)
        # Drums
        synth_punch_kick(buf, m_start, gain=0.30)
        synth_heavy_snare(buf, m_start + beat, gain=0.25, prng=prng)
        synth_punch_kick(buf, m_start + beat * 2.0, gain=0.30)
        synth_heavy_snare(buf, m_start + beat * 3.0, gain=0.25, prng=prng)

    lead_notes = [
        ("E5", 0.0, beat * 2.0), ("F5", beat * 2.0, beat * 1.0), ("G5", beat * 3.0, beat * 1.0),
        ("A5", measure * 1.0, beat * 2.5), ("G5", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("D5", measure * 2.0, beat * 2.0), ("E5", measure * 2.0 + beat * 2.0, beat * 2.0),
        ("C5", measure * 3.0, beat * 3.5),
        ("F5", measure * 4.0, beat * 2.0), ("G5", measure * 4.0 + beat * 2.0, beat * 1.0), ("A5", measure * 4.0 + beat * 3.0, beat * 1.0),
        ("B5", measure * 5.0, beat * 2.5), ("A5", measure * 5.0 + beat * 2.5, beat * 1.5),
        ("G#5", measure * 6.0, beat * 3.0),
        ("A5", measure * 7.0, beat * 4.0),
    ] * 2
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_sky_brass_lead(buf, start_t, dur_t, f, gain=0.22, pan=0.0)

    buf.apply_snes_reverb(delay_sec=0.26, feedback=0.35, mix=0.30, damp=0.45)
    buf.write_wav("assets/audio/music/bgm_stage04_plan_b.wav")


# =============================================================================
# STAGE 5 PLAN A: 忘却の要塞 〜 鋼鉄の残影 (Iron Echoes)
# 148 BPM / C minor / Heavy Industrial FM Assault & Thrilling Drive
# =============================================================================

def render_stage05_plan_a():
    print("=== Rendering Stage 5 Plan A: 忘却の要塞 〜 鋼鉄の残影 (148 BPM Iron Echoes) ===")
    bpm = 148.0
    beat = 60.0 / bpm
    measure = beat * 4.0
    total_measures = 16
    total_sec = measure * total_measures + 2.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))
    prng = RandomPRNG(19880707)

    # Cm -> Ab -> Fm -> G7 -> Cm -> Eb -> Bb -> G
    chords = [
        ["C2", "Eb2", "G2", "C3"],
        ["Ab1", "C2", "Eb2", "Ab2"],
        ["F1", "Ab1", "C2", "F2"],
        ["G1", "B1", "D2", "G2"],
        ["C2", "Eb2", "G2", "C3"],
        ["Eb2", "G2", "Bb2", "Eb3"],
        ["Bb1", "D2", "F2", "Bb2"],
        ["G1", "B1", "D2", "G2"],
    ] * 2

    for m in range(total_measures):
        m_start = m * measure
        c_names = chords[m % len(chords)]

        # Heavy Industrial FM Bass (16th syncopated mechanical crunch)
        r_f = note_freq(c_names[0])
        for s in [0, 2, 3, 6, 8, 10, 12, 14]:
            synth_industrial_fm_bass(buf, m_start + s * (beat * 0.25), beat * 0.22, r_f, gain=0.25)

        # Industrial mechanical drums
        synth_punch_kick(buf, m_start, gain=0.34)
        synth_heavy_snare(buf, m_start + beat, gain=0.28, prng=prng)
        synth_punch_kick(buf, m_start + beat * 1.75, gain=0.30)
        synth_punch_kick(buf, m_start + beat * 2.0, gain=0.34)
        synth_heavy_snare(buf, m_start + beat * 3.0, gain=0.28, prng=prng)

    # Aggressive FM Metallic Lead
    lead_notes = [
        ("C5", 0.0, beat * 1.5), ("Eb5", beat * 1.5, beat * 1.0), ("G5", beat * 2.5, beat * 1.5),
        ("Ab5", measure * 1.0, beat * 2.5), ("G5", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("F5", measure * 2.0, beat * 2.0), ("D5", measure * 2.0 + beat * 2.0, beat * 2.0),
        ("Eb5", measure * 3.0, beat * 3.5),
        ("C5", measure * 4.0, beat * 1.5), ("G5", measure * 4.0 + beat * 1.5, beat * 1.5), ("Bb5", measure * 4.0 + beat * 3.0, beat * 1.0),
        ("C6", measure * 5.0, beat * 2.5), ("Bb5", measure * 5.0 + beat * 2.5, beat * 1.5),
        ("Ab5", measure * 6.0, beat * 2.0), ("G5", measure * 6.0 + beat * 2.0, beat * 2.0),
        ("G5", measure * 7.0, beat * 4.0),
    ] * 2
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_sky_brass_lead(buf, start_t, dur_t, f, gain=0.22, pan=0.1)

    buf.apply_snes_reverb(delay_sec=0.24, feedback=0.38, mix=0.30, damp=0.50)
    buf.write_wav("assets/audio/music/bgm_stage05_plan_a.wav")


# =============================================================================
# STAGE 5 PLAN B: 忘却の要塞 〜 機械仕掛けの記憶 (Clockwork Citadel)
# 152 BPM / D minor / Cold Technological Requiem
# =============================================================================

def render_stage05_plan_b():
    print("=== Rendering Stage 5 Plan B: 忘却の要塞 〜 機械仕掛けの記憶 (152 BPM Clockwork Citadel) ===")
    bpm = 152.0
    beat = 60.0 / bpm
    measure = beat * 4.0
    total_measures = 16
    total_sec = measure * total_measures + 2.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))
    prng = RandomPRNG(19880808)

    chords = [
        ["D2", "F2", "A2"],
        ["Bb1", "D2", "F2"],
        ["C2", "E2", "G2"],
        ["A1", "C#2", "E2"],
    ] * 4

    for m in range(total_measures):
        m_start = m * measure
        c_names = chords[m % len(chords)]
        r_f = note_freq(c_names[0])

        for s in range(16):
            synth_industrial_fm_bass(buf, m_start + s * (beat * 0.25), beat * 0.20, r_f, gain=0.22)

        synth_punch_kick(buf, m_start, gain=0.32)
        synth_heavy_snare(buf, m_start + beat, gain=0.26, prng=prng)
        synth_punch_kick(buf, m_start + beat * 2.0, gain=0.32)
        synth_heavy_snare(buf, m_start + beat * 3.0, gain=0.26, prng=prng)

    lead_notes = [
        ("D5", 0.0, beat * 2.0), ("A5", beat * 2.0, beat * 2.0),
        ("F5", measure * 1.0, beat * 2.0), ("G5", measure * 1.0 + beat * 2.0, beat * 2.0),
        ("E5", measure * 2.0, beat * 3.0),
        ("C#5", measure * 3.0, beat * 4.0),
    ] * 4
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_sky_brass_lead(buf, start_t, dur_t, f, gain=0.22, pan=0.0)

    buf.apply_snes_reverb(delay_sec=0.24, feedback=0.36, mix=0.28, damp=0.45)
    buf.write_wav("assets/audio/music/bgm_stage05_plan_b.wav")


def main():
    print("=================================================================")
    print(" Mw-fActory: Stage 4 & Stage 5 High-Speed Thrilling BGM Generator")
    print("=================================================================")
    render_stage04_plan_a()
    render_stage04_plan_b()
    render_stage05_plan_a()
    render_stage05_plan_b()
    print("All Stage 4 & 5 tracks successfully generated!")

if __name__ == "__main__":
    main()

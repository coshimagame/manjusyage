#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Super Famicom Multi-Timbral Stage Variation Engine

Completely diversifies the instrumental palette and musical genre across stages:
- STAGE 02 (追憶の海 / Ocean):
    Plan A: 6/8 Rolling Ocean Ballad — Vibraphone, Rhodes Electric Piano, Nylon Guitar Arpeggio, Water Drops, Soft Brush
    Plan B: Aquatic Ambient Groove — Watery Chorused Lead, Marimba, Oceanic Sub-Pad, Bubbles
- STAGE 03 (孤独な庭・廃墟 / Ruins & Garden):
    Plan A: 3/4 Baroque Clockwork Waltz — Antique Music Box (オルゴール), Classical Guitar, Harpsichord, Clock Ticks
    Plan B: Solitary Ruins Requiem — Plucked Nylon Guitar, Church Bell, Gothic Cathedral Organ, Solitary Cello
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

    def apply_snes_reverb(self, delay_sec=0.28, feedback=0.35, mix=0.32, damp=0.45):
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

        target_peak = 0.891  # -1.0 dBFS
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
# NEW DIVERSE SFC INSTRUMENTS
# =============================================================================

def synth_rhodes_ep(buf, start_sec, dur_sec, freq, gain=0.18, pan=0.0):
    """SFC Rhodes Electric Piano / Tine Piano.
    Bell strike + warm electric reed body + gentle stereo tremolo.
    """
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        # Envelope: initial key click + bell decay + body sustain
        tine_env = math.exp(-t * 14.0)
        body_env = math.exp(-t * 1.8) * (1.0 - math.exp(-t * 200.0))
        
        # FM Tine component (inharmonic bell)
        mod = math.sin(TWO_PI * freq * 4.02 * t) * tine_env * 1.8
        carrier = math.sin(TWO_PI * freq * t + mod)
        
        # Warm 2nd harmonic
        warmth = 0.35 * math.sin(TWO_PI * freq * 2.0 * t) * body_env
        sig = (carrier * 0.70 + warmth) * body_env * gain
        
        # Gentle stereo tremolo (LFO 4.5Hz)
        trem = 1.0 + 0.18 * math.sin(TWO_PI * 4.5 * t)
        p = max(-1.0, min(1.0, pan + 0.22 * math.cos(TWO_PI * 4.5 * t)))
        theta = (p + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * trem * math.cos(theta), sig * trem * math.sin(theta))

def synth_vibraphone(buf, start_sec, dur_sec, freq, gain=0.20, pan=0.1):
    """SFC Glassy Vibraphone with motor tremolo."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        # Mallet click + bar resonance (fundamental + 4th harmonic)
        env = math.exp(-t * 2.2) * (1.0 - math.exp(-t * 300.0))
        overtone = 0.30 * math.sin(TWO_PI * freq * 3.98 * t) * math.exp(-t * 12.0)
        fund = math.sin(TWO_PI * freq * t)
        
        # Motor vibrato (5.5 Hz)
        motor = 1.0 + 0.25 * math.sin(TWO_PI * 5.5 * t) if t > 0.1 else 1.0
        sig = (fund + overtone) * env * motor * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_marimba(buf, start_sec, dur_sec, freq, gain=0.18, pan=-0.15):
    """SFC Warm Wooden Marimba."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        # Woody transient
        wood_click = math.sin(TWO_PI * freq * 3.0 * t) * math.exp(-t * 35.0) * 0.4
        env = math.exp(-t * 5.5) * (1.0 - math.exp(-t * 500.0))
        fund = math.sin(TWO_PI * freq * t)
        sig = (fund + wood_click) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_music_box(buf, start_sec, freq, gain=0.16, pan=0.2):
    """SFC Antique Music Box (オルゴール / Celesta).
    Crystal metal tines with shimmering high harmonics.
    """
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(1.8 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 3.8)
        # Inharmonic partials characteristic of metal tines
        p1 = math.sin(TWO_PI * freq * t)
        p2 = 0.45 * math.sin(TWO_PI * freq * 2.76 * t) * math.exp(-t * 6.0)
        p3 = 0.20 * math.sin(TWO_PI * freq * 5.40 * t) * math.exp(-t * 12.0)
        sig = (p1 + p2 + p3) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_classical_guitar(buf, start_sec, dur_sec, freq, gain=0.16, pan=-0.2):
    """SFC Nylon Classical Guitar (Fingerstyle pluck).
    Warm wooden pluck with damped high harmonics.
    """
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        # Pluck transient
        env = math.exp(-t * 3.2) * (1.0 - math.exp(-t * 400.0))
        # String harmonics with progressive damping
        h1 = math.sin(TWO_PI * freq * t)
        h2 = 0.50 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 5.0)
        h3 = 0.25 * math.sin(TWO_PI * freq * 3.0 * t) * math.exp(-t * 9.0)
        h4 = 0.12 * math.sin(TWO_PI * freq * 4.0 * t) * math.exp(-t * 16.0)
        # Body resonance around 210Hz
        body = 0.15 * math.sin(TWO_PI * 210.0 * t) * math.exp(-t * 4.0)
        sig = (h1 + h2 + h3 + h4 + body) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_harpsichord(buf, start_sec, dur_sec, freq, gain=0.12, pan=0.25):
    """SFC Baroque Harpsichord (チェンバロ).
    Crisp quill plectrum pluck with rich bright timbre.
    """
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 5.0)
        # Pulse-like plucked timbre (odd + even harmonics)
        ph = TWO_PI * freq * t
        sig = (math.sin(ph) + 0.65 * math.sin(2.0 * ph) + 0.45 * math.sin(3.0 * ph) +
               0.30 * math.sin(4.0 * ph) + 0.20 * math.sin(5.0 * ph)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_pipe_organ(buf, start_sec, dur_sec, chord_freqs, gain=0.09, pan_spread=0.35):
    """SFC Gothic Cathedral Pipe Organ.
    Majestic mixture of 8' principal, 4' octave, and 2' superoctave.
    """
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.08 * SAMPLE_RATE)
    fade_out = int(0.12 * SAMPLE_RATE)

    for i, freq in enumerate(chord_freqs):
        if freq <= 0: continue
        pan = -pan_spread + (2.0 * pan_spread * i / max(1, len(chord_freqs) - 1))
        theta = (pan + 1.0) * math.pi / 4.0

        for n in range(count):
            t = n / SAMPLE_RATE
            env = 1.0
            if n < fade_in: env = n / fade_in
            elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

            ph = TWO_PI * freq * t
            # Organ pipe ranks: 8' (1.0x), 4' (2.0x), 2' (4.0x) + slight wind breath
            rank8 = math.sin(ph)
            rank4 = 0.50 * math.sin(2.0 * ph)
            rank2 = 0.25 * math.sin(4.0 * ph)
            rank5th = 0.18 * math.sin(3.0 * ph)
            sample = (rank8 + rank4 + rank2 + rank5th) * env * gain
            buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_church_bell(buf, start_sec, freq=330.0, gain=0.22, pan=0.0):
    """SFC Gothic Church Bell Toll for Ruins."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(3.2 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 1.4)
        # Bell acoustics: hum tone (0.5x), prime (1.0x), tierce (1.2x), quint (1.5x), nominal (2.0x)
        b0 = 0.40 * math.sin(TWO_PI * freq * 0.5 * t) * math.exp(-t * 0.9)
        b1 = 0.70 * math.sin(TWO_PI * freq * 1.0 * t)
        b2 = 0.50 * math.sin(TWO_PI * freq * 1.2 * t) * math.exp(-t * 1.8)
        b3 = 0.35 * math.sin(TWO_PI * freq * 1.5 * t) * math.exp(-t * 2.2)
        b4 = 0.30 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 3.0)
        b5 = 0.15 * math.sin(TWO_PI * freq * 2.76 * t) * math.exp(-t * 4.5)
        sig = (b0 + b1 + b2 + b3 + b4 + b5) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_clock_tick(buf, start_sec, kind="tick", gain=0.10, pan=-0.2):
    """Antique escapement clock tick-tock for ruins/gears."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.045 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    f_wood = 1850.0 if kind == "tick" else 1320.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 140.0)
        click = (math.sin(TWO_PI * f_wood * t) + 0.3 * math.sin(TWO_PI * f_wood * 2.1 * t)) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, click * math.cos(theta), click * math.sin(theta))

def synth_ocean_brush(buf, start_sec, kind="brush", gain=0.20, prng=None):
    """Soft ocean percussion: brush snare, deep sub kick, conga, wave splash."""
    if prng is None: prng = RandomPRNG()
    start = int(start_sec * SAMPLE_RATE)
    dur = 0.18 if kind == "brush" else (0.28 if kind == "sub_kick" else 0.45)
    count = min(int(dur * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    if kind == "brush":
        # Soft brushed snare (filtered white noise with smooth ramp)
        lp = 0.0
        for n in range(count):
            t = n / SAMPLE_RATE
            env = math.exp(-t * 18.0) * (1.0 - math.exp(-t * 150.0))
            noise = prng.next_float()
            lp += 0.20 * (noise - lp)
            sig = lp * env * gain
            buf.add_sample(start + n, sig, sig)

    elif kind == "sub_kick":
        # Deep gentle round kick (like deep water pulse)
        for n in range(count):
            t = n / SAMPLE_RATE
            f = 110.0 * math.exp(-t * 22.0) + 42.0
            env = math.exp(-t * 7.0)
            sig = math.sin(TWO_PI * f * t) * env * gain * 1.3
            buf.add_sample(start + n, sig, sig)

    elif kind == "conga":
        # Muted conga / bongo tap
        for n in range(count):
            t = n / SAMPLE_RATE
            f = 240.0 * math.exp(-t * 30.0) + 160.0
            env = math.exp(-t * 14.0)
            sig = math.sin(TWO_PI * f * t) * env * gain
            buf.add_sample(start + n, sig * 0.7, sig * 1.1)

    elif kind == "splash":
        # Gentle wave splash / ocean wash
        lp = 0.0
        for n in range(count):
            t = n / SAMPLE_RATE
            env = math.exp(-t * 3.5) * (1.0 - math.exp(-t * 40.0))
            noise = prng.next_float()
            lp += 0.15 * (noise - lp)
            sig = lp * env * gain * 0.6
            buf.add_sample(start + n, sig * 1.1, sig * 0.8)

def synth_water_bubble(buf, start_sec, freq=680.0, gain=0.12, pan=0.25):
    """Water bubble drop sound."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(0.16 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        # Upward chirp
        f = freq * (1.0 + 1.4 * math.exp(-t * 35.0))
        env = math.exp(-t * 24.0)
        sig = math.sin(TWO_PI * f * t) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_fretless_ocean_bass(buf, start_sec, dur_sec, freq, gain=0.22):
    """Muted warm deep ocean bass (round, no harsh click)."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 2.8) * (1.0 - math.exp(-t * 120.0))
        sig = (0.85 * math.sin(TWO_PI * freq * t) +
               0.25 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 8.0) +
               0.15 * math.sin(TWO_PI * freq * 0.5 * t)) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_oceanic_pad(buf, start_sec, dur_sec, chord_freqs, gain=0.08, pan_spread=0.45):
    """Deep floating oceanic ambient pad."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.25 * SAMPLE_RATE)
    fade_out = int(0.28 * SAMPLE_RATE)

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
            w2 = math.sin(TWO_PI * freq * 1.003 * t)
            sub = 0.20 * math.sin(TWO_PI * freq * 0.5 * t)
            sample = (w1 * 0.45 + w2 * 0.40 + sub) * env * gain
            buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_solitary_cello(buf, start_sec, dur_sec, freq, gain=0.14, pan=-0.25):
    """Warm expressive solo cello for ruins."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.08 * SAMPLE_RATE)
    fade_out = int(0.12 * SAMPLE_RATE)
    lp_val = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = math.sin(TWO_PI * 4.6 * t) * 0.0040 if t > 0.25 else 0.0
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.70 * math.sin(ph) + 0.30 * math.sin(2.0 * ph) + 0.12 * math.sin(3.0 * ph)
        lp_val += 0.28 * (raw - lp_val)
        sample = lp_val * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))


# =============================================================================
# STAGE 2 PLAN A: 追憶の海「水底の残照」(Subaquatic Afterglow)
# 6/8 Rolling Ocean Ballad / Vibraphone & Rhodes EP / Soft Brushes & Bubbles
# =============================================================================

def render_stage02_plan_a():
    print("=== Rendering Stage 2 Plan A: 水底の残照 (6/8 Rolling Ocean Vibraphone & Rhodes) ===")
    bpm = 108.0
    beat = 60.0 / bpm          # quarter note = ~0.555s
    eighth = beat / 2.0        # eighth note in 6/8 = ~0.277s
    measure = eighth * 6.0     # 6 eighth notes per measure (~1.666s)
    total_measures = 16
    total_sec = measure * total_measures + 2.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))
    prng = RandomPRNG(20261102)

    # Chord progression: Ebmaj7 -> Cm7 -> Fm7 -> Bb7sus4 -> Gm7 -> Abmaj7 -> Fm9 -> Bb7
    chords = [
        ["Eb3", "G3", "Bb3", "D4"],   # Ebmaj7
        ["C3", "Eb3", "G3", "Bb3"],   # Cm7
        ["F3", "Ab3", "C4", "Eb4"],   # Fm7
        ["Bb2", "F3", "Ab3", "Eb4"],  # Bb7sus4
        ["G3", "Bb3", "D4", "F4"],    # Gm7
        ["Ab3", "C4", "Eb4", "G4"],   # Abmaj7
        ["F3", "Ab3", "C4", "G4"],    # Fm9
        ["Bb2", "D3", "F3", "Ab3"],   # Bb7
        # Loop repeat with emotional elevation
        ["Eb3", "G3", "Bb3", "D4"],
        ["C3", "Eb3", "G3", "D4"],    # Cm9
        ["Ab3", "C4", "Eb4", "G4"],   # Abmaj7
        ["Bb3", "D4", "F4", "Ab4"],   # Bb7
        ["G3", "Bb3", "D4", "G4"],   # Gm
        ["C3", "E3", "G3", "Bb3"],    # C7
        ["F3", "Ab3", "C4", "Eb4"],   # Fm7
        ["Bb2", "F3", "Ab3", "D4"],   # Bb7
    ]

    # 1. Rhodes Electric Piano Chords (Gentle tremolo rolling chords)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names]
        m_start = m * measure
        for i, freq in enumerate(c_freqs):
            # Arpeggiated chord entrance
            synth_rhodes_ep(buf, m_start + i * 0.04, measure * 0.95, freq, gain=0.15, pan=-0.2 + i * 0.12)

    # 2. Oceanic Pad Background (Submerged ambient wash)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names]
        synth_oceanic_pad(buf, m * measure, measure, c_freqs, gain=0.07)

    # 3. Rolling Nylon Guitar Arpeggios (6/8 flowing waves)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        # 6 eighth notes per measure
        pattern = [0, 1, 2, 3, 2, 1]
        for step in range(6):
            n_idx = pattern[step] % len(c_names)
            f = note_freq(c_names[n_idx])
            synth_classical_guitar(buf, m_start + step * eighth, eighth * 1.5, f * 2.0, gain=0.11, pan=-0.25)

    # 4. Deep Muted Ocean Bass (Gentle rolling 6/8 pulse on beats 1 and 4)
    bass_roots = ["Eb2", "C2", "F2", "Bb1", "G2", "Ab2", "F2", "Bb1",
                  "Eb2", "C2", "Ab2", "Bb1", "G2", "C2", "F2", "Bb1"]
    for m in range(total_measures):
        m_start = m * measure
        r_freq = note_freq(bass_roots[m])
        # Beat 1 (accent)
        synth_fretless_ocean_bass(buf, m_start, eighth * 2.8, r_freq, gain=0.24)
        # Beat 4 (gentle bounce)
        synth_fretless_ocean_bass(buf, m_start + eighth * 3.0, eighth * 2.6, r_freq * 1.5, gain=0.16)

    # 5. Vibraphone Glassy Lead (SFC Water Palace style nostalgic melody)
    # 6/8 lyrical phrasing
    lead_notes = [
        # Measure 0-1: Ebmaj7 -> Cm7
        ("G4", 0.0, eighth * 2.5), ("Bb4", eighth * 3.0, eighth * 1.5), ("D5", eighth * 4.5, eighth * 1.5),
        ("C5", measure * 1.0, eighth * 4.0), ("G4", measure * 1.0 + eighth * 4.5, eighth * 1.5),
        # Measure 2-3: Fm7 -> Bb7sus4
        ("Ab4", measure * 2.0, eighth * 2.5), ("C5", measure * 2.0 + eighth * 3.0, eighth * 1.5), ("Eb5", measure * 2.0 + eighth * 4.5, eighth * 1.5),
        ("D5", measure * 3.0, eighth * 4.0), ("REST", measure * 3.0 + eighth * 4.5, eighth * 1.5),
        # Measure 4-5: Gm7 -> Abmaj7
        ("Bb4", measure * 4.0, eighth * 2.5), ("D5", measure * 4.0 + eighth * 3.0, eighth * 1.5), ("F5", measure * 4.0 + eighth * 4.5, eighth * 1.5),
        ("Eb5", measure * 5.0, eighth * 3.0), ("D5", measure * 5.0 + eighth * 3.5, eighth * 1.2), ("C5", measure * 5.0 + eighth * 4.8, eighth * 1.2),
        # Measure 6-7: Fm9 -> Bb7
        ("G4", measure * 6.0, eighth * 3.5), ("Ab4", measure * 6.0 + eighth * 4.0, eighth * 2.0),
        ("Bb4", measure * 7.0, eighth * 4.5), ("REST", measure * 7.0 + eighth * 4.5, eighth * 1.5),
        # Measure 8-9: High Climax (Ebmaj7 -> Cm9)
        ("G5", measure * 8.0, eighth * 3.0), ("F5", measure * 8.0 + eighth * 3.5, eighth * 1.2), ("Eb5", measure * 8.0 + eighth * 4.8, eighth * 1.2),
        ("D5", measure * 9.0, eighth * 2.5), ("C5", measure * 9.0 + eighth * 3.0, eighth * 3.0),
        # Measure 10-11: Abmaj7 -> Bb7
        ("C5", measure * 10.0, eighth * 2.0), ("Eb5", measure * 10.0 + eighth * 2.5, eighth * 2.0), ("G5", measure * 10.0 + eighth * 4.5, eighth * 1.5),
        ("F5", measure * 11.0, eighth * 4.5),
        # Measure 12-13: Gm -> C7
        ("D5", measure * 12.0, eighth * 2.5), ("Bb4", measure * 12.0 + eighth * 3.0, eighth * 3.0),
        ("E5", measure * 13.0, eighth * 3.0), ("G5", measure * 13.0 + eighth * 3.5, eighth * 2.5),
        # Measure 14-15: Fm7 -> Bb7 -> Resolution
        ("F5", measure * 14.0, eighth * 2.5), ("Eb5", measure * 14.0 + eighth * 3.0, eighth * 1.5), ("D5", measure * 14.0 + eighth * 4.5, eighth * 1.5),
        ("Eb5", measure * 15.0, eighth * 5.5),
    ]
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_vibraphone(buf, start_t, dur_t, f, gain=0.22, pan=0.1)

    # 6. Soft Ocean Percussion (Sub-kick on 1, Brush on 4, Conga fills, Splash wash)
    for m in range(total_measures):
        m_start = m * measure
        # Beat 1: gentle sub kick
        synth_ocean_brush(buf, m_start, kind="sub_kick", gain=0.22, prng=prng)
        # Beat 4: soft brush snare
        synth_ocean_brush(buf, m_start + eighth * 3.0, kind="brush", gain=0.18, prng=prng)
        # Conga syncopations
        synth_ocean_brush(buf, m_start + eighth * 2.0, kind="conga", gain=0.12, prng=prng)
        synth_ocean_brush(buf, m_start + eighth * 5.0, kind="conga", gain=0.14, prng=prng)

        # Ambient Water Bubbles
        if m % 2 == 0:
            synth_water_bubble(buf, m_start + eighth * 1.5, freq=720.0, gain=0.11, pan=0.3)
        if m % 3 == 0:
            synth_water_bubble(buf, m_start + eighth * 4.2, freq=580.0, gain=0.12, pan=-0.3)
        if m % 4 == 0:
            synth_ocean_brush(buf, m_start, kind="splash", gain=0.15, prng=prng)

    buf.apply_snes_reverb(delay_sec=0.32, feedback=0.40, mix=0.35, damp=0.40)
    buf.write_wav("assets/audio/music/bgm_stage02_plan_a.wav")


# =============================================================================
# STAGE 2 PLAN B: 追憶の海「潮流のセレナーデ」(Current Serenade)
# 120 BPM Aquatic Groove / Marimba & Chorused E.Piano / Bubbles & Deep Sub
# =============================================================================

def render_stage02_plan_b():
    print("=== Rendering Stage 2 Plan B: 潮流のセレナーデ (Marimba & Aquatic E.Piano Groove) ===")
    bpm = 120.0
    beat = 60.0 / bpm
    sixteenth = beat / 4.0
    measure = beat * 4.0
    total_measures = 16
    total_sec = measure * total_measures + 2.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))
    prng = RandomPRNG(20261103)

    # Gm7 -> C9 -> Fmaj7 -> Bbmaj7 -> Em7b5 -> A7 -> Dm7 -> D7
    chords = [
        ["G3", "Bb3", "D4", "F4"],     # Gm7
        ["C3", "E3", "G3", "Bb3", "D4"], # C9
        ["F3", "A3", "C4", "E4"],      # Fmaj7
        ["Bb3", "D4", "F4", "A4"],     # Bbmaj7
        ["E3", "G3", "Bb3", "D4"],     # Em7b5
        ["A3", "C#4", "E4", "G4"],     # A7
        ["D3", "F3", "A3", "C4"],      # Dm7
        ["D3", "F#3", "A3", "C4"],     # D7
        # Repeat with climax
        ["G3", "Bb3", "D4", "F4"],
        ["C3", "E3", "G3", "Bb3", "D4"],
        ["F3", "A3", "C4", "E4"],
        ["Bb3", "D4", "F4", "A4"],
        ["Eb3", "G3", "Bb3", "D4"],    # Ebmaj7
        ["A3", "C#4", "E4", "G4"],     # A7
        ["D3", "F3", "A3", "D4"],      # Dm
        ["D3", "A3", "D4", "F#4"],     # D major Picardy third
    ]

    # 1. Marimba 16th Arpeggiator (Rippling water current)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        for step in range(16):
            n_idx = (step * 2) % len(c_names)
            f = note_freq(c_names[n_idx])
            pan = -0.3 if (step % 2 == 0) else 0.3
            synth_marimba(buf, m_start + step * sixteenth, sixteenth * 1.2, f * 2.0, gain=0.13, pan=pan)

    # 2. Oceanic Pad Wash
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names[:4]]
        synth_oceanic_pad(buf, m * measure, measure, c_freqs, gain=0.08)

    # 3. Rhodes Electric Piano Counterchords (Offbeat syncopations)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names[:4]]
        m_start = m * measure
        for step in [2, 6, 10, 14]: # Offbeat 8ths
            for freq in c_freqs:
                synth_rhodes_ep(buf, m_start + step * sixteenth, sixteenth * 3.0, freq, gain=0.12, pan=0.1)

    # 4. Deep Oceanic Bass
    bass_roots = ["G2", "C2", "F2", "Bb1", "E2", "A1", "D2", "D2",
                  "G2", "C2", "F2", "Bb1", "Eb2", "A1", "D2", "D2"]
    for m in range(total_measures):
        m_start = m * measure
        r_f = note_freq(bass_roots[m])
        # Syncopated ocean groove: beat 1, beat 2-and, beat 4
        synth_fretless_ocean_bass(buf, m_start, beat * 0.9, r_f, gain=0.24)
        synth_fretless_ocean_bass(buf, m_start + beat * 1.5, beat * 0.8, r_f * 1.5, gain=0.18)
        synth_fretless_ocean_bass(buf, m_start + beat * 3.0, beat * 0.9, r_f, gain=0.22)

    # 5. Vibraphone Floating Melody
    lead_notes = [
        ("D5", 0.0, beat * 2.5), ("C5", beat * 2.5, beat * 0.5), ("Bb4", beat * 3.0, beat * 1.0),
        ("A4", measure * 1.0, beat * 2.5), ("G4", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("C5", measure * 2.0, beat * 2.5), ("A4", measure * 2.0 + beat * 2.5, beat * 1.5),
        ("F4", measure * 3.0, beat * 3.5),
        ("G4", measure * 4.0, beat * 2.0), ("Bb4", measure * 4.0 + beat * 2.0, beat * 2.0),
        ("A4", measure * 5.0, beat * 2.0), ("C#5", measure * 5.0 + beat * 2.0, beat * 2.0),
        ("D5", measure * 6.0, beat * 3.5),
        ("REST", measure * 7.0, beat * 4.0),
        # Second half: Higher register
        ("F5", measure * 8.0, beat * 2.0), ("E5", measure * 8.0 + beat * 2.0, beat * 1.0), ("D5", measure * 8.0 + beat * 3.0, beat * 1.0),
        ("G5", measure * 9.0, beat * 3.0), ("E5", measure * 9.0 + beat * 3.0, beat * 1.0),
        ("A5", measure * 10.0, beat * 2.5), ("F5", measure * 10.0 + beat * 2.5, beat * 1.5),
        ("D5", measure * 11.0, beat * 3.5),
        ("Eb5", measure * 12.0, beat * 2.0), ("G5", measure * 12.0 + beat * 2.0, beat * 2.0),
        ("E5", measure * 13.0, beat * 2.0), ("A4", measure * 13.0 + beat * 2.0, beat * 2.0),
        ("D5", measure * 14.0, beat * 4.0),
        ("F#5", measure * 15.0, beat * 4.0),
    ]
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_vibraphone(buf, start_t, dur_t, f, gain=0.22, pan=-0.1)

    # 6. Percussion (Sub-kick, brush snare, bubbles)
    for m in range(total_measures):
        m_start = m * measure
        synth_ocean_brush(buf, m_start, kind="sub_kick", gain=0.24, prng=prng)
        synth_ocean_brush(buf, m_start + beat * 2.0, kind="brush", gain=0.18, prng=prng)
        synth_ocean_brush(buf, m_start + beat * 2.5, kind="sub_kick", gain=0.18, prng=prng)
        synth_ocean_brush(buf, m_start + beat * 3.0, kind="brush", gain=0.18, prng=prng)

        # Bubble chirps
        synth_water_bubble(buf, m_start + sixteenth * 7, freq=640.0, gain=0.12, pan=0.25)
        synth_water_bubble(buf, m_start + sixteenth * 13, freq=780.0, gain=0.12, pan=-0.25)

    buf.apply_snes_reverb(delay_sec=0.26, feedback=0.38, mix=0.32, damp=0.45)
    buf.write_wav("assets/audio/music/bgm_stage02_plan_b.wav")


# =============================================================================
# STAGE 3 PLAN A: 孤独な庭「錆びた歯車と曼珠沙華」(Rusted Gears & Spider Lilies)
# 3/4 Baroque Clockwork Waltz / Antique Music Box & Classical Guitar / Harpsichord
# =============================================================================

def render_stage03_plan_a():
    print("=== Rendering Stage 3 Plan A: 錆びた歯車と曼珠沙華 (3/4 Baroque Clockwork Waltz / Music Box) ===")
    bpm = 126.0
    beat = 60.0 / bpm          # quarter note = ~0.476s
    measure = beat * 3.0       # 3 beats per measure (3/4 waltz)
    total_measures = 16
    total_sec = measure * total_measures + 2.5
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))

    # Gothic Japanese Minor Progression (Gm -> Eb -> D7 -> Gm -> Cm -> F7 -> Bb -> D7)
    chords = [
        ["G3", "Bb3", "D4"],   # Gm
        ["Eb3", "G3", "Bb3"],  # Eb
        ["D3", "F#3", "A3", "C4"], # D7
        ["G3", "Bb3", "D4"],   # Gm
        ["C3", "Eb3", "G3"],   # Cm
        ["F3", "A3", "C4"],    # F
        ["Bb3", "D4", "F4"],   # Bb
        ["D3", "F#3", "A3"],   # D
        # Second half: Melancholy climax
        ["Eb3", "G3", "Bb3"],  # Eb
        ["F3", "A3", "C4"],    # F
        ["D3", "F#3", "A3"],   # D
        ["G3", "Bb3", "D4"],   # Gm
        ["C3", "Eb3", "G3"],  # Cm
        ["D3", "F#3", "A3", "C4"], # D7
        ["G3", "Bb3", "D4"],   # Gm
        ["G2", "D3", "G3", "B3"], # G major Picardy tierce resolution
    ]

    # 1. Antique Clockwork Pendulum Ticks (Beats 1, 2, 3 - Tick Tock Tick Tock)
    for m in range(total_measures):
        m_start = m * measure
        synth_clock_tick(buf, m_start, kind="tick", gain=0.10, pan=-0.25)
        synth_clock_tick(buf, m_start + beat, kind="tock", gain=0.08, pan=-0.15)
        synth_clock_tick(buf, m_start + beat * 2.0, kind="tick", gain=0.09, pan=-0.20)

    # 2. Classical Nylon Guitar Plucked Waltz (Bass on 1, Chords on 2 and 3)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        # Beat 1: Plucked bass root
        root_f = note_freq(c_names[0]) * 0.5
        synth_classical_guitar(buf, m_start, beat * 1.8, root_f, gain=0.20, pan=-0.2)
        # Beats 2 & 3: Plucked guitar chords
        for b in [1, 2]:
            for n_str in c_names[1:]:
                synth_classical_guitar(buf, m_start + b * beat, beat * 0.9, note_freq(n_str), gain=0.12, pan=-0.15)

    # 3. Baroque Harpsichord (チェンバロ) Counterpoint
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        # Harpsichord flourishes on beats 2 and 3
        if m % 2 == 1:
            for step, n_str in enumerate(c_names):
                f = note_freq(n_str) * 2.0
                synth_harpsichord(buf, m_start + beat + step * (beat * 0.4), beat * 0.5, f, gain=0.11, pan=0.25)

    # 4. Gothic Pipe Organ (Background sacred pedal tones)
    for m in range(0, total_measures, 2):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names]
        synth_pipe_organ(buf, m * measure, measure * 2.0, c_freqs, gain=0.07, pan_spread=0.3)

    # 5. Antique Music Box (オルゴール) Melodic Lead
    # Fragile, crystal, poignant Japanese Insen / Minor melody
    lead_notes = [
        # Measure 0-3
        ("D5", 0.0, beat * 1.5), ("Eb5", beat * 1.5, beat * 0.5), ("D5", beat * 2.0, beat * 1.0),
        ("Bb4", measure * 1.0, beat * 2.0), ("C5", measure * 1.0 + beat * 2.0, beat * 1.0),
        ("A4", measure * 2.0, beat * 2.0), ("F#4", measure * 2.0 + beat * 2.0, beat * 1.0),
        ("G4", measure * 3.0, beat * 3.0),
        # Measure 4-7
        ("C5", measure * 4.0, beat * 1.5), ("D5", measure * 4.0 + beat * 1.5, beat * 0.5), ("Eb5", measure * 4.0 + beat * 2.0, beat * 1.0),
        ("F5", measure * 5.0, beat * 2.0), ("Eb5", measure * 5.0 + beat * 2.0, beat * 1.0),
        ("D5", measure * 6.0, beat * 2.0), ("C5", measure * 6.0 + beat * 2.0, beat * 1.0),
        ("D5", measure * 7.0, beat * 3.0),
        # Measure 8-11: Climax (Higher octave)
        ("G5", measure * 8.0, beat * 1.5), ("F5", measure * 8.0 + beat * 1.5, beat * 0.5), ("Eb5", measure * 8.0 + beat * 2.0, beat * 1.0),
        ("F5", measure * 9.0, beat * 2.0), ("D5", measure * 9.0 + beat * 2.0, beat * 1.0),
        ("F#5", measure * 10.0, beat * 2.0), ("A5", measure * 10.0 + beat * 2.0, beat * 1.0),
        ("G5", measure * 11.0, beat * 3.0),
        # Measure 12-15: Poignant descent to silence
        ("Eb5", measure * 12.0, beat * 1.5), ("D5", measure * 12.0 + beat * 1.5, beat * 0.5), ("C5", measure * 12.0 + beat * 2.0, beat * 1.0),
        ("D5", measure * 13.0, beat * 2.0), ("F#4", measure * 13.0 + beat * 2.0, beat * 1.0),
        ("G4", measure * 14.0, beat * 3.0),
        ("B4", measure * 15.0, beat * 3.0),
    ]
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        # Music box ping-pong between left and right tines
        pan = 0.20 if (int(start_t / beat) % 2 == 0) else 0.05
        synth_music_box(buf, start_t, f, gain=0.18, pan=pan)

    # 6. Distant Church Bell Toll at measure 0 and measure 8
    synth_church_bell(buf, 0.0, freq=note_freq("G3"), gain=0.20, pan=-0.3)
    synth_church_bell(buf, measure * 8.0, freq=note_freq("Eb3"), gain=0.22, pan=-0.3)

    buf.apply_snes_reverb(delay_sec=0.30, feedback=0.42, mix=0.35, damp=0.40)
    buf.write_wav("assets/audio/music/bgm_stage03_plan_a.wav")


# =============================================================================
# STAGE 3 PLAN B: 孤独な庭「静寂の回廊」(Corridor of Silence)
# 88 BPM Solitary Ruins Requiem / Plucked Classical Guitar & Cello / Church Bell
# =============================================================================

def render_stage03_plan_b():
    print("=== Rendering Stage 3 Plan B: 静寂の回廊 (Solitary Classical Guitar & Cello Lament) ===")
    bpm = 88.0
    beat = 60.0 / bpm
    measure = beat * 4.0
    total_measures = 12
    total_sec = measure * total_measures + 3.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))

    # Dm -> Gm -> C -> F -> Bb -> Gm -> A7 -> Dm
    chords = [
        ["D3", "F3", "A3"],    # Dm
        ["G3", "Bb3", "D4"],   # Gm
        ["C3", "E3", "G3"],    # C
        ["F3", "A3", "C4"],    # F
        ["Bb3", "D4", "F4"],   # Bb
        ["G3", "Bb3", "D4"],   # Gm
        ["A3", "C#4", "E4"],   # A7
        ["D3", "F3", "A3"],    # Dm
        # Climax
        ["Bb3", "D4", "F4"],   # Bb
        ["A3", "C#4", "E4"],   # A7
        ["D3", "F3", "A3"],    # Dm
        ["D2", "A2", "D3", "F#3"], # D major Tierce
    ]

    # 1. Distant Church Bell Tolls
    for m in [0, 4, 8]:
        root_f = note_freq(chords[m][0])
        synth_church_bell(buf, m * measure, freq=root_f, gain=0.22, pan=-0.25)

    # 2. Clockwork Gear Clicks (Slow, ancient mechanical rhythm)
    for m in range(total_measures):
        m_start = m * measure
        synth_clock_tick(buf, m_start + beat * 1.0, kind="tick", gain=0.08, pan=0.25)
        synth_clock_tick(buf, m_start + beat * 3.0, kind="tock", gain=0.07, pan=0.20)

    # 3. Plucked Classical Nylon Guitar Arpeggios (Solemn fingerpicking)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        # Root note on beat 1
        synth_classical_guitar(buf, m_start, beat * 1.5, note_freq(c_names[0]) * 0.5, gain=0.22, pan=-0.2)
        # Arpeggio steps (8th notes)
        arp_pattern = [1, 2, 0, 1, 2, 1]
        for step, p_idx in enumerate(arp_pattern):
            n_str = c_names[p_idx % len(c_names)]
            t_offset = beat * 1.0 + step * (beat * 0.5)
            synth_classical_guitar(buf, m_start + t_offset, beat * 0.9, note_freq(n_str), gain=0.13, pan=-0.15)

    # 4. Solitary Cello Lament (Poignant, deep crying cello melody)
    cello_notes = [
        ("D3", 0.0, beat * 2.0), ("E3", beat * 2.0, beat * 1.0), ("F3", beat * 3.0, beat * 1.0),
        ("G3", measure * 1.0, beat * 2.5), ("A3", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("E3", measure * 2.0, beat * 3.0),
        ("F3", measure * 3.0, beat * 3.5),
        ("D4", measure * 4.0, beat * 2.0), ("C4", measure * 4.0 + beat * 2.0, beat * 1.0), ("Bb3", measure * 4.0 + beat * 3.0, beat * 1.0),
        ("G3", measure * 5.0, beat * 3.0),
        ("A3", measure * 6.0, beat * 3.5),
        ("D3", measure * 7.0, beat * 4.0),
        # Climax
        ("F4", measure * 8.0, beat * 2.0), ("E4", measure * 8.0 + beat * 2.0, beat * 1.0), ("D4", measure * 8.0 + beat * 3.0, beat * 1.0),
        ("C#4", measure * 9.0, beat * 3.5),
        ("D4", measure * 10.0, beat * 4.0),
        ("D3", measure * 11.0, beat * 4.0),
    ]
    for n_name, start_t, dur_t in cello_notes:
        f = note_freq(n_name)
        synth_solitary_cello(buf, start_t, dur_t, f, gain=0.18, pan=-0.25)

    # 5. Antique Music Box Countermelody in Higher Register (Ghostly memory)
    for m in range(total_measures):
        if m in [2, 3, 6, 7, 10, 11]:
            c_names = chords[m % len(chords)]
            m_start = m * measure
            f1 = note_freq(c_names[1]) * 2.0
            f2 = note_freq(c_names[2]) * 2.0
            synth_music_box(buf, m_start + beat * 2.0, f1, gain=0.14, pan=0.3)
            synth_music_box(buf, m_start + beat * 3.0, f2, gain=0.14, pan=0.25)

    # 6. Gothic Pipe Organ (Sacred choir sustain)
    for m in range(0, total_measures, 2):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names]
        synth_pipe_organ(buf, m * measure, measure * 2.0, c_freqs, gain=0.08, pan_spread=0.35)

    buf.apply_snes_reverb(delay_sec=0.34, feedback=0.45, mix=0.38, damp=0.38)
    buf.write_wav("assets/audio/music/bgm_stage03_plan_b.wav")


def main():
    print("=================================================================")
    print(" Mw-fActory: Super Famicom Multi-Timbral Stage Variation Generator")
    print("=================================================================")
    render_stage02_plan_a()
    render_stage02_plan_b()
    render_stage03_plan_a()
    render_stage03_plan_b()
    print("All multi-timbral stage tracks successfully generated!")

if __name__ == "__main__":
    main()

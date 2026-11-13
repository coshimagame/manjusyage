#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Super Famicom (SFC / SNES) Style Audio Asset Generator
曼珠沙華 (MANJUSHAGE) - Batch 01 (Revised: Warm SFC Soundchip Engine)
Emulates Sony SPC700 / S-DSP warm 16-bit PCM aesthetics:
  - Band-limited warm waveforms with low-pass filtering (no harsh overtones)
  - Delayed, natural musical vibrato (starts after 0.35s, subtle 10-12 cent depth)
  - SFC S-DSP style warm stereo echo with high-frequency damping
  - Balanced mix levels (lead sits elegantly inside the music without piercing)
"""

import math
import struct
import wave
import os

SAMPLE_RATE = 44100

class RandomPRNG:
    """Deterministic PRNG for bit-exact reproducibility."""
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

    def apply_snes_echo(self, delay_sec=0.28, feedback=0.32, mix=0.28, damp=0.35):
        """SFC S-DSP style warm stereo echo with low-pass damping."""
        delay_samples = int(delay_sec * SAMPLE_RATE)
        if delay_samples <= 0:
            return
        last_l = 0.0
        last_r = 0.0
        for i in range(delay_samples, self.total):
            prev_l = self.left[i - delay_samples]
            prev_r = self.right[i - delay_samples]
            # Low-pass filter the feedback reflections (damp high frequencies)
            damped_l = prev_r * (1.0 - damp) + last_l * damp
            damped_r = prev_l * (1.0 - damp) + last_r * damp
            last_l = damped_l
            last_r = damped_r
            self.left[i] += damped_l * feedback * mix
            self.right[i] += damped_r * feedback * mix

    def write_wav(self, file_path):
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        # DC offset removal
        dc_l = sum(self.left) / self.total if self.total > 0 else 0.0
        dc_r = sum(self.right) / self.total if self.total > 0 else 0.0
        for i in range(self.total):
            self.left[i] -= dc_l
            self.right[i] -= dc_r

        # Normalization to -1.0 dBFS
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
        print(f"  [Created] {file_path} ({self.total / SAMPLE_RATE:.2f}s, peak: {max_peak:.2f} -> {max_peak*scale:.2f}, DC: 0.0)")

# -------------------------------------------------------------
# Authentic Super Famicom (SFC) Soundchip Emulation Instruments
# -------------------------------------------------------------

def snes_vibrato(t, note_dur):
    """Natural, delayed musical vibrato.
    Steady during initial attack; begins gently after 0.35s on sustained notes only.
    Speed: 4.8 Hz, Max depth: ~10 cents (0.0045 relative).
    """
    if t < 0.35 or note_dur < 0.50:
        return 0.0
    ramp = min(1.0, (t - 0.35) / 0.30)
    return math.sin(2.0 * math.pi * 4.8 * (t - 0.35)) * 0.0045 * ramp

def synth_snes_lead(buf, start_sec, dur_sec, freq, gain=0.15, pan=0.0):
    """SFC Warm Pan Flute / Shaku Lead (スーパーファミコン風 雅楽笛リード).
    Pure, warm tone with gentle breath attack and smooth low-pass filtered harmonics.
    Completely eliminates buzzy/piercing high frequencies.
    """
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi
    fade_in = int(0.045 * SAMPLE_RATE)
    fade_out = int(0.080 * SAMPLE_RATE)

    # 1-pole low-pass filter state
    lp_val = 0.0
    lp_alpha = 0.35  # cuts harsh high frequencies above ~4500Hz

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in:
            env = n / fade_in
        elif n > count - fade_out:
            env = max(0.0, (count - n) / fade_out)

        # Delayed natural vibrato
        vib = snes_vibrato(t, dur_sec)
        f_curr = freq * (1.0 + vib)
        phase = two_pi * f_curr * t

        # Warm SFC flute/reed waveform (mellow fundamental + warm 2nd harmonic)
        raw_wave = (
            0.82 * math.sin(phase) +
            0.18 * math.sin(2.0 * phase) +
            0.05 * math.sin(3.0 * phase)
        )
        # Apply low-pass smoothing (SFC Gaussian interpolation feel)
        lp_val += lp_alpha * (raw_wave - lp_val)
        sample = lp_val * env * gain

        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_snes_pad(buf, start_sec, dur_sec, freq, gain=0.10, pan=0.0):
    """SFC Warm Strings / Sho Pad (スーファミ風 ストリングス・笙パッド).
    Lush, soft background bed that adds emotional depth without cluttering the lead.
    """
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi
    fade_in = int(0.15 * SAMPLE_RATE)
    fade_out = int(0.20 * SAMPLE_RATE)

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in:
            env = n / fade_in
        elif n > count - fade_out:
            env = max(0.0, (count - n) / fade_out)

        # Warm detuned chorusing
        w1 = math.sin(two_pi * freq * t)
        w2 = math.sin(two_pi * freq * 1.002 * t)
        w_sub = 0.3 * math.sin(two_pi * freq * 0.5 * t)
        sample = (w1 * 0.5 + w2 * 0.4 + w_sub) * env * gain

        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_snes_bell(buf, start_sec, dur_sec, freq, gain=0.12, pan=0.0):
    """SFC Pluck / Bell / Harp (スーファミ風 チェレスタ・琵琶アルペジオ)."""
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 9.0) * (1.0 - math.exp(-t * 300.0))
        wave = math.sin(two_pi * freq * t) + 0.25 * math.sin(two_pi * freq * 2.0 * t)
        sample = wave * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_snes_bass(buf, start_sec, dur_sec, freq, gain=0.22, pan=0.0):
    """SFC Round Fingered / Slap Bass (スーファミ風 ウォームベース).
    Deep, punchy, round bottom-end (no harsh FM clatter).
    """
    if freq <= 0:
        return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 4.2) * (1.0 - math.exp(-t * 350.0))
        wave = 0.70 * math.sin(two_pi * freq * t) + 0.30 * math.sin(two_pi * freq * 2.0 * t) * math.exp(-t * 12.0)
        sample = wave * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_snes_drum(buf, start_sec, kind="kick", gain=0.30, prng=None):
    """SFC 16-bit PCM Style Acoustic / Electronic Percussion."""
    start = int(start_sec * SAMPLE_RATE)
    duration = {"kick": 0.22, "snare": 0.20, "hat": 0.05, "taiko": 0.50}[kind]
    count = min(int(duration * SAMPLE_RATE), buf.total - start)
    if count <= 0:
        return
    two_pi = 2.0 * math.pi

    for n in range(count):
        t = n / SAMPLE_RATE
        noise = prng.next_float() if prng else 0.0

        if kind == "kick":
            f_inst = 48.0 + 32.0 * math.exp(-t * 26.0)
            phase = two_pi * f_inst * t
            sig = math.sin(phase) * math.exp(-t * 15.0)
        elif kind == "snare":
            tone = math.sin(two_pi * 175.0 * t) * 0.45 * math.exp(-t * 25.0)
            snare_noise = noise * 0.55 * math.exp(-t * 18.0)
            sig = tone + snare_noise
        elif kind == "hat":
            sig = noise * math.exp(-t * 95.0) * 0.4
        elif kind == "taiko":
            f_inst = 65.0 + 35.0 * math.exp(-t * 14.0)
            phase = two_pi * f_inst * t
            sig = math.sin(phase) * math.exp(-t * 6.0)

        sample = sig * gain
        buf.add_sample(start + n, sample, sample)

# -------------------------------------------------------------
# BGM 1: Stage 1 Plan A (SFC Gagaku Future x Melodic Rush)
# -------------------------------------------------------------
def generate_stage01_plan_a(file_path):
    bpm = 156
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(101)

    chords = [
        (["D4", "A4", "D5"], "D2"), (["Bb3", "F4", "Bb4"], "Bb1"),
        (["G3", "D4", "G4"], "G1"), (["A3", "E4", "A4"], "A1"),
        (["D4", "A4", "F5"], "D2"), (["Bb3", "F4", "D5"], "Bb1"),
        (["C4", "G4", "E5"], "C2"), (["A3", "E4", "C#5"], "A1"),
        (["D4", "A4", "F5"], "D2"), (["Bb3", "F4", "D5"], "Bb1"),
        (["G3", "D4", "Bb4"], "G1"), (["A3", "E4", "A4"], "A1"),
        (["F4", "C5", "A5"], "F2"), (["C4", "G4", "E5"], "C2"),
        (["Bb3", "F4", "D5"], "Bb1"), (["A3", "E4", "C#5"], "A1"),
        (["D4", "A4", "F5"], "D2"), (["G3", "D4", "Bb4"], "G1"),
        (["Bb3", "F4", "D5"], "Bb1"), (["C4", "G4", "E5"], "C2"),
        (["D4", "A4", "D5"], "D2"), (["Bb3", "F4", "F5"], "Bb1"),
        (["C4", "G4", "G5"], "C2"), (["D4", "A4", "A5"], "D2"),
        (["G3", "D4", "Bb4"], "G1"), (["A3", "E4", "C#5"], "A1"),
        (["Bb3", "F4", "D5"], "Bb1"), (["C4", "G4", "E5"], "C2"),
        (["D4", "A4", "F5"], "D2"), (["Bb3", "F4", "D5"], "Bb1"),
        (["A3", "E4", "C#5"], "A1"), (["D4", "A4", "D5"], "D2"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        bar_start_beat = bar_idx * 4.0
        for n_str in chord_notes:
            synth_snes_pad(buf, bar_start_beat * step, 4.0 * step, note_freq(n_str), gain=0.10, pan=-0.2)

        if bar_idx >= 4:
            b_freq = note_freq(bass_root)
            for sub in range(8):
                b_start = (bar_start_beat + sub * 0.5) * step
                synth_snes_bass(buf, b_start, 0.45 * step, b_freq, gain=0.22, pan=0.0)

        if bar_idx >= 4:
            for i, p_note in enumerate(chord_notes):
                synth_snes_bell(buf, (bar_start_beat + i * 1.0) * step, 0.9 * step, note_freq(p_note), gain=0.10, pan=0.3)

    melody_track = [
        (0.0, 2.0, "D5"), (2.0, 1.0, "F5"), (3.0, 1.0, "A5"),
        (4.0, 2.5, "G5"), (6.5, 1.5, "F5"),
        (8.0, 2.0, "E5"), (10.0, 2.0, "D5"),
        (12.0, 4.0, "A4"),
        (16.0, 1.0, "A4"), (17.0, 1.0, "D5"), (18.0, 1.5, "F5"),
        (19.5, 0.5, "E5"), (20.0, 2.0, "D5"), (22.0, 2.0, "C5"),
        (24.0, 1.5, "D5"), (25.5, 0.5, "E5"), (26.0, 2.0, "F5"),
        (28.0, 2.0, "G5"), (30.0, 2.0, "A5"),
        (32.0, 1.5, "F5"), (33.5, 0.5, "E5"), (34.0, 2.0, "D5"),
        (36.0, 2.0, "C#5"), (38.0, 2.0, "D5"),
        (40.0, 1.5, "Bb4"), (41.5, 0.5, "C5"), (42.0, 2.0, "D5"),
        (44.0, 4.0, "A4"),
        (48.0, 1.5, "A5"), (49.5, 0.5, "G5"), (50.0, 2.0, "F5"),
        (52.0, 2.0, "G5"), (54.0, 2.0, "E5"),
        (56.0, 1.5, "F5"), (57.5, 0.5, "E5"), (58.0, 2.0, "D5"),
        (60.0, 4.0, "C#5"),
        (64.0, 2.0, "D5"), (66.0, 2.0, "F5"),
        (68.0, 2.0, "G5"), (70.0, 2.0, "Bb5"),
        (72.0, 2.0, "A5"), (74.0, 2.0, "E5"),
        (76.0, 4.0, "D5"),
        (80.0, 1.0, "D5"), (81.0, 1.0, "F5"), (82.0, 2.0, "A5"),
        (84.0, 1.5, "Bb5"), (85.5, 0.5, "A5"), (86.0, 2.0, "G5"),
        (88.0, 2.0, "F5"), (90.0, 2.0, "G5"), (92.0, 4.0, "A5"),
        (96.0, 2.0, "Bb5"), (98.0, 2.0, "A5"),
        (100.0, 2.0, "F5"), (102.0, 2.0, "E5"),
        (104.0, 2.0, "D5"), (106.0, 2.0, "C5"),
        (108.0, 4.0, "D5"),
        (112.0, 2.0, "F5"), (114.0, 2.0, "E5"),
        (116.0, 4.0, "D5"),
    ]

    for b_pos, b_len, p_str in melody_track:
        freq = note_freq(p_str)
        s_time = b_pos * step
        dur = b_len * step
        synth_snes_lead(buf, s_time, dur, freq, gain=0.16, pan=0.0)

    for bar in range(bars):
        b_start = bar * 4.0
        if bar < 4:
            synth_snes_drum(buf, b_start * step, "taiko", gain=0.32, prng=prng)
            synth_snes_drum(buf, (b_start + 2.0) * step, "taiko", gain=0.24, prng=prng)
        else:
            synth_snes_drum(buf, b_start * step, "kick", gain=0.32, prng=prng)
            synth_snes_drum(buf, (b_start + 1.5) * step, "kick", gain=0.26, prng=prng)
            synth_snes_drum(buf, (b_start + 2.5) * step, "kick", gain=0.28, prng=prng)
            synth_snes_drum(buf, (b_start + 1.0) * step, "snare", gain=0.30, prng=prng)
            synth_snes_drum(buf, (b_start + 3.0) * step, "snare", gain=0.30, prng=prng)
            for sub in range(8):
                h_gain = 0.12 if sub % 2 == 0 else 0.08
                synth_snes_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=h_gain, prng=prng)

    buf.apply_snes_echo(delay_sec=0.28, feedback=0.32, mix=0.26, damp=0.35)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 2: Stage 1 Plan B (SFC Melodic Retro Rock)
# -------------------------------------------------------------
def generate_stage01_plan_b(file_path):
    bpm = 148
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(202)

    chords = [
        (["F#4", "C#5"], "F#2"), (["D4", "A4"], "D2"), (["A3", "E4"], "A1"), (["E4", "B4"], "E2"),
        (["F#4", "C#5", "A5"], "F#2"), (["D4", "A4", "F#5"], "D2"),
        (["A3", "E4", "C#5"], "A1"), (["E4", "B4", "G#5"], "E2"),
        (["F#4", "C#5", "A5"], "F#2"), (["B3", "F#4", "D5"], "B1"),
        (["C#4", "G#4", "F5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
        (["D4", "A4", "F#5"], "D2"), (["E4", "B4", "G#5"], "E2"),
        (["C#4", "G#4", "E5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
        (["B3", "F#4", "D5"], "B1"), (["C#4", "G#4", "F5"], "C#2"),
        (["D4", "A4", "F#5"], "D2"), (["E4", "B4", "G#5"], "E2"),
        (["F#4", "C#5", "A5"], "F#2"), (["D4", "A4", "F#5"], "D2"),
        (["E4", "B4", "G#5"], "E2"), (["C#4", "G#4", "F5"], "C#2"),
        (["D4", "A4", "F#5"], "D2"), (["B3", "F#4", "D5"], "B1"),
        (["C#4", "G#4", "F5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
        (["D4", "A4", "F#5"], "D2"), (["E4", "B4", "G#5"], "E2"),
        (["C#4", "G#4", "F5"], "C#2"), (["F#4", "C#5", "A5"], "F#2"),
    ]

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        b_start = bar_idx * 4.0
        for n_str in chord_notes:
            synth_snes_pad(buf, b_start * step, 4.0 * step, note_freq(n_str), gain=0.09, pan=0.15)

        b_freq = note_freq(bass_root)
        for s in range(16):
            if s % 4 != 3:
                synth_snes_bass(buf, (b_start + s * 0.25) * step, 0.22 * step, b_freq, gain=0.20, pan=0.0)

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
        synth_snes_lead(buf, m_beat * step, m_len * step, f, gain=0.17, pan=-0.05)

    for bar in range(bars):
        b_start = bar * 4.0
        synth_snes_drum(buf, b_start * step, "kick", gain=0.34, prng=prng)
        synth_snes_drum(buf, (b_start + 1.5) * step, "kick", gain=0.28, prng=prng)
        synth_snes_drum(buf, (b_start + 2.5) * step, "kick", gain=0.30, prng=prng)
        synth_snes_drum(buf, (b_start + 1.0) * step, "snare", gain=0.32, prng=prng)
        synth_snes_drum(buf, (b_start + 3.0) * step, "snare", gain=0.32, prng=prng)
        for sub in range(8):
            synth_snes_drum(buf, (b_start + sub * 0.5) * step, "hat", gain=0.12, prng=prng)

    buf.apply_snes_echo(delay_sec=0.26, feedback=0.30, mix=0.24, damp=0.35)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 3: Boss 1 Plan A (SFC Bio-Core Tension)
# -------------------------------------------------------------
def generate_boss01_plan_a(file_path):
    bpm = 162
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(303)

    chords = [
        (["G3", "Db4", "G4"], "G1"), (["G3", "D4", "Bb4"], "G1"),
        (["Ab3", "Eb4", "C5"], "Ab1"), (["G3", "Db4", "G4"], "G1"),
        (["Eb4", "Bb4", "G5"], "Eb2"), (["Db4", "Ab4", "F5"], "Db2"),
        (["D4", "A4", "F#5"], "D2"), (["D4", "Ab4", "F5"], "D2"),
    ] * 4

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        b_start = bar_idx * 4.0
        for n_str in chord_notes:
            synth_snes_pad(buf, b_start * step, 4.0 * step, note_freq(n_str), gain=0.11, pan=-0.2)

        b_freq = note_freq(bass_root)
        for s in range(8):
            synth_snes_bass(buf, (b_start + s * 0.5) * step, 0.35 * step, b_freq, gain=0.24, pan=0.0)

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
        synth_snes_lead(buf, b_pos * step, b_len * step, f, gain=0.18, pan=0.0)

    for bar in range(bars):
        b_start = bar * 4.0
        synth_snes_drum(buf, b_start * step, "taiko", gain=0.38, prng=prng)
        synth_snes_drum(buf, (b_start + 0.75) * step, "taiko", gain=0.28, prng=prng)
        synth_snes_drum(buf, (b_start + 2.0) * step, "taiko", gain=0.34, prng=prng)
        synth_snes_drum(buf, (b_start + 1.0) * step, "snare", gain=0.32, prng=prng)
        synth_snes_drum(buf, (b_start + 3.0) * step, "snare", gain=0.32, prng=prng)
        synth_snes_drum(buf, (b_start + 3.5) * step, "kick", gain=0.28, prng=prng)
        for s in range(8):
            synth_snes_drum(buf, (b_start + s * 0.5) * step, "hat", gain=0.12, prng=prng)

    buf.apply_snes_echo(delay_sec=0.24, feedback=0.30, mix=0.25, damp=0.35)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# BGM 4: Boss 1 Plan B (SFC Rhapsody Breakthrough)
# -------------------------------------------------------------
def generate_boss01_plan_b(file_path):
    bpm = 168
    step = 60.0 / bpm
    bars = 32
    duration = bars * 4 * step
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(404)

    chords = [
        (["C4", "G4", "Eb5"], "C2"), (["Ab3", "Eb4", "C5"], "Ab1"),
        (["F3", "C4", "Ab4"], "F1"), (["G3", "D4", "B4"], "G1"),
        (["C4", "G4", "Eb5"], "C2"), (["Eb4", "Bb4", "G5"], "Eb2"),
        (["Ab3", "Eb4", "C5"], "Ab1"), (["G3", "D4", "B4"], "G1"),
    ] * 4

    for bar_idx, (chord_notes, bass_root) in enumerate(chords):
        b_start = bar_idx * 4.0
        for n_str in chord_notes:
            synth_snes_pad(buf, b_start * step, 4.0 * step, note_freq(n_str), gain=0.10, pan=0.15)

        b_freq = note_freq(bass_root)
        for s in range(16):
            synth_snes_bass(buf, (b_start + s * 0.25) * step, 0.20 * step, b_freq, gain=0.20, pan=0.0)

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
        synth_snes_lead(buf, b_pos * step, b_len * step, f, gain=0.18, pan=0.0)

    for bar in range(bars):
        b_start = bar * 4.0
        synth_snes_drum(buf, b_start * step, "kick", gain=0.34, prng=prng)
        synth_snes_drum(buf, (b_start + 1.0) * step, "snare", gain=0.32, prng=prng)
        synth_snes_drum(buf, (b_start + 2.0) * step, "kick", gain=0.34, prng=prng)
        synth_snes_drum(buf, (b_start + 3.0) * step, "snare", gain=0.32, prng=prng)
        for s in range(8):
            synth_snes_drum(buf, (b_start + s * 0.5) * step, "hat", gain=0.12, prng=prng)

    buf.apply_snes_echo(delay_sec=0.22, feedback=0.28, mix=0.22, damp=0.35)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Jingle JG-002: Sortie Fanfare (SFC Style)
# -------------------------------------------------------------
def generate_jingle_sortie(file_path):
    duration = 3.6
    total_samples = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total_samples)
    prng = RandomPRNG(505)

    for n in ["D4", "F#4", "A4", "D5"]:
        synth_snes_pad(buf, 0.0, 3.4, note_freq(n), gain=0.16, pan=0.0)

    flourish = [
        (0.0, "D4"), (0.12, "F#4"), (0.24, "A4"), (0.36, "D5"),
        (0.48, "F#5"), (0.60, "A5"), (0.72, "D6")
    ]
    for t_sec, n in flourish:
        synth_snes_bell(buf, t_sec, 1.2, note_freq(n), gain=0.20, pan=0.2)
        synth_snes_lead(buf, t_sec, 0.8, note_freq(n), gain=0.14, pan=-0.1)

    for n in ["D5", "F#5", "A5", "D6"]:
        synth_snes_lead(buf, 0.9, 2.5, note_freq(n), gain=0.14, pan=0.0)

    synth_snes_drum(buf, 0.0, "taiko", gain=0.40, prng=prng)
    synth_snes_drum(buf, 0.45, "taiko", gain=0.35, prng=prng)
    synth_snes_drum(buf, 0.90, "taiko", gain=0.55, prng=prng)
    synth_snes_drum(buf, 0.90, "snare", gain=0.35, prng=prng)

    buf.apply_snes_echo(delay_sec=0.25, feedback=0.32, mix=0.28, damp=0.35)
    buf.write_wav(file_path)

# -------------------------------------------------------------
# Sound Effects (SFX)
# -------------------------------------------------------------
def generate_shot_cormii(file_path):
    duration = 0.14
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi
    prng = RandomPRNG(601)

    for n in range(total):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        f = 180.0 + 740.0 * math.exp(-t * 40.0)
        phase = two_pi * f * t
        square = 1.0 if math.sin(phase) > 0 else -1.0
        wave = 0.55 * square + 0.45 * math.sin(phase)
        noise = prng.next_float() * math.exp(-t * 80.0) * 0.20
        val = (wave + noise) * env * 0.45
        buf.add_sample(n, val, val)
    buf.write_wav(file_path)

def generate_shot_jiyoza(file_path):
    duration = 0.15
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi

    for n in range(total):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 22.0)
        f1 = 620.0 + 1330.0 * math.exp(-t * 25.0)
        f2 = 410.0 + 890.0 * math.exp(-t * 25.0)
        wave = 0.6 * math.sin(two_pi * f1 * t) + 0.4 * math.sin(two_pi * f2 * t)
        val = wave * env * 0.42
        buf.add_sample(n, val * 0.9, val * 1.1)
    buf.write_wav(file_path)

def generate_shot_mafio(file_path):
    duration = 0.18
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi
    prng = RandomPRNG(603)

    for n in range(total):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 18.0)
        f = 42.0 + 123.0 * math.exp(-t * 30.0)
        phase = two_pi * f * t
        sub = math.sin(phase)
        crunch = prng.next_float() * math.exp(-t * 45.0) * 0.35
        val = (sub * 0.75 + crunch) * env * 0.48
        buf.add_sample(n, val, val)
    buf.write_wav(file_path)

def generate_boss_warning(file_path):
    duration = 0.85
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi

    for n in range(total):
        t = n / SAMPLE_RATE
        env = (1.0 - math.exp(-t * 30.0)) * math.exp(-t * 2.5)
        lfo = math.sin(two_pi * 16.0 * t) * 0.15
        f = (320.0 + 660.0 * (t / duration)) * (1.0 + lfo)
        mod = math.sin(two_pi * f * 2.0 * t) * 1.5
        carrier = math.sin(two_pi * f * t + mod)
        dissonance = 0.30 * math.sin(two_pi * (f * 1.414) * t)
        val = (carrier + dissonance) * env * 0.38
        buf.add_sample(n, val * 0.9, val * 1.1)
    buf.write_wav(file_path)

def generate_boss_destroy(file_path):
    duration = 2.8
    total = int(duration * SAMPLE_RATE)
    buf = SoundBuffer(total)
    two_pi = 2.0 * math.pi
    prng = RandomPRNG(605)

    for n in range(total):
        t = n / SAMPLE_RATE
        noise = prng.next_float()
        crack = noise * math.exp(-t * 35.0) * 0.65
        f_sub = 24.0 + 66.0 * math.exp(-t * 6.0)
        sub = math.sin(two_pi * f_sub * t) * math.exp(-t * 1.5) * 0.60
        bursts = 0.0
        for b_time, b_gain in [(0.25, 0.45), (0.55, 0.40), (0.90, 0.35)]:
            if t > b_time:
                dt = t - b_time
                bursts += prng.next_float() * math.exp(-dt * 12.0) * b_gain
        sparkle = 0.0
        if t > 1.2:
            dt = t - 1.2
            sparkle = math.sin(two_pi * 1840.0 * t) * math.exp(-dt * 2.2) * 0.15

        val = (crack + sub + bursts + sparkle) * 0.52
        buf.add_sample(n, val * (1.0 + 0.1 * noise), val * (1.0 - 0.1 * noise))

    buf.apply_snes_echo(delay_sec=0.32, feedback=0.38, mix=0.28, damp=0.40)
    buf.write_wav(file_path)

def main():
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    print(f"=== Mw-fActory Sound Team: SFC Soundchip Engine Audio Generation ===")
    print(f"Target Root: {root_dir}")

    m_dir = os.path.join(root_dir, "assets", "audio", "music")
    generate_stage01_plan_a(os.path.join(m_dir, "bgm_stage01_plan_a.wav"))
    generate_stage01_plan_b(os.path.join(m_dir, "bgm_stage01_plan_b.wav"))
    generate_boss01_plan_a(os.path.join(m_dir, "bgm_boss01_plan_a.wav"))
    generate_boss01_plan_b(os.path.join(m_dir, "bgm_boss01_plan_b.wav"))

    j_dir = os.path.join(root_dir, "assets", "audio", "jingles")
    generate_jingle_sortie(os.path.join(j_dir, "jg002_sortie.wav"))

    s_dir = os.path.join(root_dir, "assets", "audio", "sfx")
    generate_shot_cormii(os.path.join(s_dir, "se_shot_cormii.wav"))
    generate_shot_jiyoza(os.path.join(s_dir, "se_shot_jiyoza.wav"))
    generate_shot_mafio(os.path.join(s_dir, "se_shot_mafio.wav"))
    generate_boss_warning(os.path.join(s_dir, "se_boss_warning.wav"))
    generate_boss_destroy(os.path.join(s_dir, "se_boss_destroy.wav"))

    print("=== Super Famicom Audio Assets Generated Successfully! ===")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Opening & Title Theme Engine

Generates:
  - assets/audio/music/bgm_opening_plan_a.wav (曼珠沙華 〜 記憶の深淵 / Abyss of Memories)
  - assets/audio/music/bgm_opening_plan_b.wav (曼珠沙華 〜 輪廻のプロローグ / Prologue of Reincarnation)
"""

import math
import struct
import wave
import os

SAMPLE_RATE = 44100
TWO_PI = 2.0 * math.pi

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

    def apply_snes_reverb(self, delay_sec=0.32, feedback=0.42, mix=0.35, damp=0.40):
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
# Instruments for Title / Opening
# =============================================================================

def synth_sho_pad(buf, start_sec, dur_sec, chord_freqs, gain=0.08, pan_spread=0.5):
    """Gagaku Sho (笙) Ethereal Cluster Pad."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.40 * SAMPLE_RATE)
    fade_out = int(0.45 * SAMPLE_RATE)

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
            # Gentle reed harmonic profile
            s1 = math.sin(ph)
            s2 = 0.40 * math.sin(2.0 * ph)
            s3 = 0.20 * math.sin(3.0 * ph)
            sample = (s1 + s2 + s3) * env * gain
            buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_koto_harp(buf, start_sec, dur_sec, freq, gain=0.14, pan=0.0):
    """Japanese Koto / Celtic Harp arpeggio."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 3.5) * (1.0 - math.exp(-t * 500.0))
        # Plucked string harmonics
        h1 = math.sin(TWO_PI * freq * t)
        h2 = 0.55 * math.sin(TWO_PI * freq * 2.0 * t) * math.exp(-t * 6.0)
        h3 = 0.30 * math.sin(TWO_PI * freq * 3.0 * t) * math.exp(-t * 11.0)
        h4 = 0.15 * math.sin(TWO_PI * freq * 4.0 * t) * math.exp(-t * 18.0)
        sig = (h1 + h2 + h3 + h4) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))

def synth_expressive_flute(buf, start_sec, dur_sec, freq, gain=0.20, pan=0.0):
    """Deeply melancholic SFC Shakuhachi / Wooden Flute lead."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.06 * SAMPLE_RATE)
    fade_out = int(0.12 * SAMPLE_RATE)
    lp = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        # Expressive delayed vibrato
        vib = 0.0
        if t > 0.25 and dur_sec > 0.40:
            ramp = min(1.0, (t - 0.25) / 0.30)
            vib = math.sin(TWO_PI * 4.8 * (t - 0.25)) * 0.0055 * ramp

        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.80 * math.sin(ph) + 0.20 * math.sin(2.0 * ph) + 0.08 * math.sin(3.0 * ph)
        lp += 0.32 * (raw - lp)
        sample = lp * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_warm_cello(buf, start_sec, dur_sec, freq, gain=0.16, pan=-0.25):
    """Solemn, warm cello counter-melody."""
    if freq <= 0: return
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(dur_sec * SAMPLE_RATE), buf.total - start)
    if count <= 0: return
    fade_in = int(0.10 * SAMPLE_RATE)
    fade_out = int(0.14 * SAMPLE_RATE)
    lp = 0.0

    for n in range(count):
        t = n / SAMPLE_RATE
        env = 1.0
        if n < fade_in: env = n / fade_in
        elif n > count - fade_out: env = max(0.0, (count - n) / fade_out)

        vib = math.sin(TWO_PI * 4.4 * t) * 0.0040 if t > 0.30 else 0.0
        ph = TWO_PI * freq * (1.0 + vib) * t
        raw = 0.70 * math.sin(ph) + 0.32 * math.sin(2.0 * ph) + 0.14 * math.sin(3.0 * ph)
        lp += 0.25 * (raw - lp)
        sample = lp * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sample * math.cos(theta), sample * math.sin(theta))

def synth_tympani_deep(buf, start_sec, freq=65.0, gain=0.25):
    """Dramatic orchestral tympani / sub-impact."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(1.2 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        f = freq * (1.0 + 0.4 * math.exp(-t * 20.0))
        env = math.exp(-t * 3.8)
        sig = (math.sin(TWO_PI * f * t) + 0.3 * math.sin(TWO_PI * f * 1.5 * t) * math.exp(-t * 8.0)) * env * gain
        buf.add_sample(start + n, sig, sig)

def synth_bell_chime(buf, start_sec, freq=587.33, gain=0.15, pan=0.2):
    """Crystal Title Chime (D5)."""
    start = int(start_sec * SAMPLE_RATE)
    count = min(int(2.4 * SAMPLE_RATE), buf.total - start)
    if count <= 0: return

    for n in range(count):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 2.5)
        p1 = math.sin(TWO_PI * freq * t)
        p2 = 0.40 * math.sin(TWO_PI * freq * 2.76 * t) * math.exp(-t * 5.0)
        p3 = 0.20 * math.sin(TWO_PI * freq * 5.40 * t) * math.exp(-t * 10.0)
        sig = (p1 + p2 + p3) * env * gain
        theta = (pan + 1.0) * math.pi / 4.0
        buf.add_sample(start + n, sig * math.cos(theta), sig * math.sin(theta))


# =============================================================================
# OPENING PLAN A: 曼珠沙華 〜 記憶の深淵 (Abyss of Memories)
# BPM 82 / D minor -> F Major -> D minor / Dramatic Ethereal Title Theme
# =============================================================================

def render_opening_plan_a():
    print("=== Rendering Opening Plan A: 曼珠沙華 〜 記憶の深淵 (Abyss of Memories) ===")
    bpm = 82.0
    beat = 60.0 / bpm
    measure = beat * 4.0
    total_measures = 14
    total_sec = measure * total_measures + 3.0
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))

    # Chords: Dm -> Bb -> Gm -> A7sus4 -> Dm -> Bb -> C -> Dsus4 -> D
    chords = [
        ["D3", "F3", "A3", "D4"],    # Dm (Intro)
        ["Bb2", "D3", "F3", "Bb3"],  # Bb
        ["G2", "Bb2", "D3", "G3"],   # Gm
        ["A2", "D3", "E3", "A3"],    # A7sus4
        ["D3", "F3", "A3", "D4"],    # Dm (Theme A)
        ["Bb2", "D3", "F3", "Bb3"],  # Bb
        ["C3", "E3", "G3", "C4"],    # C
        ["F2", "A2", "C3", "F3"],    # F (Climax)
        ["Bb2", "D3", "F3", "Bb3"],  # Bb
        ["G2", "Bb2", "D3", "G3"],   # Gm
        ["A2", "C#3", "E3", "A3"],   # A7
        ["D3", "F3", "A3", "D4"],    # Dm
        ["Bb2", "F3", "Bb3", "D4"],  # Bb
        ["D2", "A2", "D3", "F#3"],   # D major Picardy resolve
    ]

    # 1. Ethereal Sho Pad (Gagaku clusters floating behind the title screen)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names]
        synth_sho_pad(buf, m * measure, measure, c_freqs, gain=0.08)

    # 2. Delicate Koto / Harp Arpeggio (Spider lily petals falling)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        for step in range(8):
            n_idx = step % len(c_names)
            f = note_freq(c_names[n_idx]) * 2.0
            pan = -0.3 + (step * 0.08)
            synth_koto_harp(buf, m_start + step * (beat * 0.5), beat * 1.2, f, gain=0.12, pan=pan)

    # 3. Tympani impacts on key structural downbeats (Measure 0, 4, 7, 11)
    for m in [0, 4, 7, 11]:
        root_f = note_freq(chords[m][0])
        synth_tympani_deep(buf, m * measure, freq=root_f, gain=0.28)

    # 4. Melancholic & Weeping Main Theme (SFC Shakuhachi / Flute Lead)
    # The unforgettable, poignant motif of MANJUSHAGE
    lead_notes = [
        # Intro phrase (Measure 0-3)
        ("A4", measure * 0.0, beat * 3.0), ("G4", measure * 0.0 + beat * 3.0, beat * 1.0),
        ("F4", measure * 1.0, beat * 2.5), ("E4", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("D4", measure * 2.0, beat * 3.5),
        ("E4", measure * 3.0, beat * 3.0),
        # Main Melody (Measure 4-7): Emotional swelling
        ("D5", measure * 4.0, beat * 2.0), ("E5", measure * 4.0 + beat * 2.0, beat * 1.0), ("F5", measure * 4.0 + beat * 3.0, beat * 1.0),
        ("G5", measure * 5.0, beat * 2.5), ("F5", measure * 5.0 + beat * 2.5, beat * 1.5),
        ("E5", measure * 6.0, beat * 2.5), ("C5", measure * 6.0 + beat * 2.5, beat * 1.5),
        ("A4", measure * 7.0, beat * 4.0),
        # Climax (Measure 8-11): Passionate cry across worldlines
        ("Bb5", measure * 8.0, beat * 2.0), ("A5", measure * 8.0 + beat * 2.0, beat * 1.0), ("G5", measure * 8.0 + beat * 3.0, beat * 1.0),
        ("F5", measure * 9.0, beat * 2.5), ("D5", measure * 9.0 + beat * 2.5, beat * 1.5),
        ("E5", measure * 10.0, beat * 3.0), ("C#5", measure * 10.0 + beat * 3.0, beat * 1.0),
        ("D5", measure * 11.0, beat * 4.0),
        # Outro Descent (Measure 12-13)
        ("F5", measure * 12.0, beat * 2.0), ("E5", measure * 12.0 + beat * 2.0, beat * 2.0),
        ("F#5", measure * 13.0, beat * 4.5),
    ]
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_expressive_flute(buf, start_t, dur_t, f, gain=0.22, pan=0.0)

    # 5. Warm Solo Cello Counterpoint (Measure 4 through 11)
    cello_notes = [
        ("D3", measure * 4.0, beat * 2.5), ("F3", measure * 4.0 + beat * 2.5, beat * 1.5),
        ("G3", measure * 5.0, beat * 2.5), ("Bb3", measure * 5.0 + beat * 2.5, beat * 1.5),
        ("C3", measure * 6.0, beat * 2.5), ("E3", measure * 6.0 + beat * 2.5, beat * 1.5),
        ("F3", measure * 7.0, beat * 4.0),
        ("G3", measure * 8.0, beat * 2.5), ("Bb3", measure * 8.0 + beat * 2.5, beat * 1.5),
        ("A3", measure * 9.0, beat * 2.5), ("F3", measure * 9.0 + beat * 2.5, beat * 1.5),
        ("E3", measure * 10.0, beat * 3.5),
        ("D3", measure * 11.0, beat * 4.0),
    ]
    for n_name, start_t, dur_t in cello_notes:
        f = note_freq(n_name)
        synth_warm_cello(buf, start_t, dur_t, f, gain=0.17, pan=-0.25)

    # 6. Crystal Title Chimes at Intro and Resolution
    synth_bell_chime(buf, 0.0, freq=note_freq("D5"), gain=0.18, pan=0.25)
    synth_bell_chime(buf, measure * 4.0, freq=note_freq("A5"), gain=0.16, pan=-0.25)
    synth_bell_chime(buf, measure * 13.0, freq=note_freq("D6"), gain=0.18, pan=0.15)

    buf.apply_snes_reverb(delay_sec=0.35, feedback=0.45, mix=0.38, damp=0.35)
    buf.write_wav("assets/audio/music/bgm_opening_plan_a.wav")


# =============================================================================
# OPENING PLAN B: 曼珠沙華 〜 輪廻のプロローグ (Prologue of Reincarnation)
# BPM 96 / A minor -> C Major -> D / Ethereal Synth Arpeggio & Quiet Passion
# =============================================================================

def render_opening_plan_b():
    print("=== Rendering Opening Plan B: 曼珠沙華 〜 輪廻のプロローグ (Prologue of Reincarnation) ===")
    bpm = 96.0
    beat = 60.0 / bpm
    measure = beat * 4.0
    total_measures = 14
    total_sec = measure * total_measures + 2.5
    buf = SoundBuffer(int(total_sec * SAMPLE_RATE))

    # Am -> F -> C -> G -> Am -> F -> Dm -> E7 -> Am
    chords = [
        ["A2", "C3", "E3", "A3"],    # Am
        ["F2", "A2", "C3", "F3"],    # F
        ["C3", "E3", "G3", "C4"],    # C
        ["G2", "B2", "D3", "G3"],    # G
        ["A2", "C3", "E3", "A3"],    # Am
        ["F2", "A2", "C3", "F3"],    # F
        ["D2", "F2", "A2", "D3"],    # Dm
        ["E2", "G#2", "B2", "E3"],   # E7
        ["F2", "A2", "C3", "F3"],    # F (Climax)
        ["G2", "B2", "D3", "G3"],    # G
        ["E2", "G#2", "B2", "E3"],   # E
        ["A2", "C3", "E3", "A3"],    # Am
        ["F2", "C3", "F3", "A3"],    # F
        ["A2", "E3", "A3", "C#4"],   # A major Tierce
    ]

    # 1. Floating Ethereal Pad
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        c_freqs = [note_freq(n) for n in c_names]
        synth_sho_pad(buf, m * measure, measure, c_freqs, gain=0.08)

    # 2. 16th Harp / Bell Arpeggio (Memory Shards)
    for m in range(total_measures):
        c_names = chords[m % len(chords)]
        m_start = m * measure
        for step in range(16):
            n_idx = step % len(c_names)
            f = note_freq(c_names[n_idx]) * 2.0
            pan = -0.25 if step % 2 == 0 else 0.25
            synth_koto_harp(buf, m_start + step * (beat * 0.25), beat * 0.6, f, gain=0.10, pan=pan)

    # 3. Soft Sub-Beat (Heartbeat of the Memory Engine)
    for m in range(total_measures):
        m_start = m * measure
        synth_tympani_deep(buf, m_start, freq=note_freq(chords[m][0]), gain=0.20)
        synth_tympani_deep(buf, m_start + beat * 2.0, freq=note_freq(chords[m][0]) * 1.5, gain=0.15)

    # 4. Lyrical Melody (SFC Flute & Cello in gentle harmony)
    lead_notes = [
        ("E5", 0.0, beat * 2.0), ("D5", beat * 2.0, beat * 1.0), ("C5", beat * 3.0, beat * 1.0),
        ("A4", measure * 1.0, beat * 2.5), ("C5", measure * 1.0 + beat * 2.5, beat * 1.5),
        ("G4", measure * 2.0, beat * 3.5),
        ("B4", measure * 3.0, beat * 3.0),
        # Second half
        ("C5", measure * 4.0, beat * 2.0), ("D5", measure * 4.0 + beat * 2.0, beat * 1.0), ("E5", measure * 4.0 + beat * 3.0, beat * 1.0),
        ("F5", measure * 5.0, beat * 2.5), ("A5", measure * 5.0 + beat * 2.5, beat * 1.5),
        ("D5", measure * 6.0, beat * 3.0),
        ("E5", measure * 7.0, beat * 3.5),
        # Climax
        ("A5", measure * 8.0, beat * 2.0), ("G5", measure * 8.0 + beat * 2.0, beat * 1.0), ("F5", measure * 8.0 + beat * 3.0, beat * 1.0),
        ("G5", measure * 9.0, beat * 2.5), ("E5", measure * 9.0 + beat * 2.5, beat * 1.5),
        ("G#5", measure * 10.0, beat * 3.0),
        ("A5", measure * 11.0, beat * 4.0),
        ("C6", measure * 12.0, beat * 3.0),
        ("C#6", measure * 13.0, beat * 4.5),
    ]
    for n_name, start_t, dur_t in lead_notes:
        f = note_freq(n_name)
        synth_expressive_flute(buf, start_t, dur_t, f, gain=0.22, pan=0.0)

    # 5. Crystal Chimes
    synth_bell_chime(buf, 0.0, freq=note_freq("E5"), gain=0.15, pan=0.2)
    synth_bell_chime(buf, measure * 8.0, freq=note_freq("A5"), gain=0.18, pan=-0.2)

    buf.apply_snes_reverb(delay_sec=0.30, feedback=0.40, mix=0.35, damp=0.40)
    buf.write_wav("assets/audio/music/bgm_opening_plan_b.wav")


def main():
    print("=================================================================")
    print(" Mw-fActory: Opening & Title Theme Generator")
    print("=================================================================")
    render_opening_plan_a()
    render_opening_plan_b()
    print("All Opening tracks successfully generated!")

if __name__ == "__main__":
    main()

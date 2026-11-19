#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Thrilling SFX & Dramatic Jingles Generator

Generates:
  - Lasers:
      assets/audio/sfx/se_laser_pierce.wav (Hyper Piercing Beam Laser)
      assets/audio/sfx/se_laser_enemy_sweep.wav (Enemy Heavy Sweeping Laser)
      assets/audio/sfx/se_laser_homing.wav (High-Frequency Homing Laser)
  - Exciting Shots:
      assets/audio/sfx/se_shot_cormii_wide.wav (Cormii 5-Way Wide Shot)
      assets/audio/sfx/se_shot_jiyoza_beam.wav (Jiyoza Focused Photon Beam)
      assets/audio/sfx/se_shot_mafio_wave.wav (Mafio Bio Wave Cannon)
  - Cathartic Destructions:
      assets/audio/sfx/se_destroy_medium.wav (Medium Enemy Heavy Crash Explosion)
      assets/audio/sfx/se_destroy_heavy_chain.wav (Large Enemy Multi-Stage Chain Explosion)
      assets/audio/sfx/se_armor_break.wav (Armor / Shield Shatter Break)
  - Thrilling Jingles:
      assets/audio/jingles/jg004_miniboss.wav (JG-004: Mid-Boss Appearance Alert)
      assets/audio/jingles/jg006_boss_warning.wav (JG-006: Great Boss Alarm Siren & Fanfare)
      assets/audio/jingles/jg011_weapon_unlocked.wav (JG-011: New Weapon & Full Power Triumph)
      assets/audio/jingles/jg012_worldline_shift.wav (JG-012: Worldline Shift & Time Warp)
"""

import math
import struct
import wave
import os

SAMPLE_RATE = 44100
TWO_PI = 2.0 * math.pi

class RandomPRNG:
    def __init__(self, seed=20261121):
        self.state = seed & 0xFFFFFFFF

    def next_float(self):
        self.state = (1664525 * self.state + 1013904223) & 0xFFFFFFFF
        return (self.state / 4294967296.0) * 2.0 - 1.0

def save_wav(file_path, left_samples, right_samples=None, target_peak=0.891):
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    n = len(left_samples)
    left_samples = list(left_samples)
    if right_samples is None:
        right_samples = list(left_samples)
    else:
        right_samples = list(right_samples)

    dc_l = sum(left_samples) / n if n > 0 else 0.0
    dc_r = sum(right_samples) / n if n > 0 else 0.0
    for i in range(n):
        left_samples[i] -= dc_l
        right_samples[i] -= dc_r

    max_peak = 0.0001
    for i in range(n):
        al = abs(left_samples[i])
        ar = abs(right_samples[i])
        if al > max_peak: max_peak = al
        if ar > max_peak: max_peak = ar

    scale = target_peak / max_peak if max_peak > target_peak else 1.0

    with wave.open(file_path, "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for i in range(n):
            l_val = max(-1.0, min(1.0, left_samples[i] * scale))
            r_val = max(-1.0, min(1.0, right_samples[i] * scale))
            frames.extend(struct.pack("<hh", int(l_val * 32767.0), int(r_val * 32767.0)))
        wf.writeframes(frames)
    print(f"  [Created] {file_path} ({n / SAMPLE_RATE:.2f}s, peak: {max_peak:.2f} -> {max_peak*scale:.2f})")


# =============================================================================
# LASERS
# =============================================================================

def generate_se_laser_pierce():
    """貫通ハイパービームレーザー (Cutting-edge piercing laser)."""
    dur = 0.38
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        # High power FM beam with rapid cutting attack
        f = 2400.0 * math.exp(-t * 14.0) + 480.0
        mod = math.sin(TWO_PI * 180.0 * t) * 1.5 * math.exp(-t * 8.0)
        env = (1.0 - math.exp(-t * 200.0)) * math.exp(-t * 9.0)
        sig = math.sin(TWO_PI * f * t + mod) * env * 0.55
        buf[i] = sig
    save_wav("assets/audio/sfx/se_laser_pierce.wav", buf)

def generate_se_laser_enemy_sweep():
    """敵極太薙ぎ払いレーザー (Sub-bass charge buildup to massive sweeping beam)."""
    dur = 0.85
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(12345)
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        if t < 0.25:
            # Low charge buildup
            f = 90.0 + 350.0 * (t / 0.25)
            env = t / 0.25
            sig = math.sin(TWO_PI * f * t) * env * 0.35
        else:
            # Massive roaring beam blast
            t2 = t - 0.25
            f = 520.0 * math.exp(-t2 * 4.0) + 110.0
            noise = prng.next_float()
            lp += 0.4 * (noise - lp)
            env = math.exp(-t2 * 5.0)
            sig = (math.sin(TWO_PI * f * t2) * 0.6 + lp * 0.4) * env * 0.65
        buf[i] = sig
    save_wav("assets/audio/sfx/se_laser_enemy_sweep.wav", buf)

def generate_se_laser_homing():
    """追尾ホーミングレーザー (Curving multi-chirp laser)."""
    dur = 0.28
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 1600.0 + 800.0 * math.sin(TWO_PI * 24.0 * t) * math.exp(-t * 12.0)
        env = (t / 0.02) if t < 0.02 else math.exp(-(t - 0.02) * 16.0)
        sig = math.sin(TWO_PI * f * t) * env * 0.42
        buf[i] = sig
    save_wav("assets/audio/sfx/se_laser_homing.wav", buf)


# =============================================================================
# EXCITING SHOTS
# =============================================================================

def generate_se_shot_cormii_wide():
    """コルミィ 5WAY拡散ショット (Rapid multi-sparkle plasma spread)."""
    dur = 0.20
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f1 = 980.0 * math.exp(-t * 26.0) + 220.0
        f2 = 1320.0 * math.exp(-t * 26.0) + 330.0
        env = math.exp(-t * 20.0)
        sig = (math.sin(TWO_PI * f1 * t) + 0.6 * math.sin(TWO_PI * f2 * t)) * env * 0.46
        buf[i] = sig
    save_wav("assets/audio/sfx/se_shot_cormii_wide.wav", buf)

def generate_se_shot_jiyoza_beam():
    """ジヨーザ 集束貫通フォトンレーザー (Precision high-energy photon beam)."""
    dur = 0.24
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 2200.0 * math.exp(-t * 18.0) + 750.0
        env = math.exp(-t * 15.0)
        pulse = 1.0 + 0.3 * math.sin(TWO_PI * 90.0 * t)
        sig = math.sin(TWO_PI * f * t) * pulse * env * 0.48
        buf[i] = sig
    save_wav("assets/audio/sfx/se_shot_jiyoza_beam.wav", buf)

def generate_se_shot_mafio_wave():
    """マフィオ 波動生体キャノン (Deep bass shockwave cannon)."""
    dur = 0.32
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 240.0 * math.exp(-t * 14.0) + 38.0
        env = (t / 0.03) if t < 0.03 else math.exp(-(t - 0.03) * 11.0)
        sub = math.sin(TWO_PI * f * t) * 0.8 + 0.3 * math.sin(TWO_PI * f * 2.0 * t)
        buf[i] = sub * env * 0.58
    save_wav("assets/audio/sfx/se_shot_mafio_wave.wav", buf)


# =============================================================================
# CATHARTIC DESTRUCTION SOUNDS
# =============================================================================

def generate_se_destroy_medium():
    """中型敵撃破爆発 (Heavy crash explosion with sub-rumble)."""
    dur = 0.65
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(54321)
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        noise = prng.next_float()
        lp += 0.35 * (noise - lp)
        sub = math.sin(TWO_PI * (160.0 * math.exp(-t * 14.0) + 40.0) * t) * 0.5
        env = math.exp(-t * 7.5)
        sig = (sub + lp * 0.7) * env * 0.60
        buf[i] = sig
    save_wav("assets/audio/sfx/se_destroy_medium.wav", buf)

def generate_se_destroy_heavy_chain():
    """大型敵連続誘爆 (Multi-stage roaring chain explosion)."""
    dur = 1.60
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(998877)

    # 4 sequential explosions at t=0.0, 0.22, 0.48, 0.75
    bursts = [0.0, 0.22, 0.48, 0.75]
    for b_idx, b_start in enumerate(bursts):
        s_idx = int(b_start * SAMPLE_RATE)
        c_len = min(n - s_idx, int(0.8 * SAMPLE_RATE))
        lp = 0.0
        weight = 0.7 + 0.15 * b_idx
        for j in range(c_len):
            t = j / SAMPLE_RATE
            noise = prng.next_float()
            lp += 0.4 * (noise - lp)
            sub = math.sin(TWO_PI * (180.0 * math.exp(-t * 16.0) + 38.0) * t) * 0.45
            env = math.exp(-t * 6.5)
            buf[s_idx + j] += (sub + lp * 0.6) * env * weight * 0.35

    save_wav("assets/audio/sfx/se_destroy_heavy_chain.wav", buf)

def generate_se_armor_break():
    """装甲破壊・シールドブレイク (Crisp glass/metal shatter)."""
    dur = 0.42
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(776655)
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        # High metallic shatter
        shatter = (math.sin(TWO_PI * 3400.0 * t) + 0.5 * math.sin(TWO_PI * 5200.0 * t)) * math.exp(-t * 30.0)
        noise = prng.next_float()
        lp += 0.4 * (noise - lp)
        env = math.exp(-t * 12.0)
        sig = (shatter * 0.5 + lp * 0.5) * env * 0.52
        buf[i] = sig
    save_wav("assets/audio/sfx/se_armor_break.wav", buf)


# =============================================================================
# THRILLING JINGLES
# =============================================================================

def generate_jg004_miniboss():
    """JG-004: 小ボス出現 (Mid-Boss alert: tension flare & fast horn fanfare)."""
    dur = 2.40
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n

    # Alarm pulse at t=0.0 & 0.25s
    for a_t in [0.0, 0.25]:
        a_idx = int(a_t * SAMPLE_RATE)
        for j in range(min(n - a_idx, int(0.20 * SAMPLE_RATE))):
            t = j / SAMPLE_RATE
            f = 880.0 if a_t == 0.0 else 1174.66
            sig = math.sin(TWO_PI * f * t) * math.exp(-t * 18.0) * 0.35
            l_buf[a_idx + j] += sig
            r_buf[a_idx + j] += sig

    # Urgent horn fanfare at t=0.55s (G4 -> C#5 -> D5 -> G5)
    fanfare = [(392.00, 0.55, 0.20), (554.37, 0.75, 0.20), (587.33, 0.95, 0.25), (783.99, 1.20, 1.10)]
    for freq, s_t, d_t in fanfare:
        s_idx = int(s_t * SAMPLE_RATE)
        c_len = min(n - s_idx, int(d_t * SAMPLE_RATE))
        for j in range(c_len):
            t = j / SAMPLE_RATE
            env = (1.0 - math.exp(-t * 60.0)) * math.exp(-t * 2.2)
            ph = TWO_PI * freq * t
            sig = (math.sin(ph) + 0.45 * math.sin(2.0 * ph) + 0.2 * math.sin(3.0 * ph)) * env * 0.36
            l_buf[s_idx + j] += sig
            r_buf[s_idx + j] += sig

    # Heavy impact on climax note
    c_idx = int(1.20 * SAMPLE_RATE)
    for j in range(min(n - c_idx, int(0.9 * SAMPLE_RATE))):
        t = j / SAMPLE_RATE
        sig = math.sin(TWO_PI * (110.0 * math.exp(-t * 18.0) + 45.0) * t) * math.exp(-t * 4.5) * 0.45
        l_buf[c_idx + j] += sig
        r_buf[c_idx + j] += sig

    save_wav("assets/audio/jingles/jg004_miniboss.wav", l_buf, r_buf)

def generate_jg006_boss_warning():
    """JG-006: 大ボス出現警告 (Dread alarm siren & monumental brass fanfare)."""
    dur = 3.40
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n

    # Dual alternating sirens (t=0.0 -> 1.2)
    for i in range(int(1.25 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        f_siren = 680.0 + 320.0 * math.sin(TWO_PI * 4.0 * t)
        sig = math.sin(TWO_PI * f_siren * t) * 0.28
        l_buf[i] += sig * 0.8
        r_buf[i] += sig * 1.0

    # Monumental Boss Entrance Chords at t=1.2s (Gm -> Eb -> D)
    chords = [
        (1.20, [196.00, 293.66, 349.23, 466.16], 0.65), # G minor
        (1.85, [155.56, 233.08, 311.13, 466.16], 0.65), # Eb
        (2.50, [146.83, 220.00, 293.66, 369.99], 0.85), # D major
    ]
    for s_t, chord_freqs, dur_c in chords:
        s_idx = int(s_t * SAMPLE_RATE)
        c_len = min(n - s_idx, int(dur_c * SAMPLE_RATE))
        for j in range(c_len):
            t = j / SAMPLE_RATE
            env = (1.0 - math.exp(-t * 50.0)) * math.exp(-t * 2.0)
            sig = 0.0
            for freq in chord_freqs:
                ph = TWO_PI * freq * t
                sig += (math.sin(ph) + 0.4 * math.sin(2.0 * ph)) * 0.12
            l_buf[s_idx + j] += sig * env
            r_buf[s_idx + j] += sig * env

    save_wav("assets/audio/jingles/jg006_boss_warning.wav", l_buf, r_buf)

def generate_jg011_weapon_unlocked():
    """JG-011: 新武器完成・パワー全開 (Triumphant weapon unlock fanfare)."""
    dur = 2.60
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n

    # Rapid ascending power arpeggio (C4 -> E4 -> G4 -> C5 -> E5 -> G5)
    arps = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99]
    for s, f in enumerate(arps):
        s_idx = int(s * 0.07 * SAMPLE_RATE)
        for j in range(min(n - s_idx, int(0.35 * SAMPLE_RATE))):
            t = j / SAMPLE_RATE
            sig = (math.sin(TWO_PI * f * t) + 0.3 * math.sin(TWO_PI * f * 2.0 * t)) * math.exp(-t * 14.0) * 0.28
            l_buf[s_idx + j] += sig
            r_buf[s_idx + j] += sig

    # Major triumph chord at t=0.45s (C Major)
    c_idx = int(0.45 * SAMPLE_RATE)
    chord = [523.25, 659.25, 783.99, 1046.50]
    for j in range(min(n - c_idx, int(2.0 * SAMPLE_RATE))):
        t = j / SAMPLE_RATE
        env = (1.0 - math.exp(-t * 40.0)) * math.exp(-t * 2.0)
        sig = 0.0
        for f in chord:
            sig += (math.sin(TWO_PI * f * t) + 0.35 * math.sin(TWO_PI * f * 2.0 * t)) * 0.10
        l_buf[c_idx + j] += sig * env
        r_buf[c_idx + j] += sig * env

    save_wav("assets/audio/jingles/jg011_weapon_unlocked.wav", l_buf, r_buf)

def generate_jg012_worldline_shift():
    """JG-012: 世界線移動 (Time warp / dimensional shift sweep)."""
    dur = 2.80
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n

    for i in range(n):
        t = i / SAMPLE_RATE
        # Dimension warping sweep
        f = 440.0 + 880.0 * math.sin(TWO_PI * 1.5 * t) + 200.0 * math.cos(TWO_PI * 8.0 * t)
        env = math.sin(math.pi * (t / dur))
        p = math.sin(TWO_PI * 3.5 * t)
        theta = (p + 1.0) * math.pi / 4.0
        sig = (math.sin(TWO_PI * f * t) + 0.4 * math.sin(TWO_PI * f * 2.0 * t)) * env * 0.42
        l_buf[i] += sig * math.cos(theta)
        r_buf[i] += sig * math.sin(theta)

    save_wav("assets/audio/jingles/jg012_worldline_shift.wav", l_buf, r_buf)


def main():
    print("=================================================================")
    print(" Mw-fActory: Thrilling SFX & Dramatic Jingles Generator")
    print("=================================================================")
    print("--- Lasers ---")
    generate_se_laser_pierce()
    generate_se_laser_enemy_sweep()
    generate_se_laser_homing()

    print("--- Exciting Shots ---")
    generate_se_shot_cormii_wide()
    generate_se_shot_jiyoza_beam()
    generate_se_shot_mafio_wave()

    print("--- Cathartic Destructions ---")
    generate_se_destroy_medium()
    generate_se_destroy_heavy_chain()
    generate_se_armor_break()

    print("--- Thrilling Jingles ---")
    generate_jg004_miniboss()
    generate_jg006_boss_warning()
    generate_jg011_weapon_unlocked()
    generate_jg012_worldline_shift()
    print("All thrilling SFX and jingles generated successfully!")

if __name__ == "__main__":
    main()

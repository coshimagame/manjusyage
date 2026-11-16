#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Expanded SFX & Departure Jingles Generator

Generates:
  - Jingles:
      assets/audio/jingles/jg001_title.wav (Title Appearance)
      assets/audio/jingles/jg003_stage_start.wav (Stage Launch / Departure)
      assets/audio/jingles/jg007_stage_clear.wav (Stage Clear Victory)
  - Character Specific SFX:
      assets/audio/sfx/se_cormii_charge.wav (Cormii Charge Max Output)
      assets/audio/sfx/se_cormii_omikuji.wav (Cormii Fortune Omikuji)
      assets/audio/sfx/se_jiyoza_analyze.wav (Jiyoza Analysis Complete)
      assets/audio/sfx/se_jiyoza_barrier.wav (Jiyoza Analysis Barrier)
      assets/audio/sfx/se_mafio_predation.wav (Mafio Predation / Bite)
      assets/audio/sfx/se_mafio_absorb.wav (Mafio Power Absorb)
  - Core Combat & System SFX:
      assets/audio/sfx/se_player_hit.wav (Player Shield Hit / Damage)
      assets/audio/sfx/se_enemy_shot.wav (Enemy Bullet Fire)
      assets/audio/sfx/se_enemy_destroy_small.wav (Small Enemy Explosion)
      assets/audio/sfx/se_item_get.wav (Item Pickup / Powerup)
      assets/audio/sfx/se_menu_cursor.wav (Menu Move)
      assets/audio/sfx/se_menu_select.wav (Menu Confirm)
      assets/audio/sfx/se_menu_cancel.wav (Menu Cancel)
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
# JINGLES
# =============================================================================

def generate_jg001_title():
    """JG-001: タイトル表示ジングル (Sho chord + crystal bell flourish)."""
    dur = 2.6
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n

    # Sho chord: D4, F#4, A4, E5 (warm, sacred, blooming spider lily)
    chord = [293.66, 369.99, 440.0, 659.25]
    for i in range(n):
        t = i / SAMPLE_RATE
        env = (1.0 - math.exp(-t * 8.0)) * math.exp(-t * 0.9)
        sig = 0.0
        for f in chord:
            sig += 0.25 * math.sin(TWO_PI * f * t) + 0.10 * math.sin(TWO_PI * f * 2.0 * t)
        l_buf[i] += sig * env * 0.45
        r_buf[i] += sig * env * 0.45

    # Ascending crystal chime flourish at t=0.4s
    notes = [587.33, 739.99, 880.0, 1174.66, 1479.98, 1760.0]
    for step, f in enumerate(notes):
        start_idx = int((0.4 + step * 0.08) * SAMPLE_RATE)
        for i in range(start_idx, min(n, start_idx + int(1.2 * SAMPLE_RATE))):
            t = (i - start_idx) / SAMPLE_RATE
            env = math.exp(-t * 4.5)
            sig = (math.sin(TWO_PI * f * t) + 0.35 * math.sin(TWO_PI * f * 2.76 * t) * math.exp(-t * 6.0)) * env * 0.15
            pan = -0.4 + step * 0.16
            theta = (pan + 1.0) * math.pi / 4.0
            l_buf[i] += sig * math.cos(theta)
            r_buf[i] += sig * math.sin(theta)

    save_wav("assets/audio/jingles/jg001_title.wav", l_buf, r_buf)

def generate_jg003_stage_start():
    """JG-003: ステージ開始・発進ジングル (Engine ignition, boost surge, heroic brass motif)."""
    dur = 2.8
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n
    prng = RandomPRNG(19830303)

    # 1. Jet engine ignition build-up (filtered noise sweep t=0.0 -> 0.8)
    lp = 0.0
    for i in range(int(1.2 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        cutoff = 0.05 + 0.40 * (t / 1.2)
        noise = prng.next_float()
        lp += cutoff * (noise - lp)
        env = (t / 0.8) if t < 0.8 else math.exp(-(t - 0.8) * 3.0)
        l_buf[i] += lp * env * 0.28
        r_buf[i] += lp * env * 0.28

    # 2. Heroic SFC Brass departure fanfare at t=0.6s (D -> G -> A -> D high)
    fanfare = [
        (293.66, 0.60, 0.18),  # D4
        (392.00, 0.80, 0.18),  # G4
        (440.00, 1.00, 0.22),  # A4
        (587.33, 1.25, 0.95),  # D5 Climax
    ]
    for freq, s_t, d_t in fanfare:
        s_idx = int(s_t * SAMPLE_RATE)
        c_len = min(n - s_idx, int(d_t * SAMPLE_RATE))
        for j in range(c_len):
            t = j / SAMPLE_RATE
            env = (1.0 - math.exp(-t * 80.0)) * math.exp(-t * 2.2)
            ph = TWO_PI * freq * t
            sig = (math.sin(ph) + 0.5 * math.sin(2.0 * ph) + 0.25 * math.sin(3.0 * ph)) * env * 0.35
            l_buf[s_idx + j] += sig * 0.9
            r_buf[s_idx + j] += sig * 1.0

    # 3. Boost ignition explosion at t=1.25s (Departure burst)
    boost_start = int(1.25 * SAMPLE_RATE)
    for j in range(min(n - boost_start, int(1.4 * SAMPLE_RATE))):
        t = j / SAMPLE_RATE
        f = 130.0 * math.exp(-t * 12.0) + 38.0
        env = math.exp(-t * 4.0)
        sig = math.sin(TWO_PI * f * t) * env * 0.42
        l_buf[boost_start + j] += sig
        r_buf[boost_start + j] += sig

    save_wav("assets/audio/jingles/jg003_stage_start.wav", l_buf, r_buf)

def generate_jg007_stage_clear():
    """JG-007: ステージクリアジングル (Victory fanfare with taiko & koto resolution)."""
    dur = 3.6
    n = int(dur * SAMPLE_RATE)
    l_buf = [0.0] * n
    r_buf = [0.0] * n

    # Victory arpeggio (D -> F# -> A -> B -> D)
    notes = [
        (293.66, 0.00, 0.25),
        (369.99, 0.25, 0.25),
        (440.00, 0.50, 0.25),
        (493.88, 0.75, 0.25),
        (587.33, 1.00, 0.60),
        # Final chord
        (440.00, 1.65, 1.60),
        (587.33, 1.65, 1.60),
        (739.99, 1.65, 1.60),
    ]
    for freq, s_t, d_t in notes:
        s_idx = int(s_t * SAMPLE_RATE)
        c_len = min(n - s_idx, int(d_t * SAMPLE_RATE))
        for j in range(c_len):
            t = j / SAMPLE_RATE
            env = (1.0 - math.exp(-t * 50.0)) * math.exp(-t * 2.0)
            ph = TWO_PI * freq * t
            sig = (math.sin(ph) + 0.4 * math.sin(2.0 * ph) + 0.15 * math.sin(3.0 * ph)) * env * 0.28
            l_buf[s_idx + j] += sig
            r_buf[s_idx + j] += sig

    # Taiko victory rolls at 1.0s and 1.65s
    for roll_t in [1.00, 1.65]:
        r_idx = int(roll_t * SAMPLE_RATE)
        for j in range(min(n - r_idx, int(0.8 * SAMPLE_RATE))):
            t = j / SAMPLE_RATE
            f = 95.0 * math.exp(-t * 18.0) + 45.0
            env = math.exp(-t * 5.0)
            sig = math.sin(TWO_PI * f * t) * env * 0.38
            l_buf[r_idx + j] += sig
            r_buf[r_idx + j] += sig

    save_wav("assets/audio/jingles/jg007_stage_clear.wav", l_buf, r_buf)


# =============================================================================
# CHARACTER SPECIFIC SFX
# =============================================================================

def generate_se_cormii_charge():
    """Cormii: フルパワーチャージ完了音 (Rising plasma resonance)."""
    dur = 0.45
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        # Rapid rising chirp 220Hz -> 1800Hz with power pulse
        f = 220.0 + 1580.0 * (t / dur) ** 1.8
        mod = math.sin(TWO_PI * 45.0 * t) * 0.3
        env = (t / 0.1) if t < 0.1 else (1.0 - (t - 0.1) / (dur - 0.1)) ** 0.5
        sig = math.sin(TWO_PI * f * (1.0 + mod) * t) * env * 0.48
        buf[i] = sig
    save_wav("assets/audio/sfx/se_cormii_charge.wav", buf)

def generate_se_cormii_omikuji():
    """Cormii: 開運おみくじ・アイテム発動 (Shinto bell sparkle + lucky chime)."""
    dur = 0.38
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    chimes = [1046.50, 1318.51, 1567.98, 2093.00] # C6, E6, G6, C7
    for step, f in enumerate(chimes):
        s_idx = int(step * 0.06 * SAMPLE_RATE)
        for i in range(s_idx, min(n, s_idx + int(0.20 * SAMPLE_RATE))):
            t = (i - s_idx) / SAMPLE_RATE
            env = math.exp(-t * 18.0)
            buf[i] += math.sin(TWO_PI * f * t) * env * 0.22
    save_wav("assets/audio/sfx/se_cormii_omikuji.wav", buf)

def generate_se_jiyoza_analyze():
    """Jiyoza: 解析スキャン完了 (High tech analytical dual beep + lockon)."""
    dur = 0.30
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f1 = 1760.0 if t < 0.12 else 2637.02
        f2 = 2200.0 if t < 0.12 else 3520.00
        env = math.exp(-(t % 0.12) * 22.0)
        sig = (math.sin(TWO_PI * f1 * t) + 0.6 * math.sin(TWO_PI * f2 * t)) * env * 0.35
        buf[i] = sig
    save_wav("assets/audio/sfx/se_jiyoza_analyze.wav", buf)

def generate_se_jiyoza_barrier():
    """Jiyoza: 解析バリア展開 (Futuristic crystal shield hum)."""
    dur = 0.40
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        env = (1.0 - math.exp(-t * 40.0)) * math.exp(-t * 4.5)
        f = 520.0 + 80.0 * math.sin(TWO_PI * 18.0 * t)
        sig = (math.sin(TWO_PI * f * t) + 0.4 * math.sin(TWO_PI * f * 2.0 * t)) * env * 0.42
        buf[i] = sig
    save_wav("assets/audio/sfx/se_jiyoza_barrier.wav", buf)

def generate_se_mafio_predation():
    """Mafio: 捕食音 (Vacuum suction + bio crunch)."""
    dur = 0.32
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(19890101)
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        # Suction down to heavy crunch
        f = 350.0 * math.exp(-t * 12.0) + 60.0
        env = (t / 0.06) if t < 0.06 else math.exp(-(t - 0.06) * 10.0)
        noise = prng.next_float()
        lp += 0.3 * (noise - lp)
        sig = (math.sin(TWO_PI * f * t) * 0.6 + lp * 0.4) * env * 0.55
        buf[i] = sig
    save_wav("assets/audio/sfx/se_mafio_predation.wav", buf)

def generate_se_mafio_absorb():
    """Mafio: 能力獲得・消化完了 (Bio mutation pulse + sub power surge)."""
    dur = 0.38
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 75.0 + 260.0 * (t / dur)
        env = math.sin(math.pi * (t / dur))
        pulse = 1.0 + 0.35 * math.sin(TWO_PI * 32.0 * t)
        sig = math.sin(TWO_PI * f * t) * pulse * env * 0.50
        buf[i] = sig
    save_wav("assets/audio/sfx/se_mafio_absorb.wav", buf)


# =============================================================================
# CORE COMBAT & SYSTEM SFX
# =============================================================================

def generate_se_player_hit():
    """自機被弾・シールド損傷 (Dull metallic impact + shield alarm)."""
    dur = 0.28
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(1234567)
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        noise = prng.next_float()
        lp += 0.25 * (noise - lp)
        impact = math.sin(TWO_PI * 140.0 * math.exp(-t * 20.0) * t) * 0.6
        env = math.exp(-t * 16.0)
        sig = (impact + lp * 0.5) * env * 0.55
        buf[i] = sig
    save_wav("assets/audio/sfx/se_player_hit.wav", buf)

def generate_se_enemy_shot():
    """敵弾発射音 (Classic 8-bit/SFC laser chirp)."""
    dur = 0.12
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 1200.0 * math.exp(-t * 28.0) + 180.0
        env = math.exp(-t * 22.0)
        sig = math.sin(TWO_PI * f * t) * env * 0.35
        buf[i] = sig
    save_wav("assets/audio/sfx/se_enemy_shot.wav", buf)

def generate_se_enemy_destroy_small():
    """小型敵撃破爆発 (Punchy crisp explosion)."""
    dur = 0.35
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    prng = RandomPRNG(9876543)
    lp = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        noise = prng.next_float()
        lp += 0.35 * (noise - lp)
        sub = math.sin(TWO_PI * 180.0 * math.exp(-t * 16.0) * t)
        env = math.exp(-t * 11.0)
        sig = (sub * 0.4 + lp * 0.6) * env * 0.50
        buf[i] = sig
    save_wav("assets/audio/sfx/se_enemy_destroy_small.wav", buf)

def generate_se_item_get():
    """アイテム取得・パワーアップ音 (Bright two-tone chime)."""
    dur = 0.25
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 1174.66 if t < 0.10 else 1760.00 # D6 -> A6
        env = math.exp(-(t % 0.10) * 20.0)
        sig = (math.sin(TWO_PI * f * t) + 0.3 * math.sin(TWO_PI * f * 2.0 * t)) * env * 0.35
        buf[i] = sig
    save_wav("assets/audio/sfx/se_item_get.wav", buf)

def generate_se_menu_cursor():
    """メニュー移動 (Clean crisp blip)."""
    dur = 0.045
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 880.0
        env = math.exp(-t * 70.0)
        buf[i] = math.sin(TWO_PI * f * t) * env * 0.30
    save_wav("assets/audio/sfx/se_menu_cursor.wav", buf)

def generate_se_menu_select():
    """メニュー決定 (Positive ascending double blip)."""
    dur = 0.12
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 987.77 if t < 0.05 else 1318.51
        env = math.exp(-(t % 0.05) * 35.0)
        buf[i] = math.sin(TWO_PI * f * t) * env * 0.35
    save_wav("assets/audio/sfx/se_menu_select.wav", buf)

def generate_se_menu_cancel():
    """メニューキャンセル (Descending double blip)."""
    dur = 0.10
    n = int(dur * SAMPLE_RATE)
    buf = [0.0] * n
    for i in range(n):
        t = i / SAMPLE_RATE
        f = 1046.50 if t < 0.045 else 783.99
        env = math.exp(-(t % 0.045) * 40.0)
        buf[i] = math.sin(TWO_PI * f * t) * env * 0.32
    save_wav("assets/audio/sfx/se_menu_cancel.wav", buf)


def main():
    print("=================================================================")
    print(" Mw-fActory: Expanded Jingles & Sound Effects Generator")
    print("=================================================================")
    print("--- Jingles ---")
    generate_jg001_title()
    generate_jg003_stage_start()
    generate_jg007_stage_clear()

    print("--- Character SFX ---")
    generate_se_cormii_charge()
    generate_se_cormii_omikuji()
    generate_se_jiyoza_analyze()
    generate_se_jiyoza_barrier()
    generate_se_mafio_predation()
    generate_se_mafio_absorb()

    print("--- Core Combat & System SFX ---")
    generate_se_player_hit()
    generate_se_enemy_shot()
    generate_se_enemy_destroy_small()
    generate_se_item_get()
    generate_se_menu_cursor()
    generate_se_menu_select()
    generate_se_menu_cancel()
    print("All expanded SFX & Jingles generated successfully!")

if __name__ == "__main__":
    main()

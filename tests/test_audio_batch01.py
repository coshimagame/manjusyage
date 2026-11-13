#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Audio Quality & Inspection Test
Verifies format, headers, duration, peak amplitudes, and clipping.
"""

import os
import wave
import struct

EXPECTED_FILES = [
    ("assets/audio/music/bgm_stage01_plan_a.wav", 44100, 2, 2, 47.0, 49.0),
    ("assets/audio/music/bgm_stage01_plan_b.wav", 44100, 2, 2, 49.0, 52.0),
    ("assets/audio/music/bgm_boss01_plan_a.wav",  44100, 2, 2, 44.0, 47.0),
    ("assets/audio/music/bgm_boss01_plan_b.wav",  44100, 2, 2, 43.0, 46.0),
    ("assets/audio/jingles/jg002_sortie.wav",     44100, 2, 2, 3.0, 4.0),
    ("assets/audio/sfx/se_shot_cormii.wav",       44100, 2, 2, 0.10, 0.20),
    ("assets/audio/sfx/se_shot_jiyoza.wav",       44100, 2, 2, 0.10, 0.20),
    ("assets/audio/sfx/se_shot_mafio.wav",        44100, 2, 2, 0.15, 0.25),
    ("assets/audio/sfx/se_boss_warning.wav",      44100, 2, 2, 0.70, 1.00),
    ("assets/audio/sfx/se_boss_destroy.wav",      44100, 2, 2, 2.50, 3.20),
]

def test_audio():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    print(f"=== Running Audio QA Test on Batch 01 ({root}) ===")
    all_passed = True

    for rel_path, exp_sr, exp_ch, exp_sw, min_dur, max_dur in EXPECTED_FILES:
        full_path = os.path.join(root, rel_path)
        if not os.path.exists(full_path):
            print(f"FAIL: File missing: {rel_path}")
            all_passed = False
            continue

        with wave.open(full_path, "rb") as wf:
            n_ch = wf.getnchannels()
            sw = wf.getsampwidth()
            sr = wf.getframerate()
            n_frames = wf.getnframes()
            dur = n_frames / sr

            frames = wf.readframes(n_frames)
            num_samples = n_frames * n_ch
            samples = struct.unpack(f"<{num_samples}h", frames)

            max_val = max(abs(s) for s in samples)
            peak_db = 20.0 * (0.0001 if max_val == 0 else max_val / 32768.0)
            dc_offset = sum(samples) / num_samples

            # Check criteria
            ch_ok = (n_ch == exp_ch)
            sw_ok = (sw == exp_sw)
            sr_ok = (sr == exp_sr)
            dur_ok = (min_dur <= dur <= max_dur)
            clip_ok = (max_val <= 32760) # Ensure no 0dBFS harsh clipping
            dc_ok = (abs(dc_offset) < 50.0)

            status = "PASS" if (ch_ok and sw_ok and sr_ok and dur_ok and clip_ok and dc_ok) else "WARN/FAIL"
            if status != "PASS":
                all_passed = False

            print(f"[{status}] {os.path.basename(rel_path):<25} | {dur:5.2f}s | {sr}Hz | {n_ch}ch {sw*8}bit | Peak: {max_val/32768.0:0.2f} | DC: {dc_offset:+5.1f}")

    if all_passed:
        print("\n=== ALL AUDIO ASSETS PASSED QUALITY INSPECTION ===")
    else:
        print("\n=== SOME ASSETS FAILED INSPECTION ===")
    return all_passed

if __name__ == "__main__":
    success = test_audio()
    exit(0 if success else 1)

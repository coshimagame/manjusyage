#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Complete Musical MIDI Exporter

Exports all 10 BGM compositions into Standard MIDI Files (.mid / SMF Format 1):
  - assets/audio/midi/bgm_opening_plan_a.mid (曼珠沙華 〜 記憶の深淵)
  - assets/audio/midi/bgm_opening_plan_b.mid (曼珠沙華 〜 輪廻のプロローグ)
  - assets/audio/midi/bgm_stage01_plan_a.mid (赤い残響 〜 幽玄の飛翔)
  - assets/audio/midi/bgm_stage01_plan_b.mid (赤い残響 〜 緋色の鼓動)
  - assets/audio/midi/bgm_boss01_plan_a.mid  (生体中枢 〜 脈動する境界)
  - assets/audio/midi/bgm_boss01_plan_b.mid  (輪廻の狂詩曲 〜 死線突破)
  - assets/audio/midi/bgm_stage02_plan_a.mid (追憶の海 〜 水底の残照)
  - assets/audio/midi/bgm_stage02_plan_b.mid (追憶の海 〜 潮流のセレナーデ)
  - assets/audio/midi/bgm_stage03_plan_a.mid (孤独な庭 〜 錆びた歯車と曼珠沙華)
  - assets/audio/midi/bgm_stage03_plan_b.mid (孤独な庭 〜 静寂の回廊)
"""

import os
from midi_writer import MidiSong, note_to_midi

MIDI_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "midi"))
PPQN = 480

# =============================================================================
# 1. OPENING PLAN A: 曼珠沙華 〜 記憶の深淵 (Abyss of Memories)
# =============================================================================
def export_opening_plan_a():
    song = MidiSong(bpm=82, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Shakuhachi / Flute)", channel=0, program=77)
    t_cello = song.add_track(name="Counter (Cello Solo)", channel=1, program=42)
    t_harp = song.add_track(name="Arpeggio (Koto / Harp)", channel=2, program=46)
    t_pad = song.add_track(name="Pad (Sho / Strings)", channel=3, program=49)
    t_bass = song.add_track(name="Bass (Sub / Timpani)", channel=4, program=43)

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
        ["D2", "A2", "D3", "F#3"],   # D major resolve
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        # Pad chord
        for n_str in c_notes:
            t_pad.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str), velocity=70)

        # Harp arpeggios (8 8th-notes)
        for step in range(8):
            n_str = c_notes[step % len(c_notes)]
            p = note_to_midi(n_str)
            if p: p += 12
            t_harp.add_note(m_tick + step * (ticks_per_beat // 2), int(ticks_per_beat * 0.9), p, velocity=85)

        # Bass root
        t_bass.add_note(m_tick, ticks_per_measure - 40, note_to_midi(c_notes[0]), velocity=95)

    # Main Lead
    lead_notes = [
        ("A4", 0.0, 3.0), ("G4", 3.0, 1.0),
        ("F4", 4.0, 2.5), ("E4", 6.5, 1.5),
        ("D4", 8.0, 3.5),
        ("E4", 12.0, 3.0),
        ("D5", 16.0, 2.0), ("E5", 18.0, 1.0), ("F5", 19.0, 1.0),
        ("G5", 20.0, 2.5), ("F5", 22.5, 1.5),
        ("E5", 24.0, 2.5), ("C5", 26.5, 1.5),
        ("A4", 28.0, 4.0),
        ("Bb5", 32.0, 2.0), ("A5", 34.0, 1.0), ("G5", 35.0, 1.0),
        ("F5", 36.0, 2.5), ("D5", 38.5, 1.5),
        ("E5", 40.0, 3.0), ("C#5", 43.0, 1.0),
        ("D5", 44.0, 4.0),
        ("F5", 48.0, 2.0), ("E5", 50.0, 2.0),
        ("F#5", 52.0, 4.5),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=105)

    # Cello Counter
    cello_notes = [
        ("D3", 16.0, 2.5), ("F3", 18.5, 1.5),
        ("G3", 20.0, 2.5), ("Bb3", 22.5, 1.5),
        ("C3", 24.0, 2.5), ("E3", 26.5, 1.5),
        ("F3", 28.0, 4.0),
        ("G3", 32.0, 2.5), ("Bb3", 34.5, 1.5),
        ("A3", 36.0, 2.5), ("F3", 38.5, 1.5),
        ("E3", 40.0, 3.5),
        ("D3", 44.0, 4.0),
    ]
    for n_name, start_beat, dur_beat in cello_notes:
        t_cello.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=88)

    song.save(os.path.join(MIDI_DIR, "bgm_opening_plan_a.mid"))

# =============================================================================
# 2. OPENING PLAN B: 曼珠沙華 〜 輪廻のプロローグ (Prologue of Reincarnation)
# =============================================================================
def export_opening_plan_b():
    song = MidiSong(bpm=96, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Flute)", channel=0, program=73)
    t_pad = song.add_track(name="Pad (Choir Pad)", channel=1, program=52)
    t_arp = song.add_track(name="Arpeggio (Crystal E.Piano)", channel=2, program=4)
    t_bass = song.add_track(name="Bass (Finger Bass)", channel=3, program=33)

    chords = [
        ["A2", "C3", "E3", "A3"],
        ["F2", "A2", "C3", "F3"],
        ["C3", "E3", "G3", "C4"],
        ["G2", "B2", "D3", "G3"],
        ["A2", "C3", "E3", "A3"],
        ["F2", "A2", "C3", "F3"],
        ["D2", "F2", "A2", "D3"],
        ["E2", "G#2", "B2", "E3"],
        ["F2", "A2", "C3", "F3"],
        ["G2", "B2", "D3", "G3"],
        ["E2", "G#2", "B2", "E3"],
        ["A2", "C3", "E3", "A3"],
        ["F2", "C3", "F3", "A3"],
        ["A2", "E3", "A3", "C#4"],
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_pad.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str), velocity=72)
        # 16th Arpeggios
        for step in range(16):
            n_str = c_notes[step % len(c_notes)]
            p = note_to_midi(n_str)
            if p: p += 12
            t_arp.add_note(m_tick + step * (ticks_per_beat // 4), ticks_per_beat // 4 - 5, p, velocity=75)
        # Bass
        t_bass.add_note(m_tick, ticks_per_measure - 20, note_to_midi(c_notes[0]), velocity=90)

    lead_notes = [
        ("E5", 0.0, 2.0), ("D5", 2.0, 1.0), ("C5", 3.0, 1.0),
        ("A4", 4.0, 2.5), ("C5", 6.5, 1.5),
        ("G4", 8.0, 3.5),
        ("B4", 12.0, 3.0),
        ("C5", 16.0, 2.0), ("D5", 18.0, 1.0), ("E5", 19.0, 1.0),
        ("F5", 20.0, 2.5), ("A5", 22.5, 1.5),
        ("D5", 24.0, 3.0),
        ("E5", 28.0, 3.5),
        ("A5", 32.0, 2.0), ("G5", 34.0, 1.0), ("F5", 35.0, 1.0),
        ("G5", 36.0, 2.5), ("E5", 38.5, 1.5),
        ("G#5", 40.0, 3.0),
        ("A5", 44.0, 4.0),
        ("C6", 48.0, 3.0),
        ("C#6", 52.0, 4.5),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=100)

    song.save(os.path.join(MIDI_DIR, "bgm_opening_plan_b.mid"))

# =============================================================================
# 3. STAGE 1 PLAN A: 赤い残響 〜 幽玄の飛翔 (Stage 1 A)
# =============================================================================
def export_stage01_plan_a():
    song = MidiSong(bpm=156, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Hichiriki / Synth Lead)", channel=0, program=81)
    t_brass = song.add_track(name="Layer (Synth Brass)", channel=1, program=62)
    t_strings = song.add_track(name="Pad (Strings)", channel=2, program=48)
    t_bass = song.add_track(name="Bass (FM Slap Bass)", channel=3, program=36)
    t_drums = song.add_track(name="Drums (Rock Kit)", channel=9, program=0)

    chords = [
        ["D3", "F3", "A3"],    # Dm
        ["Bb2", "D3", "F3"],   # Bb
        ["C3", "E3", "G3"],    # C
        ["A2", "C#3", "E3"],   # A
        ["D3", "F3", "A3"],    # Dm
        ["G2", "Bb2", "D3"],   # Gm
        ["C3", "E3", "G3"],    # C
        ["F2", "A2", "C3"],    # F
        ["Bb2", "D3", "F3"],   # Bb
        ["G2", "Bb2", "D3"],   # Gm
        ["A2", "C#3", "E3"],   # A
        ["D3", "F3", "A3"],    # Dm
        ["Bb2", "D3", "F3"],   # Bb
        ["C3", "E3", "G3"],    # C
        ["D3", "F#3", "A3"],   # D Major resolve
        ["D3", "A3", "D4"],    # D Power chord
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        # Strings pad
        for n_str in c_notes:
            t_strings.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str) + 12, velocity=75)

        # 8th note driving bass
        root_midi = note_to_midi(c_notes[0])
        for b in range(8):
            t_bass.add_note(m_tick + b * (ticks_per_beat // 2), (ticks_per_beat // 2) - 10, root_midi, velocity=100)

        # Drums (Kick: 36, Snare: 38, Closed Hat: 42, Crash: 49)
        t_drums.add_note(m_tick, 100, 36, velocity=110) # Kick 1
        t_drums.add_note(m_tick + ticks_per_beat, 100, 38, velocity=105) # Snare 2
        t_drums.add_note(m_tick + ticks_per_beat * 2, 100, 36, velocity=105) # Kick 3
        t_drums.add_note(m_tick + ticks_per_beat * 3, 100, 38, velocity=105) # Snare 4
        for h in range(8):
            t_drums.add_note(m_tick + h * (ticks_per_beat // 2), 60, 42, velocity=80)
        if m % 4 == 0:
            t_drums.add_note(m_tick, 300, 49, velocity=115) # Crash

    # Lead Melody
    lead_notes = [
        ("D5", 0.0, 2.0), ("E5", 2.0, 1.0), ("F5", 3.0, 1.0),
        ("G5", 4.0, 2.0), ("F5", 6.0, 1.0), ("E5", 7.0, 1.0),
        ("D5", 8.0, 2.5), ("E5", 10.5, 1.5),
        ("C#5", 12.0, 4.0),
        ("D5", 16.0, 2.0), ("F5", 18.0, 1.0), ("A5", 19.0, 1.0),
        ("Bb5", 20.0, 2.5), ("A5", 22.5, 1.5),
        ("G5", 24.0, 2.0), ("F5", 26.0, 1.0), ("E5", 27.0, 1.0),
        ("F5", 28.0, 4.0),
        ("G5", 32.0, 2.0), ("Bb5", 34.0, 1.0), ("D6", 35.0, 1.0),
        ("C6", 36.0, 2.5), ("Bb5", 38.5, 1.5),
        ("A5", 40.0, 2.0), ("G5", 42.0, 1.0), ("F#5", 43.0, 1.0),
        ("G5", 44.0, 4.0),
        ("Bb5", 48.0, 2.0), ("A5", 50.0, 1.0), ("G5", 51.0, 1.0),
        ("F5", 52.0, 2.0), ("E5", 54.0, 2.0),
        ("D5", 56.0, 4.0),
        ("D5", 60.0, 4.0),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        p = note_to_midi(n_name)
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, p, velocity=105)
        t_brass.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, p - 12, velocity=85)

    song.save(os.path.join(MIDI_DIR, "bgm_stage01_plan_a.mid"))

# =============================================================================
# 4. STAGE 1 PLAN B: 赤い残響 〜 緋色の鼓動 (Stage 1 B)
# =============================================================================
def export_stage01_plan_b():
    song = MidiSong(bpm=162, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Synth Saw)", channel=0, program=81)
    t_strings = song.add_track(name="Pad (Strings)", channel=1, program=48)
    t_bass = song.add_track(name="Bass (Gallop Bass)", channel=2, program=33)
    t_drums = song.add_track(name="Drums (Rock Kit)", channel=9, program=0)

    chords = [
        ["F#3", "A3", "C#4"],  # F#m
        ["D3", "F#3", "A3"],   # D
        ["A2", "C#3", "E3"],   # A
        ["E3", "G#3", "B3"],   # E
        ["F#3", "A3", "C#4"],  # F#m
        ["D3", "F#3", "A3"],   # D
        ["B2", "D3", "F#3"],   # Bm
        ["C#3", "E#3", "G#3"], # C#
    ] * 2

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_strings.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str) + 12, velocity=75)
        # Gallop bass
        r_p = note_to_midi(c_notes[0])
        for b in range(4):
            t_bass.add_note(m_tick + b * ticks_per_beat, ticks_per_beat // 3, r_p, velocity=100)
            t_bass.add_note(m_tick + b * ticks_per_beat + ticks_per_beat // 2, ticks_per_beat // 3, r_p, velocity=95)

        t_drums.add_note(m_tick, 100, 36, velocity=110)
        t_drums.add_note(m_tick + ticks_per_beat, 100, 38, velocity=105)
        t_drums.add_note(m_tick + ticks_per_beat * 2, 100, 36, velocity=105)
        t_drums.add_note(m_tick + ticks_per_beat * 3, 100, 38, velocity=105)

    lead_notes = [
        ("C#5", 0.0, 2.0), ("D5", 2.0, 1.0), ("E5", 3.0, 1.0),
        ("F#5", 4.0, 2.5), ("E5", 6.5, 1.5),
        ("C#5", 8.0, 3.5),
        ("B4", 12.0, 3.0),
        ("A4", 16.0, 2.0), ("B4", 18.0, 2.0),
        ("C#5", 20.0, 2.0), ("D5", 22.0, 2.0),
        ("B4", 24.0, 3.0),
        ("C#5", 28.0, 4.0),
    ] * 2
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=105)

    song.save(os.path.join(MIDI_DIR, "bgm_stage01_plan_b.mid"))

# =============================================================================
# 5. STAGE 2 PLAN A: 追憶の海 〜 水底の残照 (Stage 2 Ocean A)
# =============================================================================
def export_stage02_plan_a():
    song = MidiSong(bpm=108, time_sig=(6, 8), ppqn=PPQN)
    ticks_per_eighth = PPQN // 2
    ticks_per_measure = ticks_per_eighth * 6

    t_vib = song.add_track(name="Lead (Vibraphone)", channel=0, program=11)
    t_ep = song.add_track(name="Chords (Rhodes E.Piano)", channel=1, program=4)
    t_guitar = song.add_track(name="Arpeggio (Nylon Guitar)", channel=2, program=24)
    t_bass = song.add_track(name="Bass (Fretless Ocean Bass)", channel=3, program=35)
    t_drums = song.add_track(name="Percussion (Brush Kit)", channel=9, program=0)

    chords = [
        ["Eb3", "G3", "Bb3", "D4"],   # Ebmaj7
        ["C3", "Eb3", "G3", "Bb3"],   # Cm7
        ["F3", "Ab3", "C4", "Eb4"],   # Fm7
        ["Bb2", "F3", "Ab3", "Eb4"],  # Bb7sus4
        ["G3", "Bb3", "D4", "F4"],    # Gm7
        ["Ab3", "C4", "Eb4", "G4"],   # Abmaj7
        ["F3", "Ab3", "C4", "G4"],    # Fm9
        ["Bb2", "D3", "F3", "Ab3"],   # Bb7
        ["Eb3", "G3", "Bb3", "D4"],
        ["C3", "Eb3", "G3", "D4"],
        ["Ab3", "C4", "Eb4", "G4"],
        ["Bb3", "D4", "F4", "Ab4"],
        ["G3", "Bb3", "D4", "G4"],
        ["C3", "E3", "G3", "Bb3"],
        ["F3", "Ab3", "C4", "Eb4"],
        ["Bb2", "F3", "Ab3", "D4"],
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        # Rhodes EP
        for i, n_str in enumerate(c_notes):
            t_ep.add_note(m_tick + i * 20, ticks_per_measure - 40, note_to_midi(n_str), velocity=80)
        # Guitar 6/8 Arpeggio
        pattern = [0, 1, 2, 3, 2, 1]
        for step in range(6):
            n_idx = pattern[step] % len(c_notes)
            p = note_to_midi(c_notes[n_idx]) + 12
            t_guitar.add_note(m_tick + step * ticks_per_eighth, int(ticks_per_eighth * 1.5), p, velocity=75)
        # Fretless Bass (Beats 1 & 4)
        r_p = note_to_midi(c_notes[0]) - 12
        t_bass.add_note(m_tick, ticks_per_eighth * 3 - 20, r_p, velocity=95)
        t_bass.add_note(m_tick + ticks_per_eighth * 3, ticks_per_eighth * 3 - 20, r_p + 7, velocity=85)
        # Soft Percussion
        t_drums.add_note(m_tick, 100, 36, velocity=85) # Sub kick on 1
        t_drums.add_note(m_tick + ticks_per_eighth * 3, 100, 38, velocity=70) # Brush on 4

    # Vibraphone Lead
    lead_notes = [
        ("G4", 0.0, 2.5), ("Bb4", 3.0, 1.5), ("D5", 4.5, 1.5),
        ("C5", 6.0, 4.0), ("G4", 10.5, 1.5),
        ("Ab4", 12.0, 2.5), ("C5", 15.0, 1.5), ("Eb5", 16.5, 1.5),
        ("D5", 18.0, 4.0),
        ("Bb4", 24.0, 2.5), ("D5", 27.0, 1.5), ("F5", 28.5, 1.5),
        ("Eb5", 30.0, 3.0), ("D5", 33.0, 1.2), ("C5", 34.2, 1.2),
        ("G4", 36.0, 3.5), ("Ab4", 39.5, 2.0),
        ("Bb4", 42.0, 4.5),
        ("G5", 48.0, 3.0), ("F5", 51.0, 1.2), ("Eb5", 52.2, 1.2),
        ("D5", 54.0, 2.5), ("C5", 56.5, 3.0),
        ("C5", 60.0, 2.0), ("Eb5", 62.0, 2.0), ("G5", 64.0, 1.5),
        ("F5", 66.0, 4.5),
        ("D5", 72.0, 2.5), ("Bb4", 74.5, 3.0),
        ("E5", 78.0, 3.0), ("G5", 81.0, 2.5),
        ("F5", 84.0, 2.5), ("Eb5", 86.5, 1.5), ("D5", 88.0, 1.5),
        ("Eb5", 90.0, 5.5),
    ]
    for n_name, start_eighth, dur_eighth in lead_notes:
        t_vib.add_note(int(start_eighth * ticks_per_eighth), int(dur_eighth * ticks_per_eighth) - 10, note_to_midi(n_name), velocity=100)

    song.save(os.path.join(MIDI_DIR, "bgm_stage02_plan_a.mid"))

# =============================================================================
# 6. STAGE 2 PLAN B: 追憶の海 〜 潮流のセレナーデ (Stage 2 Ocean B)
# =============================================================================
def export_stage02_plan_b():
    song = MidiSong(bpm=120, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_vib = song.add_track(name="Lead (Vibraphone)", channel=0, program=11)
    t_marimba = song.add_track(name="Arpeggio (Marimba)", channel=1, program=12)
    t_ep = song.add_track(name="Chords (Rhodes EP)", channel=2, program=4)
    t_bass = song.add_track(name="Bass (Fretless Bass)", channel=3, program=35)
    t_drums = song.add_track(name="Percussion (Brush Kit)", channel=9, program=0)

    chords = [
        ["G3", "Bb3", "D4", "F4"],
        ["C3", "E3", "G3", "Bb3", "D4"],
        ["F3", "A3", "C4", "E4"],
        ["Bb3", "D4", "F4", "A4"],
        ["E3", "G3", "Bb3", "D4"],
        ["A3", "C#4", "E4", "G4"],
        ["D3", "F3", "A3", "C4"],
        ["D3", "F#3", "A3", "C4"],
    ] * 2

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        # Marimba 16th rippling current
        for s in range(16):
            p = note_to_midi(c_notes[(s * 2) % len(c_notes)]) + 12
            t_marimba.add_note(m_tick + s * (ticks_per_beat // 4), (ticks_per_beat // 4) - 5, p, velocity=75)
        # Offbeat EP chords
        for s in [1, 3]:
            for n_str in c_notes[:4]:
                t_ep.add_note(m_tick + s * ticks_per_beat + (ticks_per_beat // 2), int(ticks_per_beat * 0.7), note_to_midi(n_str), velocity=75)
        # Bass
        r_p = note_to_midi(c_notes[0]) - 12
        t_bass.add_note(m_tick, ticks_per_beat - 10, r_p, velocity=95)
        t_bass.add_note(m_tick + int(ticks_per_beat * 1.5), ticks_per_beat - 10, r_p + 7, velocity=85)
        t_bass.add_note(m_tick + ticks_per_beat * 3, ticks_per_beat - 10, r_p, velocity=90)

    lead_notes = [
        ("D5", 0.0, 2.5), ("C5", 2.5, 0.5), ("Bb4", 3.0, 1.0),
        ("A4", 4.0, 2.5), ("G4", 6.5, 1.5),
        ("C5", 8.0, 2.5), ("A4", 10.5, 1.5),
        ("F4", 12.0, 3.5),
        ("G4", 16.0, 2.0), ("Bb4", 18.0, 2.0),
        ("A4", 20.0, 2.0), ("C#5", 22.0, 2.0),
        ("D5", 24.0, 3.5),
        ("F5", 32.0, 2.0), ("E5", 34.0, 1.0), ("D5", 35.0, 1.0),
        ("G5", 36.0, 3.0), ("E5", 39.0, 1.0),
        ("A5", 40.0, 2.5), ("F5", 42.5, 1.5),
        ("D5", 44.0, 3.5),
        ("Eb5", 48.0, 2.0), ("G5", 50.0, 2.0),
        ("E5", 52.0, 2.0), ("A4", 54.0, 2.0),
        ("D5", 56.0, 4.0),
        ("F#5", 60.0, 4.0),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        t_vib.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=105)

    song.save(os.path.join(MIDI_DIR, "bgm_stage02_plan_b.mid"))

# =============================================================================
# 7. STAGE 3 PLAN A: 孤独な庭 〜 錆びた歯車と曼珠沙華 (Stage 3 Ruins A)
# =============================================================================
def export_stage03_plan_a():
    song = MidiSong(bpm=126, time_sig=(3, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 3

    t_box = song.add_track(name="Lead (Music Box / Celesta)", channel=0, program=10)
    t_guitar = song.add_track(name="Accompaniment (Classical Guitar)", channel=1, program=24)
    t_harp = song.add_track(name="Counterpoint (Harpsichord)", channel=2, program=6)
    t_organ = song.add_track(name="Pad (Church Organ)", channel=3, program=19)
    t_clock = song.add_track(name="Clockwork (Woodblock Tick)", channel=9, program=0)

    chords = [
        ["G3", "Bb3", "D4"],   # Gm
        ["Eb3", "G3", "Bb3"],  # Eb
        ["D3", "F#3", "A3", "C4"], # D7
        ["G3", "Bb3", "D4"],   # Gm
        ["C3", "Eb3", "G3"],   # Cm
        ["F3", "A3", "C4"],    # F
        ["Bb3", "D4", "F4"],   # Bb
        ["D3", "F#3", "A3"],   # D
        ["Eb3", "G3", "Bb3"],  # Eb
        ["F3", "A3", "C4"],    # F
        ["D3", "F#3", "A3"],   # D
        ["G3", "Bb3", "D4"],   # Gm
        ["C3", "Eb3", "G3"],   # Cm
        ["D3", "F#3", "A3", "C4"], # D7
        ["G3", "Bb3", "D4"],   # Gm
        ["G2", "D3", "G3", "B3"], # G major
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        # Organ pad
        for n_str in c_notes:
            t_organ.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str), velocity=65)
        # Classical guitar waltz: Bass on 1, Chords on 2 & 3
        r_p = note_to_midi(c_notes[0]) - 12
        t_guitar.add_note(m_tick, int(ticks_per_beat * 1.5), r_p, velocity=95)
        for b in [1, 2]:
            for n_str in c_notes[1:]:
                t_guitar.add_note(m_tick + b * ticks_per_beat, ticks_per_beat - 10, note_to_midi(n_str), velocity=78)
        # Harpsichord flourish
        if m % 2 == 1:
            for s, n_str in enumerate(c_notes):
                t_harp.add_note(m_tick + ticks_per_beat + s * (ticks_per_beat // 3), ticks_per_beat // 3 - 5, note_to_midi(n_str) + 12, velocity=75)
        # Clock tick (Side stick: 37, Wood block: 76/77)
        t_clock.add_note(m_tick, 50, 76, velocity=85)
        t_clock.add_note(m_tick + ticks_per_beat, 50, 77, velocity=75)
        t_clock.add_note(m_tick + ticks_per_beat * 2, 50, 76, velocity=80)

    lead_notes = [
        ("D5", 0.0, 1.5), ("Eb5", 1.5, 0.5), ("D5", 2.0, 1.0),
        ("Bb4", 3.0, 2.0), ("C5", 5.0, 1.0),
        ("A4", 6.0, 2.0), ("F#4", 8.0, 1.0),
        ("G4", 9.0, 3.0),
        ("C5", 12.0, 1.5), ("D5", 13.5, 0.5), ("Eb5", 14.0, 1.0),
        ("F5", 15.0, 2.0), ("Eb5", 17.0, 1.0),
        ("D5", 18.0, 2.0), ("C5", 20.0, 1.0),
        ("D5", 21.0, 3.0),
        ("G5", 24.0, 1.5), ("F5", 25.5, 0.5), ("Eb5", 26.0, 1.0),
        ("F5", 27.0, 2.0), ("D5", 29.0, 1.0),
        ("F#5", 30.0, 2.0), ("A5", 32.0, 1.0),
        ("G5", 33.0, 3.0),
        ("Eb5", 36.0, 1.5), ("D5", 37.5, 0.5), ("C5", 38.0, 1.0),
        ("D5", 39.0, 2.0), ("F#4", 41.0, 1.0),
        ("G4", 42.0, 3.0),
        ("B4", 45.0, 3.0),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        t_box.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=95)

    song.save(os.path.join(MIDI_DIR, "bgm_stage03_plan_a.mid"))

# =============================================================================
# 8. STAGE 3 PLAN B: 孤独な庭 〜 静寂の回廊 (Stage 3 Ruins B)
# =============================================================================
def export_stage03_plan_b():
    song = MidiSong(bpm=88, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_cello = song.add_track(name="Lead (Solitary Cello)", channel=0, program=42)
    t_guitar = song.add_track(name="Arpeggio (Nylon Guitar)", channel=1, program=24)
    t_box = song.add_track(name="Counter (Music Box)", channel=2, program=10)
    t_organ = song.add_track(name="Pad (Church Organ)", channel=3, program=19)
    t_bell = song.add_track(name="Bell (Tubular Bell)", channel=4, program=14)

    chords = [
        ["D3", "F3", "A3"],    # Dm
        ["G3", "Bb3", "D4"],   # Gm
        ["C3", "E3", "G3"],    # C
        ["F3", "A3", "C4"],    # F
        ["Bb3", "D4", "F4"],   # Bb
        ["G3", "Bb3", "D4"],   # Gm
        ["A3", "C#4", "E4"],   # A7
        ["D3", "F3", "A3"],    # Dm
        ["Bb3", "D4", "F4"],   # Bb
        ["A3", "C#4", "E4"],   # A7
        ["D3", "F3", "A3"],    # Dm
        ["D2", "A2", "D3", "F#3"], # D major
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_organ.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str), velocity=65)
        # Guitar fingerpicking
        r_p = note_to_midi(c_notes[0]) - 12
        t_guitar.add_note(m_tick, ticks_per_beat, r_p, velocity=90)
        arp = [1, 2, 0, 1, 2, 1]
        for s, idx in enumerate(arp):
            t_guitar.add_note(m_tick + ticks_per_beat + s * (ticks_per_beat // 2), (ticks_per_beat // 2) - 10, note_to_midi(c_notes[idx % len(c_notes)]), velocity=75)
        # Church bell toll on measure 0, 4, 8
        if m in [0, 4, 8]:
            t_bell.add_note(m_tick, ticks_per_measure * 2, note_to_midi(c_notes[0]), velocity=105)

    lead_notes = [
        ("D3", 0.0, 2.0), ("E3", 2.0, 1.0), ("F3", 3.0, 1.0),
        ("G3", 4.0, 2.5), ("A3", 6.5, 1.5),
        ("E3", 8.0, 3.0),
        ("F3", 12.0, 3.5),
        ("D4", 16.0, 2.0), ("C4", 18.0, 1.0), ("Bb3", 19.0, 1.0),
        ("G3", 20.0, 3.0),
        ("A3", 24.0, 3.5),
        ("D3", 28.0, 4.0),
        ("F4", 32.0, 2.0), ("E4", 34.0, 1.0), ("D4", 35.0, 1.0),
        ("C#4", 36.0, 3.5),
        ("D4", 40.0, 4.0),
        ("D3", 44.0, 4.0),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        t_cello.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=95)

    song.save(os.path.join(MIDI_DIR, "bgm_stage03_plan_b.mid"))

# =============================================================================
# 9. BOSS 1 PLAN A: 生体中枢 〜 脈動する境界 (Boss 1 A)
# =============================================================================
def export_boss01_plan_a():
    song = MidiSong(bpm=168, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Distorted FM Synth)", channel=0, program=84)
    t_strings = song.add_track(name="Choir / Strings Pad", channel=1, program=52)
    t_bass = song.add_track(name="Bass (Industrial Slap Bass)", channel=2, program=36)
    t_drums = song.add_track(name="Drums (Tympani & Taiko)", channel=9, program=0)

    chords = [
        ["G2", "C#3", "G3"],   # Tritone tension
        ["G2", "D3", "Bb3"],   # Gm
        ["Eb2", "A2", "Eb3"],  # Eb diminished
        ["D2", "F#2", "C3"],   # D7
    ] * 4

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_strings.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str) + 12, velocity=75)
        # Heavy syncopated bass
        r_p = note_to_midi(c_notes[0])
        t_bass.add_note(m_tick, ticks_per_beat // 2, r_p, velocity=110)
        t_bass.add_note(m_tick + int(ticks_per_beat * 0.75), ticks_per_beat // 2, r_p, velocity=105)
        t_bass.add_note(m_tick + ticks_per_beat * 2, ticks_per_beat // 2, r_p, velocity=110)
        t_bass.add_note(m_tick + int(ticks_per_beat * 2.75), ticks_per_beat // 2, r_p, velocity=105)
        # Drums
        t_drums.add_note(m_tick, 100, 36, velocity=120)
        t_drums.add_note(m_tick + ticks_per_beat, 100, 38, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat * 2, 100, 36, velocity=120)
        t_drums.add_note(m_tick + ticks_per_beat * 3, 100, 38, velocity=115)

    lead_notes = [
        ("G4", 0.0, 1.5), ("C#5", 1.5, 1.0), ("D5", 2.5, 1.5),
        ("Bb4", 4.0, 2.0), ("A4", 6.0, 1.0), ("Ab4", 7.0, 1.0),
        ("G4", 8.0, 2.5), ("C#5", 10.5, 1.5),
        ("D5", 12.0, 4.0),
    ] * 2
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=110)

    song.save(os.path.join(MIDI_DIR, "bgm_boss01_plan_a.mid"))

# =============================================================================
# 10. BOSS 1 PLAN B: 輪廻の狂詩曲 〜 死線突破 (Boss 1 B)
# =============================================================================
def export_boss01_plan_b():
    song = MidiSong(bpm=174, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Fast Techno Lead)", channel=0, program=80)
    t_pad = song.add_track(name="Pad (Synth Strings)", channel=1, program=50)
    t_bass = song.add_track(name="Bass (Synth Bass)", channel=2, program=38)
    t_drums = song.add_track(name="Drums (Electronic Kit)", channel=9, program=0)

    chords = [
        ["E2", "G2", "B2"],    # Em
        ["C2", "E2", "G2"],    # C
        ["D2", "F#2", "A2"],   # D
        ["B1", "D#2", "F#2"],  # B
    ] * 4

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_pad.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str) + 12, velocity=75)
        # 16th driving bass
        r_p = note_to_midi(c_notes[0])
        for s in range(16):
            t_bass.add_note(m_tick + s * (ticks_per_beat // 4), (ticks_per_beat // 4) - 5, r_p, velocity=95)
        # Fast techno drums
        for b in range(4):
            t_drums.add_note(m_tick + b * ticks_per_beat, 80, 36, velocity=115) # 4-on-the-floor
            t_drums.add_note(m_tick + b * ticks_per_beat + (ticks_per_beat // 2), 60, 42, velocity=90) # Offbeat open hat

    lead_notes = [
        ("E5", 0.0, 1.0), ("B5", 1.0, 1.0), ("G5", 2.0, 1.0), ("F#5", 3.0, 1.0),
        ("G5", 4.0, 2.0), ("A5", 6.0, 2.0),
        ("B5", 8.0, 2.0), ("D6", 10.0, 2.0),
        ("D#6", 12.0, 4.0),
    ] * 2
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=110)

    song.save(os.path.join(MIDI_DIR, "bgm_boss01_plan_b.mid"))

# =============================================================================
# 11. STAGE 4 PLAN A: 分岐する空 〜 碧落の疾走 (Stage 4 Sky A, 165 BPM)
# =============================================================================
def export_stage04_plan_a():
    song = MidiSong(bpm=165, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Sky Brass)", channel=0, program=62)
    t_arp = song.add_track(name="Arpeggio (Sparkling Synth)", channel=1, program=81)
    t_pad = song.add_track(name="Pad (Strings)", channel=2, program=48)
    t_bass = song.add_track(name="Bass (Slap Drive Bass)", channel=3, program=36)
    t_drums = song.add_track(name="Drums (Power Kit)", channel=9, program=0)

    chords = [
        ["E3", "G3", "B3"],    # Em
        ["C3", "E3", "G3"],    # C
        ["D3", "F#3", "A3"],   # D
        ["B2", "D#3", "F#3"],  # Bm
        ["C3", "E3", "G3"],    # C
        ["A2", "C3", "E3"],    # Am
        ["B2", "D#3", "F#3", "A3"], # B7
        ["E3", "G3", "B3"],    # Em
        ["C3", "E3", "G3", "B3"],
        ["D3", "F#3", "A3", "C4"],
        ["G3", "B3", "D4"],
        ["E3", "G3", "B3"],
        ["C3", "E3", "G3"],
        ["D3", "F#3", "A3"],
        ["E3", "G3", "B3", "E4"],
        ["E3", "B3", "E4", "G4"],
    ]

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_pad.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str) + 12, velocity=75)
        # 16th Arps
        for s in range(16):
            n_str = c_notes[(s * 3) % len(c_notes)]
            t_arp.add_note(m_tick + s * (ticks_per_beat // 4), (ticks_per_beat // 4) - 5, note_to_midi(n_str) + 24, velocity=85)
        # 8th Slap bass
        r_p = note_to_midi(c_notes[0])
        for b in range(8):
            p = r_p if (b % 4 != 3) else r_p + 12
            t_bass.add_note(m_tick + b * (ticks_per_beat // 2), (ticks_per_beat // 2) - 10, p, velocity=100)
        # Drums
        t_drums.add_note(m_tick, 100, 36, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat, 100, 38, velocity=110)
        t_drums.add_note(m_tick + ticks_per_beat * 2, 100, 36, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat * 3, 100, 38, velocity=110)

    lead_notes = [
        ("B4", 0.0, 2.0), ("C5", 2.0, 1.0), ("D5", 3.0, 1.0),
        ("E5", 4.0, 2.5), ("D5", 6.5, 1.5),
        ("A4", 8.0, 2.0), ("B4", 10.0, 2.0),
        ("G4", 12.0, 3.5),
        ("E5", 16.0, 2.0), ("F#5", 18.0, 1.0), ("G5", 19.0, 1.0),
        ("A5", 20.0, 2.5), ("G5", 22.5, 1.5),
        ("F#5", 24.0, 3.0),
        ("E5", 28.0, 4.0),
        ("G5", 32.0, 2.0), ("A5", 34.0, 1.0), ("B5", 35.0, 1.0),
        ("A5", 36.0, 2.5), ("F#5", 38.5, 1.5),
        ("G5", 40.0, 2.5), ("D5", 42.5, 1.5),
        ("E5", 44.0, 3.5),
        ("C5", 48.0, 2.0), ("D5", 50.0, 2.0),
        ("B4", 52.0, 2.0), ("D5", 54.0, 2.0),
        ("E5", 56.0, 4.0),
        ("E5", 60.0, 4.0),
    ]
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=110)

    song.save(os.path.join(MIDI_DIR, "bgm_stage04_plan_a.mid"))

# =============================================================================
# 12. STAGE 4 PLAN B: 分岐する空 〜 乱気流のロンド (Stage 4 Sky B, 158 BPM)
# =============================================================================
def export_stage04_plan_b():
    song = MidiSong(bpm=158, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Brass Lead)", channel=0, program=62)
    t_arp = song.add_track(name="Arpeggio (Triplet Synth)", channel=1, program=81)
    t_bass = song.add_track(name="Bass (Gallop Bass)", channel=2, program=33)
    t_drums = song.add_track(name="Drums (Rock Kit)", channel=9, program=0)

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

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        # Triplet arps (12 per measure)
        for t_step in range(12):
            p = note_to_midi(c_notes[t_step % len(c_notes)]) + 24
            t_arp.add_note(m_tick + int(t_step * (ticks_per_measure / 12)), int((ticks_per_measure / 12) * 0.9), p, velocity=80)
        # Gallop bass
        r_p = note_to_midi(c_notes[0])
        for b in range(4):
            t_bass.add_note(m_tick + b * ticks_per_beat, ticks_per_beat // 3, r_p, velocity=100)
            t_bass.add_note(m_tick + b * ticks_per_beat + ticks_per_beat // 2, ticks_per_beat // 3, r_p, velocity=95)
        # Drums
        t_drums.add_note(m_tick, 100, 36, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat, 100, 38, velocity=105)
        t_drums.add_note(m_tick + ticks_per_beat * 2, 100, 36, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat * 3, 100, 38, velocity=105)

    lead_notes = [
        ("E5", 0.0, 2.0), ("F5", 2.0, 1.0), ("G5", 3.0, 1.0),
        ("A5", 4.0, 2.5), ("G5", 6.5, 1.5),
        ("D5", 8.0, 2.0), ("E5", 10.0, 2.0),
        ("C5", 12.0, 3.5),
        ("F5", 16.0, 2.0), ("G5", 18.0, 1.0), ("A5", 19.0, 1.0),
        ("B5", 20.0, 2.5), ("A5", 22.5, 1.5),
        ("G#5", 24.0, 3.0),
        ("A5", 28.0, 4.0),
    ] * 2
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=105)

    song.save(os.path.join(MIDI_DIR, "bgm_stage04_plan_b.mid"))

# =============================================================================
# 13. STAGE 5 PLAN A: 忘却の要塞 〜 鋼鉄の残影 (Stage 5 Fortress A, 148 BPM)
# =============================================================================
def export_stage05_plan_a():
    song = MidiSong(bpm=148, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (Industrial Metal FM)", channel=0, program=84)
    t_pad = song.add_track(name="Pad (Dark Strings)", channel=1, program=49)
    t_bass = song.add_track(name="Bass (Heavy FM Bass)", channel=2, program=38)
    t_drums = song.add_track(name="Drums (Industrial Kit)", channel=9, program=0)

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

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        for n_str in c_notes:
            t_pad.add_note(m_tick, ticks_per_measure - 20, note_to_midi(n_str) + 12, velocity=75)
        # Syncopated 16th industrial bass
        r_p = note_to_midi(c_notes[0])
        for s in [0, 2, 3, 6, 8, 10, 12, 14]:
            t_bass.add_note(m_tick + s * (ticks_per_beat // 4), (ticks_per_beat // 4) - 5, r_p, velocity=105)
        # Heavy drums
        t_drums.add_note(m_tick, 100, 36, velocity=120)
        t_drums.add_note(m_tick + ticks_per_beat, 100, 38, velocity=115)
        t_drums.add_note(m_tick + int(ticks_per_beat * 1.75), 100, 36, velocity=110)
        t_drums.add_note(m_tick + ticks_per_beat * 2, 100, 36, velocity=120)
        t_drums.add_note(m_tick + ticks_per_beat * 3, 100, 38, velocity=115)

    lead_notes = [
        ("C5", 0.0, 1.5), ("Eb5", 1.5, 1.0), ("G5", 2.5, 1.5),
        ("Ab5", 4.0, 2.5), ("G5", 6.5, 1.5),
        ("F5", 8.0, 2.0), ("D5", 10.0, 2.0),
        ("Eb5", 12.0, 3.5),
        ("C5", 16.0, 1.5), ("G5", 17.5, 1.5), ("Bb5", 19.0, 1.0),
        ("C6", 20.0, 2.5), ("Bb5", 22.5, 1.5),
        ("Ab5", 24.0, 2.0), ("G5", 26.0, 2.0),
        ("G5", 28.0, 4.0),
    ] * 2
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=110)

    song.save(os.path.join(MIDI_DIR, "bgm_stage05_plan_a.mid"))

# =============================================================================
# 14. STAGE 5 PLAN B: 忘却の要塞 〜 機械仕掛けの記憶 (Stage 5 Fortress B, 152 BPM)
# =============================================================================
def export_stage05_plan_b():
    song = MidiSong(bpm=152, time_sig=(4, 4), ppqn=PPQN)
    ticks_per_beat = PPQN
    ticks_per_measure = PPQN * 4

    t_lead = song.add_track(name="Lead (FM Synth)", channel=0, program=81)
    t_bass = song.add_track(name="Bass (16th Techno Bass)", channel=1, program=38)
    t_drums = song.add_track(name="Drums (Electronic Kit)", channel=9, program=0)

    chords = [
        ["D2", "F2", "A2"],
        ["Bb1", "D2", "F2"],
        ["C2", "E2", "G2"],
        ["A1", "C#2", "E2"],
    ] * 4

    for m, c_notes in enumerate(chords):
        m_tick = m * ticks_per_measure
        r_p = note_to_midi(c_notes[0])
        for s in range(16):
            t_bass.add_note(m_tick + s * (ticks_per_beat // 4), (ticks_per_beat // 4) - 5, r_p, velocity=100)
        t_drums.add_note(m_tick, 80, 36, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat, 80, 38, velocity=110)
        t_drums.add_note(m_tick + ticks_per_beat * 2, 80, 36, velocity=115)
        t_drums.add_note(m_tick + ticks_per_beat * 3, 80, 38, velocity=110)

    lead_notes = [
        ("D5", 0.0, 2.0), ("A5", 2.0, 2.0),
        ("F5", 4.0, 2.0), ("G5", 6.0, 2.0),
        ("E5", 8.0, 3.0),
        ("C#5", 12.0, 4.0),
    ] * 4
    for n_name, start_beat, dur_beat in lead_notes:
        t_lead.add_note(int(start_beat * ticks_per_beat), int(dur_beat * ticks_per_beat) - 10, note_to_midi(n_name), velocity=105)

    song.save(os.path.join(MIDI_DIR, "bgm_stage05_plan_b.mid"))


def export_ableton_clips():
    """Export single-track MIDI clips categorized by instrument for Ableton Live Drag & Drop."""
    ableton_clip_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "ableton", "MIDI_Clips"))
    os.makedirs(ableton_clip_dir, exist_ok=True)
    # Re-export each track of each song as standalone single-track MIDI clip
    # e.g. Lead_165BPM_Emin_Stage04_PlanA.mid, Bass_165BPM_Emin_Stage04_PlanA.mid, etc.
    print(f"  [Ableton Live] Exporting individual instrument clips to {ableton_clip_dir}...")
    # Generate standalone clips for quick Ableton Session/Arrangement drop
    clips = [
        ("Lead_82BPM_Dmin_OpeningA.mid", 82, 0, 77, [("A4", 0.0, 3.0), ("G4", 3.0, 1.0), ("F4", 4.0, 2.5), ("E4", 6.5, 1.5), ("D4", 8.0, 3.5), ("D5", 16.0, 2.0), ("E5", 18.0, 1.0), ("F5", 19.0, 1.0), ("G5", 20.0, 2.5), ("F5", 22.5, 1.5), ("E5", 24.0, 2.5), ("C5", 26.5, 1.5), ("A4", 28.0, 4.0)]),
        ("Arp_82BPM_Dmin_OpeningA.mid", 82, 0, 46, [("D4", 0.0, 0.5), ("F4", 0.5, 0.5), ("A4", 1.0, 0.5), ("D5", 1.5, 0.5)] * 8),
        ("Bass_82BPM_Dmin_OpeningA.mid", 82, 0, 43, [("D2", 0.0, 4.0), ("Bb1", 4.0, 4.0), ("G1", 8.0, 4.0), ("A1", 12.0, 4.0), ("D2", 16.0, 4.0)]),
        ("Lead_165BPM_Emin_Stage04A.mid", 165, 0, 62, [("B4", 0.0, 2.0), ("C5", 2.0, 1.0), ("D5", 3.0, 1.0), ("E5", 4.0, 2.5), ("D5", 6.5, 1.5), ("A4", 8.0, 2.0), ("B4", 10.0, 2.0), ("G4", 12.0, 3.5), ("E5", 16.0, 2.0), ("F#5", 18.0, 1.0), ("G5", 19.0, 1.0), ("A5", 20.0, 2.5), ("G5", 22.5, 1.5), ("F#5", 24.0, 3.0), ("E5", 28.0, 4.0)]),
        ("Bass_165BPM_Emin_Stage04A.mid", 165, 0, 36, [("E2", 0.0, 0.5), ("E2", 0.5, 0.5), ("E2", 1.0, 0.5), ("E3", 1.5, 0.5)] * 8),
        ("Arp_165BPM_Emin_Stage04A.mid", 165, 0, 81, [("E4", 0.0, 0.25), ("G4", 0.25, 0.25), ("B4", 0.5, 0.25), ("E5", 0.75, 0.25)] * 16),
        ("Lead_148BPM_Cmin_Stage05A.mid", 148, 0, 84, [("C5", 0.0, 1.5), ("Eb5", 1.5, 1.0), ("G5", 2.5, 1.5), ("Ab5", 4.0, 2.5), ("G5", 6.5, 1.5), ("F5", 8.0, 2.0), ("D5", 10.0, 2.0), ("Eb5", 12.0, 3.5)]),
        ("Bass_148BPM_Cmin_Stage05A.mid", 148, 0, 38, [("C2", 0.0, 0.25), ("C2", 0.5, 0.25), ("C2", 0.75, 0.25)] * 8),
        ("Lead_108BPM_Eb_Stage02A.mid", 108, 0, 11, [("G4", 0.0, 1.25), ("Bb4", 1.5, 0.75), ("D5", 2.25, 0.75), ("C5", 3.0, 2.0)]),
        ("Lead_126BPM_Gmin_Stage03A.mid", 126, 0, 10, [("D5", 0.0, 1.5), ("Eb5", 1.5, 0.5), ("D5", 2.0, 1.0), ("Bb4", 3.0, 2.0), ("C5", 5.0, 1.0), ("A4", 6.0, 2.0), ("G4", 9.0, 3.0)]),
    ]
    for filename, bpm, ch, prog, notes in clips:
        s = MidiSong(bpm=bpm, time_sig=(4, 4), ppqn=PPQN)
        tr = s.add_track(name=filename[:-4], channel=ch, program=prog)
        for n_name, st_b, d_b in notes:
            tr.add_note(int(st_b * PPQN), int(d_b * PPQN) - 10, note_to_midi(n_name), velocity=105)
        s.save(os.path.join(ableton_clip_dir, filename))



def main():
    print("=================================================================")
    print(" Mw-fActory: Exporting All BGM to Standard MIDI Files (.mid)")
    print("=================================================================")
    export_opening_plan_a()
    export_opening_plan_b()
    export_stage01_plan_a()
    export_stage01_plan_b()
    export_stage02_plan_a()
    export_stage02_plan_b()
    export_stage03_plan_a()
    export_stage03_plan_b()
    export_boss01_plan_a()
    export_boss01_plan_b()
    export_stage04_plan_a()
    export_stage04_plan_b()
    export_stage05_plan_a()
    export_stage05_plan_b()
    export_ableton_clips()
    print("All 14 BGM tracks and Ableton MIDI clips exported successfully!")

if __name__ == "__main__":
    main()

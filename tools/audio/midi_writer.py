#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Standard MIDI File (SMF Format 1) Writer

Pure Python SMF Format 1 encoder with zero external dependencies.
Converts musical sequences (notes, chords, drums, CC, program changes) into .mid files.
"""

import struct
import os
import math

NOTE_NAMES = {
    "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "E#": 5, "Fb": 4,
    "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10,
    "B": 11, "B#": 0, "Cb": 11
}

def note_to_midi(name):
    if not name or name == "REST":
        return None
    pitch_str = name[:-1]
    octave = int(name[-1])
    semitone = NOTE_NAMES[pitch_str]
    return (octave + 1) * 12 + semitone

def encode_vlq(value):
    """Encode an integer as a variable-length quantity (VLQ)."""
    val = int(value)
    buffer = val & 0x7F
    result = bytearray()
    while val > 0x7F:
        val >>= 7
        result.insert(0, (val & 0x7F) | 0x80)
    result.append(buffer)
    return bytes(result)

class MidiTrack:
    def __init__(self, name="Track", channel=0, program=0):
        self.name = name
        self.channel = channel
        self.program = program
        self.events = [] # list of (absolute_tick, event_bytes)

    def add_event(self, abs_tick, event_bytes):
        self.events.append((int(abs_tick), event_bytes))

    def add_note(self, start_tick, dur_tick, pitch, velocity=100):
        if pitch is None: return
        # Note On
        self.add_event(start_tick, bytes([0x90 | (self.channel & 0x0F), pitch & 0x7F, velocity & 0x7F]))
        # Note Off
        self.add_event(start_tick + dur_tick, bytes([0x80 | (self.channel & 0x0F), pitch & 0x7F, 0x00]))

    def compile(self):
        # Sort events by absolute tick
        # Note Off before Note On at same tick
        def event_order(item):
            tick, b = item
            ev_type = b[0] & 0xF0 if len(b) > 0 else 0
            priority = 0 if ev_type == 0x80 else 1
            return (tick, priority)

        self.events.sort(key=event_order)

        track_data = bytearray()

        # Track Name Meta Event
        if self.name:
            encoded_name = self.name.encode("utf-8")
            track_data.extend(encode_vlq(0))
            track_data.extend(bytes([0xFF, 0x03, len(encoded_name)]))
            track_data.extend(encoded_name)

        # Program Change Event
        track_data.extend(encode_vlq(0))
        track_data.extend(bytes([0xC0 | (self.channel & 0x0F), self.program & 0x7F]))

        # Events
        current_tick = 0
        for tick, ev_bytes in self.events:
            delta = max(0, tick - current_tick)
            track_data.extend(encode_vlq(delta))
            track_data.extend(ev_bytes)
            current_tick = tick

        # End of Track Meta Event
        track_data.extend(encode_vlq(0))
        track_data.extend(bytes([0xFF, 0x2F, 0x00]))

        # Track chunk header: MTrk + length
        header = b"MTrk" + struct.pack(">I", len(track_data))
        return header + track_data

class MidiSong:
    def __init__(self, bpm=120, time_sig=(4, 4), ppqn=480):
        self.bpm = bpm
        self.time_sig = time_sig
        self.ppqn = ppqn
        self.tracks = []

    def add_track(self, name="Track", channel=0, program=0):
        t = MidiTrack(name=name, channel=channel, program=program)
        self.tracks.append(t)
        return t

    def save(self, file_path):
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        # Create Conductor Track (Tempo & Time Signature)
        conductor_data = bytearray()
        
        # Track Name
        c_name = b"Conductor Track"
        conductor_data.extend(encode_vlq(0))
        conductor_data.extend(bytes([0xFF, 0x03, len(c_name)]))
        conductor_data.extend(c_name)

        # Time Signature: nn, dd (pow of 2), cc (clocks per click), bb (32nd notes per 24 clocks)
        nn, dd_val = self.time_sig
        dd = int(math.log2(dd_val)) if dd_val in [2, 4, 8, 16] else 2
        conductor_data.extend(encode_vlq(0))
        conductor_data.extend(bytes([0xFF, 0x58, 0x04, nn, dd, 24, 8]))

        # Tempo (microseconds per quarter note)
        tempo_val = int(60_000_000 / self.bpm)
        t_b1 = (tempo_val >> 16) & 0xFF
        t_b2 = (tempo_val >> 8) & 0xFF
        t_b3 = tempo_val & 0xFF
        conductor_data.extend(encode_vlq(0))
        conductor_data.extend(bytes([0xFF, 0x51, 0x03, t_b1, t_b2, t_b3]))

        # End of conductor
        conductor_data.extend(encode_vlq(0))
        conductor_data.extend(bytes([0xFF, 0x2F, 0x00]))

        c_chunk = b"MTrk" + struct.pack(">I", len(conductor_data)) + conductor_data

        compiled_tracks = [c_chunk]
        for t in self.tracks:
            compiled_tracks.append(t.compile())

        total_tracks = len(compiled_tracks)

        # Header chunk: MThd + len=6 + format=1 + num_tracks + division
        mthd = b"MThd" + struct.pack(">HHH", 1, total_tracks, self.ppqn)
        # wait: struct.pack len=6 -> format >IHHH is (6, 1, total_tracks, ppqn)
        header = b"MThd" + struct.pack(">IHHH", 6, 1, total_tracks, self.ppqn)

        with open(file_path, "wb") as f:
            f.write(header)
            for ch in compiled_tracks:
                f.write(ch)

        print(f"  [Created MIDI] {file_path} ({total_tracks} tracks, BPM {self.bpm}, {self.time_sig[0]}/{self.time_sig[1]})")

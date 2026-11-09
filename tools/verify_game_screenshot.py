#!/usr/bin/env python3
"""Validate a Godot screenshot without accepting an empty or corrupt PNG.

Usage: python tools/verify_game_screenshot.py /path/to/screenshot.png
The file must have been captured from a running Godot scene; this tool cannot
prove its provenance, only its structural integrity and non-uniform pixels.
"""
import argparse
import pathlib
import struct
import sys
import zlib

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def validate(path: pathlib.Path) -> tuple[int, int]:
    data = path.read_bytes()
    if not data.startswith(PNG_SIGNATURE):
        raise ValueError("not a PNG file")
    pos = len(PNG_SIGNATURE)
    width = height = None
    image_data = bytearray()
    saw_end = False
    while pos + 12 <= len(data):
        length = struct.unpack_from(">I", data, pos)[0]
        if length > 100_000_000 or pos + length + 12 > len(data):
            raise ValueError("truncated or oversized PNG chunk")
        kind = data[pos + 4:pos + 8]
        payload = data[pos + 8:pos + 8 + length]
        crc = struct.unpack_from(">I", data, pos + 8 + length)[0]
        if zlib.crc32(kind + payload) & 0xFFFFFFFF != crc:
            raise ValueError("PNG chunk CRC mismatch")
        if kind == b"IHDR":
            if width is not None or length != 13:
                raise ValueError("invalid IHDR")
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            if not (width > 0 and height > 0 and width <= 8192 and height <= 8192):
                raise ValueError("invalid image dimensions")
            if depth != 8 or color not in (2, 6) or compression or filtering or interlace:
                raise ValueError("unsupported PNG format (expected noninterlaced RGB/RGBA 8-bit)")
        elif kind == b"IDAT":
            image_data.extend(payload)
        elif kind == b"IEND":
            saw_end = True
            break
        pos += 12 + length
    if not saw_end or width is None or not image_data:
        raise ValueError("incomplete PNG")
    channels = 3 if color == 2 else 4
    stride = width * channels
    expected = height * (stride + 1)
    raw = zlib.decompress(bytes(image_data), max_length=expected + 1)
    if len(raw) != expected:
        raise ValueError("unexpected decompressed PNG size")
    # PNG filters are row-local. Reconstruct pixels before checking variation.
    previous = bytearray(stride)
    distinct = set()
    for row in range(height):
        offset = row * (stride + 1)
        filt = raw[offset]
        current = bytearray(raw[offset + 1:offset + 1 + stride])
        if filt > 4:
            raise ValueError("invalid PNG filter")
        for i in range(stride):
            a = current[i - channels] if i >= channels else 0
            b = previous[i]
            c = previous[i - channels] if i >= channels else 0
            if filt == 1:
                prediction = a
            elif filt == 2:
                prediction = b
            elif filt == 3:
                prediction = (a + b) // 2
            elif filt == 4:
                p = a + b - c
                distances = (abs(p - a), abs(p - b), abs(p - c))
                prediction = (a, b, c)[distances.index(min(distances))]
            else:
                prediction = 0
            current[i] = (current[i] + prediction) & 255
        for i in range(0, stride, channels):
            distinct.add(bytes(current[i:i + 3]))
            if len(distinct) > 1:
                break
        previous = current
    if len(distinct) < 2:
        raise ValueError("image contains only a single flat color")
    return width, height


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("png", type=pathlib.Path)
    args = parser.parse_args()
    try:
        width, height = validate(args.png)
    except (OSError, ValueError, zlib.error) as exc:
        print(f"FAIL {args.png}: {exc}", file=sys.stderr)
        return 1
    print(f"PASS {args.png}: {width}x{height}, valid CRC and varied pixels")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

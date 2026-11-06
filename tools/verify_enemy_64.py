"""Verify the imported enemy pack using Python's standard library."""
from pathlib import Path
import hashlib
import json
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "assets/enemies/manjushage_64_v1"

def require(condition, message):
    if not condition:
        raise ValueError(message)

def main():
    checksums = json.loads((PACK / "checksums.git.json").read_text(encoding="utf-8"))
    require(len(checksums) == 131, "Expected 131 original files")
    for name, expected in checksums.items():
        data = (PACK / name).read_bytes()
        actual = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        require(actual == expected, "Original changed: " + name)
    original = json.loads((PACK / "manifest.json").read_text(encoding="utf-8"))
    runtime = json.loads((PACK / "manifest.runtime.json").read_text(encoding="utf-8"))
    corrected = dict(original, source_image="original_concept_sheet.png")
    require(runtime == corrected, "Unexpected runtime manifest changes")
    require((PACK / runtime["source_image"]).is_file(), "Missing source sheet")
    enemies = runtime["enemies"]
    require(runtime["count"] == len(enemies) == 64, "Expected 64 enemies")
    expected_ids = {f"S{s:02}E{e:02}" for s in range(1, 9) for e in range(1, 9)}
    require({e["id"] for e in enemies} == expected_ids, "Invalid IDs")
    for e in enemies:
        require(e["id"] == f'S{e["stage"]:02}E{e["slot"]:02}', "Stage/slot mismatch")
        for key in ("sprite", "source_crop"):
            require((PACK / e[key]).is_file(), "Missing " + e[key])
    pngs = list(PACK.rglob("*.png"))
    require(len(pngs) == 129, "Expected 129 PNGs")
    for path in pngs:
        data = path.read_bytes()
        require(data[:8] == b"\x89PNG\r\n\x1a\n", str(path))
        offset, compressed, ended = 8, b"", False
        while offset < len(data):
            length = struct.unpack(">I", data[offset:offset+4])[0]
            kind = data[offset+4:offset+8]
            payload = data[offset+8:offset+8+length]
            crc = struct.unpack(">I", data[offset+8+length:offset+12+length])[0]
            require(zlib.crc32(kind + payload) & 0xffffffff == crc, "PNG CRC: " + str(path))
            if kind == b"IHDR":
                width, height, depth, color, comp, filt, interlace = struct.unpack(">IIBBBBB", payload)
            elif kind == b"IDAT":
                compressed += payload
            elif kind == b"IEND":
                ended = True
            offset += length + 12
        require(ended and offset == len(data), "Invalid PNG ending")
        require(depth == 8 and color in (2, 6) and interlace == comp == filt == 0, "Unsupported PNG")
        channels = {2: 3, 6: 4}[color]
        raw = zlib.decompress(compressed)
        stride = 1 + width * channels
        require(len(raw) == height * stride, "Invalid scanline length")
        require(all(raw[y * stride] <= 4 for y in range(height)), "Invalid scanline filter")
        if path.parent.name == "sprites":
            require(color == 6, "Sprite must be RGBA")
    print("PASS: 131 originals match; 129 PNG CRC/decompression checks; 64 IDs, 8x8 mapping, manifest paths")
    print("NOT TESTED: Godot import/rendering, full visual QA, gameplay, export")
if __name__ == "__main__":
    main()

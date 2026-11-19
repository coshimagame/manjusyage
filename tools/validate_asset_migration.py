#!/usr/bin/env python3
"""Read-only pre-merge audit: compare asset bytes and resolve local references."""
from __future__ import annotations
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ASSET_EXT={".png",".webp",".jpg",".jpeg",".svg",".wav",".ogg",".tscn",".tres"}
GODOT_RE = re.compile(r"res://([^\s\"')]+[.](?:png|webp|jpg|jpeg|svg|wav|ogg|tscn|tres))", re.I)
MARKDOWN_RE = re.compile(r"\!?\[[^\]]*\]\((?!https?://|data:|#)([^)\s]+[.](?:png|webp|jpg|jpeg|svg|wav|ogg|tscn|tres|md))\)", re.I)
def git(*args):
    return subprocess.check_output(["git",*args],text=True).strip()
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--base",default="main")
    p.add_argument("--strict",action="store_true",help="exit nonzero on missing references or modified originals")
    a=p.parse_args()
    root=Path(__file__).resolve().parents[1]
    files=[x for x in root.rglob("*") if x.is_file() and ".git" not in x.parts]
    by_hash={}
    for f in files:
        if f.suffix.lower() in ASSET_EXT and f.suffix.lower() in {".png",".webp",".jpg",".jpeg",".svg"}:
            by_hash.setdefault(sha(f),[]).append(f.relative_to(root).as_posix())
    missing=[]
    optional_slots=[]
    archived_refs=[]
    documentation_examples=[]
    for f in files:
        if f.suffix.lower() not in {".md",".gd",".tscn",".tres",".cfg",".json"}:continue
        try: txt=f.read_text(encoding="utf-8")
        except UnicodeError:continue
        # Screenshot destinations are outputs, not required input assets.
        # Exclude only literal save_png destinations; keep other res:// checks strict.
        screenshot_outputs = set(re.findall(r"\.save_png\(\s*[\"\x27]res://([^\"\x27]+\.png)[\"\x27]\s*\)", txt)) if f.suffix.lower() == ".gd" else set()
        for m in GODOT_RE.finditer(txt):
            if m.group(1) in screenshot_outputs:
                continue
            raw=m.group(1).split("#")[0]
            target=(root/raw).resolve()
            if not target.is_relative_to(root) or not target.is_file():
                entry={"source":f.relative_to(root).as_posix(),"reference":"res://"+raw}
                source=entry["source"]
                if source=="art_catalog.gd" or source=="tests/test_art_slots.gd":
                    optional_slots.append(entry)
                elif source.startswith("docs/manjushage/archive/"):
                    archived_refs.append(entry)
                elif source.endswith("README.md"):
                    documentation_examples.append(entry)
                else:
                    missing.append(entry)
        for m in MARKDOWN_RE.finditer(txt):
            raw=m.group(1).split("#")[0]
            target=(f.parent/raw).resolve()
            if not target.is_relative_to(root) or not target.is_file():
                entry={"source":f.relative_to(root).as_posix(),"reference":raw}
                if entry["source"].startswith("docs/manjushage/archive/"):
                    archived_refs.append(entry)
                else:
                    missing.append(entry)
    originals=[]
    for f in files:
        rel=f.relative_to(root).as_posix()
        if "/originals/" not in "/"+rel:continue
        try:
            old=subprocess.check_output(["git","show",f"{a.base}:{rel}"],stderr=subprocess.DEVNULL)
            originals.append({"path":rel,"unchanged":hashlib.sha256(old).hexdigest()==sha(f)})
        except subprocess.CalledProcessError:
            originals.append({"path":rel,"unchanged":None})
    # Detect original assets removed from the working tree.
    try:
        base_paths = git("ls-tree", "-r", "--name-only", a.base).splitlines()
        for rel in base_paths:
            if "/originals/" in "/" + rel and not (root / rel).is_file():
                originals.append({"path": rel, "unchanged": False, "reason": "missing from working tree"})
    except subprocess.CalledProcessError:
        pass
    duplicates=[paths for paths in by_hash.values() if len(paths)>1]
    report={"missing_references":missing,"optional_art_slots_not_yet_populated":optional_slots,
            "archived_references":archived_refs,"documentation_examples":documentation_examples,
            "duplicate_image_groups":duplicates,"originals":originals,
            "note":"Optional art catalog slots are deliberately allowed to be absent because the loader has a procedural fallback. Missing runtime references and removed originals still fail strict mode. Only literal local paths are checked. Dynamic load paths, .import UID resolution, visual correctness and Godot runtime require separate tests."}
    print(json.dumps(report,ensure_ascii=False,indent=2))
    failed=bool(missing) or any(x["unchanged"] is False for x in originals)
    if a.strict and failed:raise SystemExit(1)
if __name__=="__main__":main()

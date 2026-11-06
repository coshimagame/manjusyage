# MANJUSHAGE 64 enemy concept crops — Codex handoff

Contains 64 transparent PNG crops (`sprites/`), 64 unmodified RGB crops (`source_crops/`), and original full concept sheet.

**IMPORTANT:** These are automated crops of a single concept sheet, not polished, independently illustrated production sprites. Transparency is approximate and may leave artifacts or remove dark outline pixels. Please review in Godot 4.6 before using.

## Vertical and horizontal scroll
Both scroll modes can load the same PNG as a provisional billboard. There are **no separately drawn top/side views**, rotation frames, firing or death animations. Do not claim otherwise. For side view and top view variants, commission or create approved distinct art before final production.

## Integration
1. Keep originals unchanged; put processed files in a dedicated assets/import folder.
2. Use manifest.json IDs `S01E01`...`S08E08` and avoid hardcoding unapproved names.
3. Use nearest-neighbor texture filtering; consider 2x/3x scaling for pixel-art display.
4. Inspect silhouettes and alpha edges; reject/replace crops that include text or other sprites.
5. Map stage/slot to movement and attack patterns separately.
6. Implement via safe feature branch and PR; do not merge main without user approval.

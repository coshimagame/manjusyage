# MANJUSHAGE Steam trailer production brief — v0.1 (2026-11-05)

**User-approved direction:** cinematic animated storytelling + **real captured gameplay**. Long-tail Steam sales; truthful advertising. This document is a production plan, **not a claim that video or footage has been rendered**.

## Source of truth / visual continuity
- Read `CANON.md`, `CHARACTERS.md`, `ART_ASSETS.md`, `STAGES.md`, `GAMEPLAY.md`, and the latest game source before creating shots.
- **Never change the faces, hair, clothing, or canonical visual identity of コルミィ, ジヨーザ, マフィオ.** Existing art takes priority; do not use the prior weapon-growth concept image with different faces as character artwork.
- Prefer actual assets from the repository and gameplay capture from **Godot 4.6**. Existing paths recorded in ART_ASSETS include `docs/images/menu.png`, `docs/images/gate.png`, `docs/images/boss.png`, `audio/title.wav`, `audio/ruins.wav`, `audio/sentinel.wav`, `audio/shot.wav`, `audio/hit.wav`, `audio/burst.wav`, `audio/pickup.wav`, `audio/gate.wav`, `audio/switch.wav`. **Confirm their current existence and licensing before use.**
- Label mockups as **CONCEPT / DEVELOPMENT FOOTAGE**; do not misrepresent unimplemented abilities or stage/worldline features as gameplay. Do not use unrelated internet search images as product assets.
- Existing approved protagonist portrait source is not confirmed in ART_ASSETS: **do not invent replacements**; use gameplay ships/silhouettes/abstract petal visuals until the correct originals are located.
- Music and SFX: original project sources only; prioritize a soft, nostalgic melodic opening, percussion-driven action crescendo, then one sustained note and silence. Sidechain or duck BGM during critical SFX. Check loudness/peaks and avoid clipping.

## 90-second storyboard (target, may cut to 60 seconds)
| Time | Visual / camera | Audio | Production gate |
|---|---|---|---|
| 00–08 | Black; a single red spider-lily silhouette blooms from procedural petals; slow dolly in | Wind/low pulse, delicate bell | Original animation; no character redesign |
| 08–16 | Three points of light appear in separate worldline fragments, moving toward one screen | Three distinct sound motifs, rising arpeggio | Abstract representation; no invented portraits |
| 16–28 | **Real Stage 1 gameplay capture**: flight, movement, enemy entry, shot impact, readable HUD | Gameplay shots + beat enters | Record directly from a runnable Windows build |
| 28–40 | Cut between actual abilities for each playable character, 3–4 sec each | コルミィ: bloom/crackle; ジヨーザ: scan/shield tone; マフィオ: intake/converted shot | Show only abilities verified in build; otherwise use labeled concept motion cards |
| 40–54 | **Real cooperative play** 1–3 pilots and boss attacks; sharp cuts on explosions | Rhythm intensifies, boss warning sound | Capture actual game, do not fake multiplayer |
| 54–67 | Horizontal→vertical/worldline change; petal transitions | Harmonized synths and distorted pulse | If not implemented, use labeled concept interlude or omit |
| 67–79 | Boss climax, shield/weapon progression, screen-filling petals | Crescendo, impact, sudden stop | Actual gameplay only for gameplay shots |
| 79–90 | Red spider lily fades into MANJUSHAGE title, Mw-fActory, Steam CTA; no invented release date | Warm resolving chord, lingering echo | Steam branding and store URL only after real page exists |

## Editing / export specification
- Working master: 1920×1080, 30fps, H.264 MP4, stereo AAC; pixel art should use integer nearest-neighbor scaling from 640×360.
- Preserve readability of projectiles, bullets, player silhouettes, and 3-player HUD on mobile screens.
- Produce a **15–20 second teaser first** with verified title animation and source-owned audio; next a 45–60 second gameplay-led cut, then 90-second full cut.
- Track shot ID, source file, capture commit SHA, status (real footage / concept), SFX cue, copyright origin, and approval in `docs/manjushage/ART_ASSETS.md`.
- Deliverables: `trailer/shotlist.md`, `trailer/audio_cue_sheet.md`, `trailer/exports/teaser_v01.mp4` (when actually rendered), source project and captions (JA/EN).
- Never overwrite original assets; do not commit huge encoded videos without checking repo storage policy (Git LFS or Release assets may be better).

## Next actions for Codex / Antigravity
1. Audit current game assets, playable scenes, existing official portraits and original audio. Record exact available paths.
2. Capture real gameplay from current Windows build with commit SHA; report whether 3P, growth, shield, absorption, and vertical scroll **actually work**.
3. Assemble a 15–20s teaser with existing assets; generate only original petal/light overlays; make both a clean/no-text and captioned export.
4. Prepare sound effect cue sheet and original music arrangement; verify timing and clipping.
5. Build the 60–90s cut from actual footage, replacing labeled concept shots as implementation catches up. Submit source, video preview, and a checklist for human review.

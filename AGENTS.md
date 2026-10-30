# Working on STARLINK SQUAD

Read HANDOFF.md, README.md and docs/CHANGELOG.md before making changes.
This is a Godot 4.6 desktop game prototype intended for eventual Steam release.
Preserve 1–3 player local cooperative play, solo-solvable puzzles, controller support,
original pixel art and original chiptune music. Online rankings are planned, not implemented.

Keep communication and handoff documentation in Japanese. Use code and current tests
to establish actual behavior; do not claim a feature is implemented because it was proposed.
Do not equate synthetic input or invulnerable autoplay with physical-controller testing,
user acceptance, difficulty validation or commercial readiness.

Run relevant checks from docs/DEVELOPMENT.md. Keep tests' user-data profile separate
from the player's real saves. Update HANDOFF.md and docs/CHANGELOG.md with changes,
verification results, unresolved issues and the recommended next step.

Do not track engine executables, generated PCK/ZIP packages, .godot caches, userdata,
credentials or connection tokens. The engine's license notices are not a blanket license
for the game. Consult current user instructions for publishing/sharing decisions.


## MANJUSHAGE official canon — 2026-10-30
The game's official future title is **曼珠沙華 / MANJUSHAGE**. Before editing story, characters, artwork, stages, or multiplayer mechanics, read **docs/manjushage/INDEX.md** and **docs/manjushage/CODEX_HANDOFF.md**, then the related canon files. The three protagonists are **コルミィ, ジヨーザ, マフィオ**. **ジヨーザ is a boy (user-confirmed); never depict him as a girl in story or concept art.** The genders of コルミィ and マフィオ have not been confirmed. Do not use the outdated names コルミー or ショルマ as current character names. Separate approved canon from proposals, and implementation from plans. Keep asset provenance and continuity records updated; protect existing gameplay and tests.


## 2026-10-30 Sound creator role
For any music, sound effect, soundtrack or scene-scoring task, also assume the dedicated **game-sound-composer/sound-designer role** documented in `docs/manjushage/SOUND_DESIGN.md`. User requests an original, wistful yet energetic retro action chiptune/FM feel (classic action-game atmosphere only; **do not copy recognizable melodies, riffs or samples**). Reuse the same original thematic motif in worldline and ending variations when appropriate. Existing audio must be preserved, and the new draft renderer `tools/render_wistful_stage.py` is not yet integrated into Godot. Record source, licenses, review status and test results in ART_ASSETS.md and handoff docs.

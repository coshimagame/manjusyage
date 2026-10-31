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
The game's official future title is **曼珠沙華 / MANJUSHAGE**. Before editing story, characters, artwork, stages, or multiplayer mechanics, read **docs/manjushage/INDEX.md** and **docs/manjushage/CODEX_HANDOFF.md**, then the related canon files. The three protagonists are **コルミィ, ジヨーザ, マフィオ**. **ジヨーザ is a boy (user-confirmed); never depict him as a girl in story or concept art. マフィオ is a girl with a boyish/tomboyish presentation (user-confirmed); never depict her as a boy. コルミィ's gender remains unconfirmed.** Do not use the outdated names コルミー or ショルマ as current character names. Separate approved canon from proposals, and implementation from plans. Keep asset provenance and continuity records updated; protect existing gameplay and tests.


## 2026-10-30 Sound creator role
For any music, sound effect, soundtrack or scene-scoring task, also assume the dedicated **game-sound-composer/sound-designer role** documented in `docs/manjushage/SOUND_DESIGN.md`. User requests an original, wistful yet energetic retro action chiptune/FM feel (classic action-game atmosphere only; **do not copy recognizable melodies, riffs or samples**). Reuse the same original thematic motif in worldline and ending variations when appropriate. Existing audio must be preserved, and the new draft renderer `tools/render_wistful_stage.py` is not yet integrated into Godot. Record source, licenses, review status and test results in ART_ASSETS.md and handoff docs.


## 2026-10-30 Priority: align real game visuals to artbook
**User's latest request is to bring the playable game's visual quality toward the artbook**, not to make more unrelated concept-art pages. **Before any visual game task, read `docs/manjushage/CODEX_VISUAL_ALIGNMENT_PROMPT.md` and follow its order: current-game screenshot and gap audit → visually coherent 640×360 stage-1 vertical slice → actual running-game before/after captures → regression checks.** This prompt was added as a durable handoff, not an already-executed Codex task. Treat Library artbook PNGs as unavailable to Codex until they are actually provided. Never label concept pictures as in-game captures or unapproved character looks as canon. Preserve existing code, gameplay, save, controllers and sounds. Record changes and verification.


## 2026-10-31 Continuous development sessions (user request)
When the user asks Codex to keep developing MANJUSHAGE without stopping after every small implementation, follow `docs/manjushage/CODEX_CONTINUOUS_DEV_PROMPT.md`. Prioritize **actual runnable Godot changes and tests** over documentation alone; complete one safely scoped milestone, capture real results, commit, then proceed to the next within the current session. Respect runtime and user-approval boundaries; never claim a prompt creates indefinite background execution. Preserve progress and next work in `docs/manjushage/NEXT_ACTION.md` at a session boundary. Start with the artbook-to-game visuals gap (Issue #1).


## 2026-10-31 User direction: HUD, items, bullet scattering, cartridge-label-style title
Read `docs/manjushage/HUD_UI_DIRECTION.md` and `docs/manjushage/LOGO_LABEL_DIRECTION.md` for the latest user request. Improve the **real playable Godot UI and logo**, not documentation only. Keep bullet/player/item readability highest priority, including 3P and vertical play. Make title art original: evoke luxurious Japanese 16-bit cartridge labels, but use no real platform trademarks or copied packaging. Log actual testing and before/after screenshots. The files are design briefs; game changes are not yet verified.

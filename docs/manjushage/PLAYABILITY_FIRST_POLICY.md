# Playability-first implementation policy (approved 2026-11-11)

## Decision
Prioritize a functioning, testable Godot 4.6 game over final visual polish. Temporary visuals are permitted for ships, enemies, bosses, backgrounds, projectiles, effects and UI **when they enable real gameplay**. This supersedes any assumption that missing approved art blocks implementation; it does **not** imply that placeholder art is approved final art.

## Non-negotiable safeguards
- Never overwrite, delete, or silently replace existing originals or previously approved images. Preserve original files and references.
- Keep placeholders clearly labeled as provisional; do not describe them as approved art or completed final assets.
- Route visuals through independently replaceable paths/resources (or centralized mapping) so each element can be swapped without changing gameplay logic.
- Keep existing-path fallback until all references are migrated and tested.
- Do not merge PR #50/#51 merely because placeholder visuals are now allowed; validate dependencies, paths and Godot tests first.

## Implementation order
1. Boot, controller/keyboard input, player movement, firing, collisions, damage, game-over and restart.
2. One complete playable stage with enemies, midboss/boss, progression and a downloadable test build.
3. Three-player local co-op and the remaining stages, then difficulty and worldline variants.
4. Replace provisional visuals incrementally after approval, without altering gameplay behavior.

## Acceptance checks
- Godot 4.6 headless import/test and CI build pass.
- A human can launch and play a build, and the exact build artifact is linked.
- Asset swaps preserve gameplay and no approved original is lost.

This file is a development decision, **not evidence that the implementation or asset migration is complete**.

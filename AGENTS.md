# Working on 曼珠沙華 (MANJUSHAGE) — internal legacy ID STARLINK SQUAD

## 🚨 最新引き継ぎ / 2026-10-31：ビジュアル改修を実装済み、最優先はCodexによる実行検証
**ユーザーからChatGPTとCodexに向けた明示的指示：『最高のゲームクリエイターチームになろう』『それをCodexにも伝えておいて』。** ChatGPTは実装・企画・設定整合・レビューの一員、Codexは実行環境でのGodot改修・検証・継続開発を担当し、ユーザーが最終的な見た目と面白さを判断する。役割は協力の目安であり、ChatGPT→Codexのライブ会話同期や自動起動を意味しない。

**今のGitHub `main` にはChatGPTが直接コミットしたVISUAL PASS 01が含まれる。** `biological_stage.gd` の生体ステージ背景／赤い曼珠沙華 `f2381fcef`、`game.gd` のHUD・ハート/結晶アイテム・ひし形敵弾・花弁エフェクト・赤×白銀の仮ロゴ `6d81f9dcb`、敵2シルエット `7972f076c`。詳細は `docs/manjushage/VISUAL_PASS_01.md`、開いている [Issue #1](https://github.com/coshimagame/starlink-squad/issues/1)、`docs/manjushage/NEXT_ACTION.md`。**資料だけの更新ではないが、Godot 4.6のパース／実描画／1〜3人テストは未確認**。静的括弧検査のみ。**コードが動くと仮定せず、Codexは第一に実際のエンジンで修正・検証すること。**

**作業を始めるとき（最優先）**
1. `git status` と最新 `main` / HEADを確認。ローカルで古い展開ZIPを編集しない。未コミット作業や他人の編集を上書きしない。
2. **Godot 4.6 Standard**でプロジェクトをインポート／起動し、パース・エディターエラーを解消。ユーザーは4.7.2で変換警告を見たことがあり、版の変換でプロジェクトを壊さない。
3. 赤い残響の道中・救助・ボス、メニュー、縦スクロールの**実ゲームスクリーンショット**で、ユーザーが指摘した「紫の輪郭円の背景、同形敵、四角い敵弾、仮HUD」が改善されたか確かめ、プレイアブルな描画へブラッシュアップ。スクリーンショットはコンセプト画と混同しない。
4. `docs/DEVELOPMENT.md`の検証（インポート、既存1〜3P自動攻略、保存、音楽、プロローグ、縦区間、ボス）を実行、スクリプトエラーやリソース問題があれば修正。実機ゲームパッドと人間の操作は別途未検証と明記。
5. **確認後も**美しい背景・機体・生体ボス・弾幕・アイテム・HUD・ロゴを繰り返し改善。ユーザー好みの赤×白銀ロゴ、3人の性別/名前、視認性を優先。商用キャラ・既存ゲームの絵/音をコピーしない。仮案は仮案で試し、勝手に正史化しない。
6. 実際の変更、Before/Afterスクリーンショット、テスト結果、残課題、コミットを `HANDOFF.md`、`docs/CHANGELOG.md`、`docs/manjushage/NEXT_ACTION.md` と Issue #1に記録。動作未確認なら未確認のまま、Issueを閉じない。

**重要：** `project.godot` の内部名 `STARLINK SQUAD` は旧セーブ互換の可能性で残してあり、旧名が残ること自体は旧コードが起動された証拠ではない。既存ユーザーのダウンロードZIPはGitHubの更新と自動同期しない。


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
The game's official future title is **曼珠沙華 / MANJUSHAGE**. Before editing story, characters, artwork, stages, or multiplayer mechanics, read **docs/manjushage/INDEX.md** and **docs/manjushage/CODEX_HANDOFF.md**, then the related canon files. The three protagonists are **コルミィ, ジヨーザ, マフィオ**. **ジヨーザ is a boy (user-confirmed); never depict him as a girl in story or concept art. マフィオ is a girl with a boyish/tomboyish presentation (user-confirmed); never depict her as a boy. コルミィ is an energetic, lively girl (user-confirmed); her detailed visual design remains unconfirmed.** Do not use the outdated names コルミー or ショルマ as current character names. Separate approved canon from proposals, and implementation from plans. Keep asset provenance and continuity records updated; protect existing gameplay and tests.


## 2026-10-30 Sound creator role
For any music, sound effect, soundtrack or scene-scoring task, also assume the dedicated **game-sound-composer/sound-designer role** documented in `docs/manjushage/SOUND_DESIGN.md`. User requests an original, wistful yet energetic retro action chiptune/FM feel (classic action-game atmosphere only; **do not copy recognizable melodies, riffs or samples**). Reuse the same original thematic motif in worldline and ending variations when appropriate. Existing audio must be preserved, and the new draft renderer `tools/render_wistful_stage.py` is not yet integrated into Godot. Record source, licenses, review status and test results in ART_ASSETS.md and handoff docs.


## 2026-10-30 Priority: align real game visuals to artbook
**User's latest request is to bring the playable game's visual quality toward the artbook**, not to make more unrelated concept-art pages. **Before any visual game task, read `docs/manjushage/CODEX_VISUAL_ALIGNMENT_PROMPT.md` and follow its order: current-game screenshot and gap audit → visually coherent 640×360 stage-1 vertical slice → actual running-game before/after captures → regression checks.** This prompt was added as a durable handoff, not an already-executed Codex task. Treat Library artbook PNGs as unavailable to Codex until they are actually provided. Never label concept pictures as in-game captures or unapproved character looks as canon. Preserve existing code, gameplay, save, controllers and sounds. Record changes and verification.


## 2026-10-31 Continuous development sessions (user request)
When the user asks Codex to keep developing MANJUSHAGE without stopping after every small implementation, follow `docs/manjushage/CODEX_CONTINUOUS_DEV_PROMPT.md`. Prioritize **actual runnable Godot changes and tests** over documentation alone; complete one safely scoped milestone, capture real results, commit, then proceed to the next within the current session. Respect runtime and user-approval boundaries; never claim a prompt creates indefinite background execution. Preserve progress and next work in `docs/manjushage/NEXT_ACTION.md` at a session boundary. Start with the artbook-to-game visuals gap (Issue #1).


## 2026-10-31 User direction: HUD, items, bullet scattering, cartridge-label-style title
Read `docs/manjushage/HUD_UI_DIRECTION.md` and `docs/manjushage/LOGO_LABEL_DIRECTION.md` for the latest user request. Improve the **real playable Godot UI and logo**, not documentation only. Keep bullet/player/item readability highest priority, including 3P and vertical play. Make title art original: evoke luxurious Japanese 16-bit cartridge labels, but use no real platform trademarks or copied packaging. Log actual testing and before/after screenshots. The files are design briefs; game changes are not yet verified.


## 2026-10-31 User direction: build provisional versions, study classic shmups
The user explicitly requests **coherent provisional implementations even for undecided art**, then repeated refinement. Read `docs/manjushage/PROVISIONAL_VISUAL_BIBLE_V01.md`, `CLASSIC_STG_INSPIRATIONS_V01.md`, and `NEXT_ACTION.md`. Inspirations from Salamander, TwinBee, R-TYPE and Area 88 should be converted into **distinctive original mechanics and aesthetics** rather than copying their protected assets, distinctive sprite/ship shapes, stage patterns, text or music. Characters: **コルミィ energetic girl / ジヨーザ boy / マフィオ tomboyish girl**. Four worldlines change the spider-lily color (crimson, silver-white, blue-violet and gold are **provisional choices**, not approved colors). Prototype/approve/implement/test are separate states. Develop actual Godot gameplay in small measured milestones instead of stopping at documents.

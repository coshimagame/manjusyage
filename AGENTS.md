# Working on 曼珠沙華 (MANJUSHAGE) — internal legacy ID STARLINK SQUAD

## 2026-11-15 / Codex 作業開始時の最新指示書確認（ユーザー正式依頼）

**すべてのCodex開発セッションの作業開始時に、最新のリポジトリ状態と指示書を確認すること。** これは運用指示であり、Codexが自動起動・自動同期するという意味ではない。

1. `git status` で未保存変更を保護し、`git fetch` 等でリモートの最新状態を取得。作業ブランチと `main` の差分を把握し、他の作業・未マージPR #50 / #51を上書きしない。
2. この `AGENTS.md` と `docs/manjushage/INDEX.md`、`docs/manjushage/CODEX_HANDOFF.md`、`docs/manjushage/NEXT_ACTION.md`、該当分野の最新正式指示書を読む。存在しないファイルは未存在と記録し、読んだふりをしない。
3. **管制会話UIの確定ルール：** `docs/manjushage/CONTROL_ROOM_DIALOGUE_DIRECTION.md` を確認。ステージ後などムゥとの管制会話では **左に相手の顔、右にムゥの顔**。正式な顔素材を保護し、差し替え可能にする。文書保存とゲーム実装は別扱い。
4. 最新正式決定／旧案／未決事項を区別し、矛盾があれば勝手に正史化しない。コード・素材・参照の実在を確認する。
5. 作業報告には、**実際に読んだ指示書のパスとコミット、実装した内容、Godot 4.6の実行検証結果、未実施項目**を記録する。未検証を成功と記さない。
6. この規則は作業開始時の確認を要求するもので、実際にCodexが読んだことの証明には作業ログが必要。


## 🎮 制作チーム正式名称（ユーザー決定／2026-10-31）
**Mw-fActory（ムゥファクトリー）**。これ以降、ChatGPT、Codex、専門ロールによる『曼珠沙華（MANJUSHAGE）』制作チームの呼称を **Mw-fActory** に統一する。大文字・小文字・ハイフンは **Mw-fActory** を正確に維持。作品タイトルとチーム名は別。正式ロゴ、スタッフ表記・会社登記等は決定していないため推測・捏造しない。GitHubリポジトリ名、Godotの内部名、保存ID、セーブデータを名称変更のために無断で変更しない。


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


## 2026-10-31 / ART SLOT v0.1: 好きなChatGPT絵をPNGで差し替える（ユーザー直接指示）
ユーザー：「正式でなくても仮で全部入れて磨く」「グラフィックは差し替えすぐできるでしょ？」「あなたのグラフィック結構いいのあるからそれでいれれるように」。`art_catalog.gd`、`art/active/README.md`、`tests/test_art_slots.gd` を追加し、`game.gd`・`biological_stage.gd` へ**11個のPNGスロット**を実装：赤×白銀タイトルロゴ／タイトル背景／コルミィ・ジヨーザ・マフィオ各機体／狙撃・扇状敵／HP・エネルギーアイテム／生体ステージ遠景／ボス本体。各PNGが**存在すれば描画に利用し、なければ現行Godotでの手描きへフォールバック**。ステージ危険壁やボス弱点はPNGの上にゲーム処理で表示し、当たり判定や保存データ・既存機能は変更しない。Godot4.6のインポート／実画面・1〜3人テストは**未実施**。

過去の生成コンセプトボードには実在メーカーの商標／旧名・性別の不整合があったため**丸ごと実装しない**。ユーザー選好の赤×白銀タイトル文字のみ抽出した試用ロゴと、前に好評だった緑の回復アイコン／青い結晶のエネルギーアイコンは**このChatGPT会話でPNGの差し替え体験用ZIP**として準備。**ZIPの画像バイナリはGitHubリポジトリには未登録**であり、Codexから自動的に参照できない。Godotで表示するときはユーザーがZIP内の `art/active/*.png` を最新版展開フォルダへコピーする必要あり。試作採用は「正式キャラ外観の採用」ではない。

**Codexの次の一手**：GitHub最新版で `godot --headless --editor --path . --import --quit`、`tests/test_art_slots.gd`、旧1〜3P自動攻略を実行してエラーを直す。後日PNGが揃えば画像ごとに追加し、実スクリーンショットで視認性・比率・性能をレビュー。READMEに従って差し替えだけで済む構造を維持。既存ユーザーPCの古いZIP展開版に自動反映されないことも忘れず案内。


## 2026-10-31 重要・ユーザー最新指示：仮案も実装優先、ムゥのストーリー演出と雅楽的な未来アクション音楽
**制作手順の正式方針**：「決まったことや提案はどんどんゲームに入れる。破綻したら直す。まずゴリゴリ作る」。
- 最優先共通ルールは docs/manjushage/PROTOTYPE_FIRST_DIRECTIVE.md。提案を未承認のまま**試作として実装**してよいが、公式設定への昇格はしない。既存ゲームのプレイ・セーブ・権利を守り、バグが出たら修復して先へ。Codexの無期限自動起動を有効にするものではない。
- **音楽**：ユーザー希望は**雅楽の幽玄さ・派手なシューティングの疾走・少しの不気味さ・哀愁・美しく儚い・永い時を越えた未来感**。音楽制作チーム内の作曲/雅楽和声/STG編曲/SEミックスの観点でA/B案を批評し、試作音を聴いて改善する。 docs/manjushage/SOUND_DESIGN.mdを最初に読む。実在の作曲家を雇ったという主張は禁止。
- **ムゥとの交流・アニメーション**：ユーザーが「ムゥとのやりとりのアニメーション、ストーリー部分を充実させたい」。docs/manjushage/MU_CINEMATICS_V01.md を読んで実装。既存 prologue.gd は **6→8ページ、ムゥの整備室の図形アニメ・工具の火花・2段階の字幕字送り・無線風の会話**を追加済み（コミット 30b39e65）。人物顔や正式台詞は未確定のため、影絵・仮台詞で実装。原設定の別世界線のムゥ／1周目生還予定だったが予期せぬ異常で命を落とす／2周目に生き残る点を守る。
- **必須次作業**：Godot 4.6で最新版のprologue.gdをインポート・実描画・スキップ／ページ送り・--training-shot・--workshop-shotを検証し、出たエラーを直す。同時にgame.gdのアートスロットと生体背景、1〜3人・音・セーブも回帰。Godot実行検収なしで「動作確認済み」と言わない。続けてムゥの道中無線・別れ／再会のテスト用シーンと音楽モチーフを短い単位で追加する。

## 2026-10-31 追加確定設定：クゥ（Kuu）
**クゥ＝ムゥの妻**。**機体搭載OS**で、3人にとっての**仮想のお母さんのような存在**。**なぜか全世界線に存在する**。型番はなく、**OS5という表記は誤り**。生死、OSになった理由、世界線を跨ぐ同一性、各ムゥの婚姻関係、記憶共有は未決。ユーザーが未決定事項を後から覆す可能性に備え、キャラ設定に勝手な理由付けをせず仮案と決定を分離する。Codexが制作する際の最新基準：docs/manjushage/CANON.md C-054〜056、CONTINUITY.md、CHARACTERS.md、STORY.md。

## 2026-10-31 最新クゥ設定 C-058（元人間・愛・矛盾）
ユーザーが確定した**物語の中心**：クゥは**元々人間**で、誰もが戦う理由を失えるようにと願う愛の存在。しかし**クゥの存在がそれぞれの戦う理由になってしまう**ため、クゥ自身は深く苦しむ。機体OS（OS5ではない）、ムゥの妻、3人を導く仮想の母的存在、全世界線に理由なく存在する。**以前の「元人間か未決」はここで上書き**。「なぜOSに」「いま身体があるか」「原形」の正体は未決。ムゥが原形を探すのはC-057の仮の物語案。黒幕化や登場人物の主体性を奪う描写は避け、各人が異なる理由で戦う悲劇を丁寧に脚本・アニメーション・音楽へ仮実装して磨く。詳細はCANON.md、STORY.md、MU_CINEMATICS_V01.md。

## 2026-10-31 KU-ORIGIN-001：クゥの並列接続と緊急OS化
ユーザーが決定：元人間クゥは戦いをなくすため敵軍ネットワークへ思考を並列に繋いだが、自我が分散して存在が薄れ、**雲散霧消を防ぐ緊急措置としてOS化された**。ユーザーの最新**有力案だが未確定**：その救助・OS化を夫のムゥが実施。CANON C-059/060、KUU_ORIGIN_PARALLEL_NETWORK.mdを遵守。いま人間の身体があるか、なぜ全世界線にいるか、原形の正体は未決。映像・音は仮実装して試し、Godot実機検証結果を残す。

## 2026-11-01 実装監査と修正の引き継ぎ（最優先）
今回の最新版で、プロローグ8ページ・3人の固有能力・1面クリア後のブリーフィング・32x20の細身3機PNGとステージ別図鑑解放をコードへ反映した。**Godot 4.6での実機検収はまだ実施していない**。次回作業の冒頭では docs/manjushage/STATUS_AUDIT_2026-11-01.md を読み、列挙された新旧全自動テストを隔離した user:// で実行する。
重大な発見：audio/ending.wav と audio/wistful_demo.wav は未配置（音源の新作完成ではない）。game.gd は安全なタイトル/道中曲フォールバックへ改修済。古いテストが実際と食い違っていたため修正済。エンディング専用BGMと新曲インポートは今後の開発課題。
3人の仮決定人物ビジュアルを勝手に変更しない。機体は細身3機PNGをart/activeへ導入済。戦闘は1面のみ完成を目指す試作。2面以降に戦闘はないため出撃不可。図鑑閲覧はマフィオ4面・ジヨーザ5面・コルミィ6面から。全ての「修正コード反映」と「テスト合格」は区別する。


## 2026-11-05 / 8ステージ背景・断面・敵配置：並行制作ブリーフ（提案）
ユーザーは、いま見られる1面だけでなく **全8面について背景、レベル断面、敵の登場、スクロール、ボス、周回ごとの変化を同時に検討し、ステージ別PDFで見たい**と希望。CodexとAntigravityは視覚・レベル設計に着手する前に、`docs/manjushage/STAGE_BACKGROUND_CONCEPTS_V01.md` を読み、現行 `STAGES.md`・`ENEMIES.md`・`CANON.md`と照合する。未決のボスやスクロール案は**未承認の試作用**であり勝手に正史にしない。古典STGはゲームデザインの参考に限定し、元の絵・音・ステージを改造流用しない。実装・Godot実走・画像採用は別状態として記録する。文書を読むことはCodex/Antigravityの自動起動を意味しない。

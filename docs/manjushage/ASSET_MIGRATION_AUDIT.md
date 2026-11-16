# 素材移行・参照監査（2026-11-09、進行中）

この記録は**完了報告ではない**。承認済み原画の同定と main への統合前に、未確認項目を見える化する。

## 確認した実装
- `art_catalog.gd` の13スロットは、整理後のパスを優先し、既存の `art/active/<slot>.png` にフォールバックする。アイテム4件は中間の旧分類パスにも対応する。
- `tests/test_art_slots.gd` は13スロットの数、代表的なパス、取得テクスチャの寸法を検査する。ただし原画との一致、全パスの実在、実画面での視認性は検証しない。
- `art/README.md` に記録された2026-11-07のGodot Actions実行は**過去の記録**であり、今回のコミットに対するテスト実行ではない。

## main統合前の必須確認
- [ ] 3人の承認済み原画PNGの出典・承認状態・SHAを確定し、元ファイルを保護して移行する。未同定の画像を採用済みと記載しない。
- [ ] `art/active/` と `art/concepts/` の実ファイルを列挙し、移行前後のSHAを照合する。
- [ ] docsの正史・旧案・未決事項を全ファイルで照合し、矛盾を記録する。
- [ ] PR #50（README）→ PR #51（分類）の依存関係と最新mainの差分を再確認する。
- [ ] Godot 4.6でインポート、`tests/test_art_slots.gd`、実ゲーム起動を再実行する。
- [ ] Windows版のタイトル・出撃・3機・敵・背景・UIを承認済み画像と比較し、見た目の退行がないことを確認する。
- [ ] mainへ反映後、docsのリンク、artの参照、実在画像、Godotテストを再検証する。

**現状：未完了。** READMEだけのフォルダはPNG納品を意味しない。実画面確認前に完了扱いしない。

## 2026-11-09 追加確認（GitHub差分）
- PR #50 は `main` 向け未マージ、PR #51 は #50 のブランチ向け未マージ。#51 は変更65ファイル、head `43a2623475b4ad7e6ce222ba3ee159c59e555b48`（確認時点）。
- `main...cleanup/canon-and-art-folders-20261106` の比較は `diverged`、整理ブランチが77コミット先行、`main` が3コミット先行。変更65ファイル。**マージ可能判定だけではこの3コミットの内容整合性や動作を保証しない。**
- この比較とファイル一覧確認はGitHub API上の静的検査。実PNGのSHA照合、リンクの全件検証、Godot実行テストを行ったことを意味しない。
- `main` への反映前に、#50 → #51 の順序と他PRによる最新の変更を再照合する。承認済み原画未同定のままPNGを追加・置換しない。

## 2026-11-09 20時台 JST 再監査
- PR #50: `main` 向け open / 未マージ、head `39f209b71d99ac77ce051aba385c0bbcffdfa774`。PR #51: #50 ブランチ向け open / 未マージ、head `4f8cc5e7c65c7e093a23aa05a7c517d1651473bf`。
- `main...cleanup/canon-and-art-folders-20261106` は `diverged`、78 ahead / 3 behind、変更65ファイル。比較に現れる `art/` の変更はREADMEのみで、承認済み原画PNGの移行が完了した根拠はない。
- 現時点でGitHub APIによるPRメタデータ・変更パス確認まで。Godotの最新headに対する実行検証、SHA照合、実画面比較は未実施。完了条件未達のためマージは保留する。

## 2026-11-10 21時台 JST 自動検証記録
- GitHub Actions `Art catalog and reference validation` は整理ブランチ head `0fe112c18da97adc1482a393c2fa55ee19b6d948` に対し、2026-11-09 11:16 UTC開始の2実行がともに `success`。ワークフロー定義上、Godot 4.6 headless import と `tests/test_art_slots.gd` を含む。ただしWindows実画面の承認原画比較や全リンク/SHA監査は含まない。
- PR #50 と #51 は依然 open / 未マージ。#51 の変更65ファイル中、`art/` 配下の変更はREADMEのみで、承認済み原画の移行完了を示さない。
- 上記成功は**分類ブランチ上の限定的な自動テスト成功**であり、`main` 統合後の動作・画像一致の保証ではない。未完了チェック項目を維持し、承認済み原画を推測で置換しない。

## 2026-11-10 22時台 JST 実ファイル所在・Git blob SHA棚卸し
- 整理ブランチ `23dcb9ff5bb54194cd352a48dbe2f6ee8a648e0e` のGit treeを再帰取得（`truncated=false`）。画像拡張子PNG/JPEG/WebPの実在ファイルは **18パス**。これは承認済みの証明ではない。以下のSHAは**Git blob SHA-1**であり、PNG実バイト列のSHA-256ではない。
- `art/active/` は機体3点とタイトルロゴ1点、`art/concepts/` はパイロット案3点。新分類フォルダへの画像複製・移動は確認できず、既存ファイルは元の場所に残っている。
- `books/` の画像3パス（うちタイトル2パスは同一blob）、`docs/images/` 3パス、`docs/screenshots/latest/` 5パス。スクリーンショットは原画と同一視しない。

| 実在画像 | Git blob SHA-1 |
| --- | --- |
| `art/active/ship_cormii.png` | `a99e9254ee1f369aea52f50fd783dceb08695796` |
| `art/active/ship_jiyoza.png` | `fa2cb19f349cdb7f5fcb91e864893b18474a9b82` |
| `art/active/ship_mafio.png` | `944b3a712c162326ec44ba76bc6f1ba786129a0f` |
| `art/active/title_logo.png` | `d3c8feb640dc2a86fac4d15cb2d36f33c9eafba0` |
| `art/concepts/pilot_cormii_slim_v01.png` | `cab57f69824896fe311c2b88eaf619cd9c17cf0f` |
| `art/concepts/pilot_jiyoza_slim_v01.png` | `49cccb79c0feaeb9b9ece900fc95a4d2276b246c` |
| `art/concepts/pilot_mafio_slim_v01.png` | `5344d116c6278c2ec1f9f654f3cfb706ea144223` |
| `books/perfect-guide/supplements/source-expansion-v0.2/bio-boss-v0.7.png` | `96c3e40414988f6fae2302c53804fe988a8005f9` |
| `books/perfect-guide/supplements/source-expansion-v0.2/title-v0.6.png` | `1052f57b37ffcc8e88fc1de70ae13b927f37f6b2` |
| `books/perfect-guide/v0.1/title-v0.6.png` | `1052f57b37ffcc8e88fc1de70ae13b927f37f6b2` |
| `docs/images/boss.png` | `082769ba51669e8dbf9abcb6da8b428af1e67d1a` |
| `docs/images/gate.png` | `214c77abbe3b8c4ccffa07ba49da8fed17f78c9a` |
| `docs/images/menu.png` | `6c3106947eff65457007725ea56e7b0e9f225f9a` |
| `docs/screenshots/latest/boss.png` | `feb1f2ba87b67918bb9978e394f41b0c9c271d58` |
| `docs/screenshots/latest/briefing.png` | `db827124e4f1585f5ef67d03834f1cf5f2f3f207` |
| `docs/screenshots/latest/menu.png` | `4c23ed65400c9261b299cb567f002e85f559b07d` |
| `docs/screenshots/latest/status.png` | `e0a4d7a46a9ce133eb1f546c826f7f72c94f3fa7` |
| `docs/screenshots/latest/vertical.png` | `e62d07eb44ecabaf16fbf9bf8df422b3bbe70b87` |

**残作業**：各画像の承認根拠と利用用途を照合し、必要なものだけ原本を保持したまま分類先へコピーする。コピー後にblob SHA一致を検証し、参照・ゲーム描画をテストする。現時点で画像の移行・承認・main統合を完了したとは扱わない。

## 2026-11-11 07時台 JST 検証と実装方針の更新
- PR #50、#51 はともに open・未マージ、GitHub競合判定は mergeable。ただし #51 のベースは #50 の整理ブランチであり、直接 main 向けではない。順序を維持する。
- #51 の変更65ファイルを再取得。`art/` 内は分類先READMEであり、分類先へのPNG移行を示す追加画像は含まれていない。原本18パスの監査記録を維持する。
- ユーザーの最新方針「まず動くゲーム、仮ビジュアルは後で差し替え可」を `PLAYABILITY_FIRST_POLICY.md` に明文化（コミット `bc154b5a4a5f97d7789b02b61ccaca7099f1577a`）。**承認済み原画の上書き許可ではない**。
- 上記コミットに対する GitHub Actions `Art catalog and reference validation` は run `42910763779` が `completed/success`。限定的な自動検証であり、Windows実画面比較、原画承認、実画像移行、main統合後テストは未了。
- この確認では画像の移動・置換・PRマージを行わない。mainへの整理反映は未完了。

## 2026-11-11 08時台 JST mainとの実画像差分（重要）
- Git treeの再帰取得（双方 `truncated=false`）で、**mainに画像20パス、整理ブランチに18パス**を確認。従来の「18パス」は整理ブランチ限定の数であり、リポジトリ全体の最新画像数ではない。
- mainにのみ存在する実画像2点：
  - `art/ui/character_hub_ui_20261106.png` — Git blob SHA-1 `0e2cb68d06e5cd563fd66373cde8a69a63803acf`
  - `art/ui/character_system_ui_20261106.png` — Git blob SHA-1 `8b091ec2891a7e50860304f4692945524bb83da7`
- 既存の `art/active/` 4画像、`art/concepts/` 3画像はmainと整理ブランチで同じGit blob SHA。上記2点の承認状態は未確認であり、未承認・削除対象と断定しない。
- **統合前にmainのUI画像2点を保持することが必須。** ブランチに存在しないからといって消去しない。PR #50（main向け）と #51（#50向け）の依存関係を保ち、最新mainを取り込んだ上で差分・参照・Godot検証を実施する。
- 今回はGit treeの静的照合のみ。PNGコピー、SHA-256照合、Windows実画面確認、main統合後のGodotテストは未実施。完了扱いしない。

## 2026-11-11 18時台 JST 最新mainとの差分再照合
- Git treeを再帰取得し、mainの画像20パスと整理ブランチの画像25パスを照合。整理ブランチの25パスには元画像7点の分類先コピー7パスが含まれるため、**画像の種類が7点増えたという意味ではない**。
- 分類先コピー7点は元画像とGit blob SHAが一致。元の7パスは残存し、削除されていない。
- mainの `art/ui/character_hub_ui_20261106.png`（`0e2cb68d06e5cd563fd66373cde8a69a63803acf`）と `art/ui/character_system_ui_20261106.png`（`8b091ec2891a7e50860304f4692945524bb83da7`）は整理ブランチにはない。統合時に両方を保護する。
- **新たな注意点**：`docs/screenshots/latest/` の5画像は同一パスでもmainと整理ブランチでblob SHAが異なる。boss、briefing、menu、status、verticalの5点を一括上書きせず、撮影元ビルド・更新日時・表示内容を比較して最新の適切なものを採用する。これらは原画ではなく動作証跡として扱う。
- PR #50、#51はopen・未マージ。分類先の画像コピーとGit tree比較はGodotの描画確認やリンク全件検査の代替ではない。main統合後の検証まで完了扱いしない。

## 2026-11-11 21時台 JST 画像ファイル名と実装スロットの差異
- PR #50（main向け）とPR #51（#50向け）はともにopen・未マージ。#51 head `cf13440049b2712a93eefed0e2ac92409164c6cc`、変更73ファイル。
- 分類先の7画像は `art/characters/{cormii,jiyoza,mafio}/ship_{名前}.png`、`pilot_*_slim_v01.png`、`art/backgrounds/title/title_logo.png`。一方、`art/README.md` の自動読込対象は機体 `ship.png`、人物 `portrait.png` / `face.png`、タイトル背景 `backdrop.png` と説明されている。**分類先へコピー済みであることとゲームの自動採用は別**。`art_catalog.gd` の実パス定義と照合し、必要なら元画像を保護したまま明示的なマッピングを追加すること。
- `art/README.md` 末尾の「子フォルダは案内READMEのみ」は7画像追加以前の古い記述。今後の更新で「7画像はコピー済み、承認済み原画の同定とゲーム接続は未完了」と修正する。
- 今回はPR・監査資料・保存先ガイドの静的確認のみ。Godot実行、全参照・全リンク検証、mainへの統合は未実施。**完了ではない**。

## 2026-11-13 14時台 JST 最新PR・CI再確認
- PR #50 は `main` 向け open・未マージ（head `39f209b71d99ac77ce051aba385c0bbcffdfa774`）、PR #51 は #50 ブランチ向け open・未マージ（head `122977314ecb56938ca5b5f44bb89680bee9b1ca`）。両PRともGitHub上の `mergeable=true` は競合判定に過ぎず、素材の承認・参照・描画検証を意味しない。
- `main...cleanup/canon-and-art-folders-20261106` 比較は `diverged`、整理ブランチ90コミット先行、mainが3コミット先行。main側の最新比較基点 `5adcf719334b9fe3886f02f6256e7d0df1b792f3`。main固有のUI画像2点と同名スクリーンショット5点の差異は既存監査のとおり保護・精査が必要。
- #51 head `122977314ecb56938ca5b5f44bb89680bee9b1ca` に対するGitHub Actions `Art catalog and reference validation` run `43032336535` は `completed/success`。これはそのコミットの限定的なCI成功であり、Windows実画面比較、承認済み原画同定、全Markdownリンク・画像SHA検証、main統合後テストを証明しない。
- 今回はGitHub APIでのPR状態・差分・CI確認。未確認の原画を移動・置換せず、PR #50→#51の順序を維持する。**main反映・全参照検証の完了条件は未達。**

## 2026-11-15 21時台 JST main差分・新指示書の追跡
- GitHub比較 `main...6e6026ea677af350f459768cce85eb811ac894ed` は `diverged`、整理ブランチが92コミット先行、mainが7コミット先行。比較時のmain HEADは `d4ab8486dfb2a059d2e1754e742d540f7af46ae4`。この差分は古い監査の「3 behind」から増えているため、統合前に必ず再ベース差分を確認する。
- PR #50の変更パスは `README.md` のみ。PR #51は分類先PNG7点、docs、art、`art_catalog.gd`、テスト、CI定義を含む73パス。依存関係を崩さずに扱う。
- 最新mainにはユーザー確定の管制会話演出 `docs/manjushage/CONTROL_ROOM_DIALOGUE_DIRECTION.md`（ムゥの顔を右、会話相手の顔を左）と、Codexが作業開始時に最新指示書を確認する `AGENTS.md` の更新がある。#51統合時に両ファイルを保護し、必要なら `CURRENT_SPEC.md` の参照にも反映する。**指示書の存在はゲームへの実装完了を意味しない**。
- 既知のmain固有UI画像2点と同名スクリーンショット5点の差分は未解決。原画承認の同定、全リンク、実画面比較、main統合後のGodot検証も未実施。**完了条件未達につきPRのマージは保留**。

## 2026-11-16 01時台 JST PR依存関係と最新差分の再確認
- GitHub APIでPR #50は `open`、`merged=false`、`main` 向け、head `39f209b71d99ac77ce051aba385c0bbcffdfa774`、`mergeable=true` と確認。
- PR #51は `open`、`merged=false`、#50の `cleanup/simple-repo-navigation-20261106` 向け、head `ece2867868c1ef2f85b6f2a11024d7771b8c9e9a`、`mergeable=true` と確認。依存PRを飛ばしてmainに直接マージしない。
- `main...cleanup/canon-and-art-folders-20261106` は `diverged`、整理ブランチ94コミット先行、mainが7コミット先行、差分73パス。比較時main HEAD `d4ab8486dfb2a059d2e1754e742d540f7af46ae4`。
- 既存監査で特定したmain固有UI画像2点とスクリーンショット5点の差分、原画承認状態、全参照検証、main統合後のGodot動作確認は未解決。`mergeable=true` はこれらの検証完了を意味しない。
- 本確認はPRメタデータ・GitHub比較・既存監査資料の照合。画像の移動・置換、mainマージ、Godot実行は行っていない。**完了条件未達**。


## 2026-11-16 11時台 JST 再照合（main統合前）
- GitHub APIでPR #50はopen/未マージ、base `main`、head `39f209b71d99ac77ce051aba385c0bbcffdfa774`。PR #51はopen/未マージ、base `cleanup/simple-repo-navigation-20261106`、head `b0ba43d3c4702718be32716b65be7a5c402796e4`。両PRのmergeable=trueは静的競合判定のみ。
- 比較 `main...cleanup/canon-and-art-folders-20261106` はdiverged、95 ahead / 7 behind、73変更パス。main head `d4ab8486dfb2a059d2e1754e742d540f7af46ae4`。この比較では新たな画像保護・参照検証の完了を示す根拠は得られていない。
- 従来の未解決事項（承認済み原画の同定、main固有UI PNG 2点、同名スクリーンショット5点の比較、全Markdown/画像参照、統合後Godot 4.6テスト、Windows実画面比較）を引き継ぐ。未承認の画像を正式採用せず、既存原画を上書きしない。
- 今回の作業はGitHub PR・差分・監査記録の照合であり、Godotの実行やmainへの統合ではない。**完了条件未達。**

## 2026-11-16 15時台 JST PR競合判定の変化
- 最新GitHub PR取得で **#50 はopen、mergeable=false**、#51はopen、mergeable=true。#50の判定は以前のtrueから変化したため、原因（mainの新規変更との衝突かGitHub判定中か）を解消するまで両PRともマージしない。
- `main...cleanup/canon-and-art-folders-20261106` は **diverged、96 ahead / 10 behind、73変更パス**。前回の95 ahead / 7 behindからmain側も進行。main側変更を上書きしないよう、差分・衝突箇所を改めて照合する。
- この時点で承認済み原画の同定、main固有UI画像2点・スクリーンショット5点の保護比較、全リンク・参照、統合後Godotテストは未完了。**mainへの統合・完了通知は行わない**。

## 2026-11-16 17時台 JST PR判定の再取得と新規ラフ画の保護
- GitHub APIでPR #50・#51はともにopenで、今回の`mergeable=true`を確認。15時台に記録した#50の`false`から変化したが、GitHub側の一時判定か競合解消かは未確定。`mergeable=true`のみを根拠に統合しない。
- `main...cleanup/canon-and-art-folders-20261106`は97 ahead / 10 behind、73変更パス。mainの新規変更を取り込む前に再比較する。
- mainに追加された成長型敵の企画書 `docs/manjushage/GROWING_ENEMY_VISUAL_PROPOSAL.md` とSVGラフ `docs/manjushage/GROWING_ENEMY_VISUAL_ROUGH.svg` は提案段階の参考資料であり、承認済みゲーム素材ではない。統合時に保持し、透過PNGや実装済み素材と誤認しない。
- 原画承認・main固有UI画像2点・スクリーンショット5点・全参照・main統合後Godot動作検証は引き続き未完了。画像や既存参照は変更せず、mainへのマージは保留。

## 2026-11-16 18時台 JST 再監査
- GitHubでPR #50（READMEのみ）・PR #51（73ファイルの設定・art分類）を再取得。両PRはopen、未マージ、mergeable=true。#51のbaseは`cleanup/simple-repo-navigation-20261106`であり、mainに直接統合しない。静的mergeable判定は内容検証・Godot動作保証ではない。
- `main...cleanup/canon-and-art-folders-20261106`比較は98 ahead / 10 behind、73ファイル差分。分類先のPNGは7点（title logo 1、主人公3人のpilotとship各1）。これは新規デザイン7点の制作証拠ではなく、移行先パスに存在する画像数の確認に限る。
- main側のグロウフィア企画書とSVGラフを保護対象として維持。既存の承認済み原画と同一性を確認するまで画像の置換・削除はしない。
- 承認済み原画の同定、main固有UI PNG 2点、スクリーンショット5点の比較、Markdown/画像/コード参照の網羅検証、Godot 4.6実行、Windows表示比較は未完了。今回の変更は監査記録のみ。mainマージなし。**完了条件未達。**

## 2026-11-16 19時台 JST main新規背景ギミック資料の保護
- `main...cleanup/canon-and-art-folders-20261106` は diverged、99 ahead / 11 behind、73ファイル差分。mainの更新がさらに1コミット進んだため、旧差分をそのまま統合しない。
- mainに新規追加された `docs/manjushage/BACKGROUND_GIMMICKS_64_CONCEPTS.md`（8面×8の背景ギミック提案、Codex実装指示）は整理時の保持対象。これは**企画書であり、背景素材PNGや実装済みギミックではない**。敵・背景・ステージの正史資料と区別し、提案段階として分類する。
- 既知の未解決事項：承認済み原画の同定、main固有UI PNG 2点と同名スクリーンショット5点の照合、Markdown/画像/コード参照の網羅検証、Godot 4.6実行・Windows表示比較。既存画像の移動・上書き、mainへのマージは未実施。**完了条件未達。**

## 2026-11-16 20時台 JST 競合・参照監査の継続
- GitHubでPR #50・#51がopen・未マージを再確認。#50のbaseはmain、#51のbaseは#50の整理ブランチ。今回のmergeable判定は両方trueだが、動作保証ではない。
- `main...cleanup/canon-and-art-folders-20261106` は **100 ahead / 11 behind、73ファイル差分**。main先端は `f0e5f92a2bc5919532851a8e862af48334cd3e72`。前回記録から整理側1コミット増加。
- mainの背景ギミック64案・グロウフィアSVGラフ・企画書は移行対象に保持し、承認済み原画や透過PNGと誤認しない。
- 未解決：承認済み原画の同定、main固有UI PNG 2点・スクリーンショット5点の同一性確認、全リンク/コード/画像参照の網羅検証、Godot 4.6の実行・表示確認。安全性が未証明のため、既存画像は移動/削除/上書きせず、mainへのマージは保留。**完了条件未達。**


## 2026-11-16 21時台 JST main→整理ブランチ逆方向差分の具体的保護対象
- GitHubでPR #50・#51がopen、mergeable=trueを再確認。ただし#51は#50ブランチをbaseとしており、mainへの直接マージはしない。
- 比較 main→整理ブランチは **101 ahead / 11 behind、73ファイル**。逆方向（整理ブランチ→main）では、mainにしかない追加・変更ファイルを具体的に確認した。これらを移行時に**削除・上書きしてはいけない**。
- 新規の画像実体：`art/concept/eight_stage_retro_pixel_concepts_20261106.png`、`art/ui/character_hub_ui_20261106.png`、`art/ui/character_system_ui_20261106.png`、`art/ui/chat_ui_atlas_20261106.png`、`art/ui/launch_button_v01.png`、`art/ui/title_logo_extended_v01.png`、`art/v09/{cosmos.png,enemy-0.png,enemy-1.png,enemy-2.png,enemy-3.png,ship-atlas.png}`、`art/v09/originals/{bio-cosmos.png,enemies.png,ship-states.png}`。承認済みかどうかは未確定。原画を含む`art/v09/originals/`は特に保護する。
- main側に追加された資料：`art/v09/PROMPTS.md`、`art/v09/PROVENANCE.md`、`art/ui/README_CHAT_IMPORT.md`、`docs/manjushage/{BACKGROUND_GIMMICKS_64_CONCEPTS.md,CONTROL_ROOM_DIALOGUE_DIRECTION.md,GROWING_ENEMY_VISUAL_PROPOSAL.md,GROWING_ENEMY_VISUAL_ROUGH.svg}`。背景ギミックとグロウフィアは提案・ラフ段階として扱う。
- main側に追加されたコード・音声：`visual_v09.gd`、`tests/test_v09.gd`、`tests/test_status_v09.gd`、`audio/*v09*.wav`等。main側で`game.gd`、`biological_stage.gd`、`pilot_abilities.gd`、`vertical_passage.gd`、`mafio_archive.gd`、`tools/pack.gd`も変更されている。整理ブランチの旧実装で上書きしない。
- `docs/screenshots/latest/{boss,briefing,menu,status,vertical}.png` はmain側で変更済み。比較・保護前に移行しない。
- 今回はGitHub差分でパスの存在と変更種別を確認したのみ。バイナリ同一性、承認状態、全参照の整合性、Godot 4.6動作は未検証。**main統合・完了通知は保留。**

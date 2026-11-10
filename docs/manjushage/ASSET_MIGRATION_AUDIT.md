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

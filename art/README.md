# 画像素材の整理・差し替えガイド

**画像はキャラ・敵・背景ごとに保存**。新フォルダにPNGを置くと、既存13スロットすべてに整理先パスを定義済み。ただしPNGが実在しない場合は旧パス、さらにプログラム描画へフォールバックする。旧 `art/active/*.png` も残して互換性を維持。

## UI装飾

- `art/ui/logos/`：ロゴ（`title_logo.png` は新しい場所から自動読込、旧パスにも対応）
- `art/ui/buttons/`：「出撃」などのボタン画像（**ゲームへの画像接続は未実装**）
- `art/ui/decorations/`：ステータス画面・HUD・枠・カーソル（**画像接続は未実装**）

## 保存場所

| 対象 | PNGの保存先 | ゲーム表示 |
| --- | --- | --- |
| コルミィ機 | `art/characters/cormii/ship.png` | 対応 |
| ジヨーザ機 | `art/characters/jiyoza/ship.png` | 対応 |
| マフィオ機 | `art/characters/mafio/ship.png` | 対応 |
| 3人の立ち絵 | `art/characters/{cormii,jiyoza,mafio}/portrait.png` | **未接続**（原画保存用） |
| 3人の顔・表情 | `art/characters/{cormii,jiyoza,mafio}/face.png` | **未接続**（原画保存用） |
| 狙撃敵 | `art/enemies/lance/sprite.png` | 対応 |
| 扇状敵 | `art/enemies/bloom/sprite.png` | 対応 |
| 生体ボス | `art/enemies/boss/body.png` | 対応 |
| タイトル背景 | `art/backgrounds/title/backdrop.png` | 対応 |
| 1面の生体遠景 | `art/backgrounds/stage_01/backdrop.png` | 対応 |
| 2〜8面の背景 | `art/backgrounds/stage_02/`〜`stage_08/backdrop.png` | **未接続**（各面の実装待ち） |

**従来のまま使える：** 旧タイトルロゴ `art/active/title_logo.png`、4種のアイテム用旧パス `art/active/item_*.png`（実ファイルの有無は個別確認）。旧パスは削除しない。

## 差し替え方法

1. 対象フォルダに表のファイル名でPNGを置く。新しいパスが優先され、画像がなければ旧 `art/active/` を探す。
2. Godot 4.6で再インポートし、ゲームを停止してからF5で再起動する。起動中の自動更新ではない。
3. 画像の読み込みに失敗したら既存のプログラム描画へ戻る。敵・ボスの当たり判定は変わらない。
4. 原画の出典、承認状態、旧版と新版の違いは `docs/manjushage/ART_ASSETS.md` に記録する。

**現状：** 機体3点、パイロット案3点、タイトルロゴ1点は既存画像と同一blobのコピーを分類先へ保存済み（原本は保持）。ただし承認済み原画の同定・移行は**未完了**。機体3点のコピー名は `ship_cormii.png` 等で、標準差し替え名 `ship.png` とは異なる。`art_catalog.gd` は標準名を優先し、次にコピー名、最後に旧 `art/active/` を参照する。ロゴも `art/ui/logos/title_logo.png` → `art/backgrounds/title/title_logo.png` → 旧パスの順。パイロット案は自動表示されない。ゲームのコード接続は `art_catalog.gd` に実装したが、Godot 4.6によるリソースインポート・13スロット/フォールバックの自動検証は**2026-11-07に成功**（[GitHub Actions run 42347305770](https://github.com/coshimagame/manjusyage/actions/runs/42347305770)、コミット `36f170a4`）。ただし、実ゲームの起動・描画の目視比較は**未実施**。勝手に人物デザインを作り直さない。

## 見た目の退行防止（マージ前の必須確認）

- ユーザーからゲームの見た目が以前より悪くなったとの指摘あり。**新規素材を自動採用しない**。既存 `art/active/` のPNGと `art/concepts/` の参考画像を削除・上書きしない。
- 新フォルダのREADMEは素材そのものではない。採用済み原画の同一性が確認できるまで、別の機体・人物PNGを同名で配置しない。
- `tests/test_art_slots.gd` は整理先13件と読み込み可能性を検査するが、**見た目が承認済みデザインと一致することまでは保証しない**。Windows版のタイトル・出撃・3機・敵・背景・UIを実画面で旧版と比較してからマージする。
- Godotの自動テスト合格だけでは整理完了としない。目視比較未実施、原画移行未完了、`main`未反映の場合は**整理完了と記載しない**。

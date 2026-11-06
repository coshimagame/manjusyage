# 画像素材の整理・差し替えガイド

**画像はキャラ・敵・背景ごとに保存**。新フォルダにPNGを置くと、既存13スロットのうち対応するものは自動で読み込む。旧 `art/active/*.png` も残して互換性を維持。

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

**従来のまま：** タイトルロゴ `art/active/title_logo.png`、4種のアイテム `art/active/item_*.png`。無理に移動しない。

## 差し替え方法

1. 対象フォルダに表のファイル名でPNGを置く。新しいパスが優先され、画像がなければ旧 `art/active/` を探す。
2. Godot 4.6で再インポートし、ゲームを停止してからF5で再起動する。起動中の自動更新ではない。
3. 画像の読み込みに失敗したら既存のプログラム描画へ戻る。敵・ボスの当たり判定は変わらない。
4. 原画の出典、承認状態、旧版と新版の違いは `docs/manjushage/ART_ASSETS.md` に記録する。

**現状：** 子フォルダは案内READMEのみ。承認済み原画PNGの取り込みは**未完了**。ゲームのコード接続は `art_catalog.gd` に実装したが、Godot 4.6の起動・描画テストは**未実施**。勝手に人物デザインを作り直さない。

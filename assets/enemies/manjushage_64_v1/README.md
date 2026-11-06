# 曼珠沙華・64体の敵素材
2026-11-06。ユーザー指定の既存ZIPから取り込み。ゲーム内統合は未実施。

## 原本
- sprites/: 透過PNG 64点（136または137×76、RGBA）。
- source_crops/: 切り出し原画64点。
- original_concept_sheet.png: 一覧原画1536×1024。
- manifest.json / README_FOR_CODEX.md: ZIP同梱原本。
- ZIP SHA-256: 528283aac90103c4403ca20cd3a36568ecb5f4539e89101da7a1caf3a86390e4。
- 出典: ユーザーが指定したChatGPT会話「曼珠沙華 Steam発売優先開発」（6aecf2f3-9e2c-83ec-8ea4-eeeccc328ffa）。この環境ではDownloads内の同名ZIPを使用。同名複製5個は同一SHA-256。元ChatGPT環境の/mnt/dataの実体との直接照合はできていない。
- 原本131ファイルはバイト列を保持。ZIP自体はリポジトリへ登録しない。

## 実装入口
[Codex実装指示書](../../../docs/manjushage/CODEX_ENEMY_64_IMPLEMENTATION.md)を読む。
manifest.runtime.jsonは原本manifestのsource_imageだけを実在するoriginal_concept_sheet.pngへ修正した派生版。パスはこのフォルダー相対。原本の旧ファイル名は履歴として保持する。

## 検証と制約
ZIP CRC、PNG129点のチャンクCRC・展開長、64体の一意ID、各面8スロット、全sprite/source_crop参照が合格。
原本のGit blob SHA-1はGitHub保存時の応答と照合。checksums.git.jsonに一覧を保存。
一覧原画は目視確認済み。各切り出しの透過品質・実ゲーム表示・Godot実行は未検証。
方向別画像・アニメーションは含まれない。横/縦では同じ静止画を暫定利用する。黒抜け、文字混入、切れは個体ごとに検査する。
画像の4〜8面名称はSTAGES.mdと異なる。安定IDとstage番号を使い、既存の正史・承認済み素材を上書きしない。

## 抜き取り目視で確認した問題
S05E01に文字の混入、S08E08に文字の混入と絵の上下の切れが見られる。S01E01/S01E08を含む抜き取り画像では暗い背景の残留も見える。全64点の目視QAは未完了。原本は修正せず保存し、実装時に原画から別フォルダーへ再切り出し・透過調整する。これらを完成スプライトとして扱わない。

## 再検証
リポジトリ直下で `python tools/verify_enemy_64.py` を実行する。Python標準ライブラリのみ。今回ローカルで終了コード0・PASSを確認。Godotの実行検証とは別。

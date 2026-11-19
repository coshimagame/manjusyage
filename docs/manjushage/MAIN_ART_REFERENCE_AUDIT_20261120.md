# main素材参照の現状確認（2026-11-20）

この記録は完了報告ではない。既存画像・承認済み原画を削除・上書きしない。

## mainで直接確認した事実
- **更新（2026-11-20）**：PR #317 のmainへのマージ後、`art_catalog.gd` は13スロットの分類先パスを優先し、コピー画像と旧 `art/active/` へのフォールバックに対応。以前の「main未実装」は履歴として扱う。
- `art/README.md` の分類先優先探索の記述はPR #317で実装と整合した。ただし最新mainでのGodot実行検証は未確認。
- `art/backgrounds/title/title_logo.png` はmainで取得できず、分類先のPNG移行は未完了。
- PR #51 の整理ブランチの `art_catalog.gd` には `ORGANIZED_PATHS`、`COPIED_ORIGINAL_PATHS`、`PREVIOUS_ITEM_PATHS` が存在する。ただしPR全体には競合があり、無検証で一括マージしない。
- `docs/manjushage/CURRENT_SPEC.md` はmainに存在し、新旧差分の入口として使えるが、全資料の監査完了を意味しない。

## 次に必要な検証
- [ ] mainと整理ブランチの実画像をblob SHAで比較し、承認済み原画と既存UI画像を保護する
- [x] 分類先探索を独立した小PR #317で導入し、旧 `art/active/` へのフォールバックを維持する（コード統合のみ確認）
- [ ] Godot 4.6 headless importと13スロットの検証を最新mainで実行する
- [ ] 全Markdownリンク、実在PNG、コード参照を確認する
- [ ] Windows実画面で承認済みデザインとの退行比較を行う

**現状は未完了。** フォルダのREADMEは画像の納品を意味しない。

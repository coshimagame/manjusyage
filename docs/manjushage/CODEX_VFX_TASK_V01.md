# Codex実装指示 — 曼珠沙華 弾幕／アイテム／VFX ビジュアル 2026-11-17

## 指示の位置づけ
ユーザーは「案を一覧とラフで見たい」「GitHubに置き、Codexに読ませてから実際の素材とゲームのビジュアルを強化したい」と依頼。**このファイルを見たことはCodexの起動・実装開始を意味しない**。次にCodexが作業するときの正式な読込対象。仕様追加のため既存の正史・能力・顔を変更しない。

## 最初に読むファイル（必須）
1. `AGENTS.md`、`docs/manjushage/INDEX.md`、`docs/manjushage/CANON.md`、`docs/manjushage/CODEX_HANDOFF.md`、`docs/manjushage/NEXT_ACTION.md`
2. `docs/manjushage/HUD_UI_DIRECTION.md`、`docs/manjushage/PROVISIONAL_VISUAL_BIBLE_V01.md`
3. **`docs/manjushage/VFX_ASSET_DESIGN_PACK_V01.md`**（全48種＋12弾幕パターン）
4. **`docs/manjushage/visuals/vfx_bullets_v01.svg`**, **`vfx_items_v01.svg`**, **`vfx_effects_v01.svg`**（絵のラフ）
5. **`docs/manjushage/VFX_ASSET_MANIFEST_V01.csv`**（ID対応表）
6. 現行 `game.gd`、`pilot_abilities.gd` 等の関連スクリプト・アートを確認し、実装済／未実装を現物で照合。

## 実作業の優先パイプライン
1. 作業開始時 `git status` → fetch → 自分の作業ブランチのベース／未保存変更を保護。マージ済み仕様、既存PRと競合させない。
2. **1面だけの小さな縦切り**を行う。P0のB01/B02/B05/B10＋I01/I02＋V01/V02/V15から着手。既存の弾数・衝突判定・拾得ロジックは原則維持。現行コードに適合するものを優先し、不要な敵追加はしない。
3. **静止画の制作で終えない**。透明RGBA個別PNGを制作し、アニメ必要部品のコマPNG・スプライトシート・座標JSONとCSVを出す。すべて置換可能なパスでGodotに接続。
4. プロジェクト内の画像フィルタはnearest、整数拡大で表示。敵弾と無害粒子は衝突レイヤーも描画レイヤーも別。VFXは有限寿命でプールする。
5. 実ゲームの実行が可能ならGodot 4.6で起動し、1人・3人・横・縦・ボス・アイテム取得の実スクリーンショットと合否ログ。実行不可なら**未実施**と明記。
6. リグレッション：敵弾命中、アイテム2種の回復値、被弾、救出、固有能力、セーブ、オーディオ、画面演出量OFFを検証。誤動作したら変更を隔離。
7. 実際に動いた成果と残課題を `HANDOFF.md`、`docs/CHANGELOG.md`、`ART_ASSETS.md` に追記。次の作業は `NEXT_ACTION.md` に書き、PRにスクショと検証結果を付ける。

## 1回のCodexセッションの成功条件（最小）
- 2種アイテムの視覚品質が改善、PNG実在、拾得ロジック維持を確認。
- 敵弾のうち少なくとも1種が実ゲームに表示され、危険部と花弁VFXが別表示される。
- 640×360の道中画面でbefore/afterと1〜3人の判別を比較。
- 機能実装／素材生成／自動テスト／手動検証の区分を明記したコミットまたはPRを残す。

## Codexに今すぐ送る一文
`mainのAGENTS.mdを読み、docs/manjushage/CODEX_VFX_TASK_V01.md と VFX_ASSET_DESIGN_PACK_V01.md、visuals/vfx_*_v01.svg、VFX_ASSET_MANIFEST_V01.csvを読み込んで。現行game.gdと既存素材を監査し、P0を透明PNG制作→ゲーム実装→Godot検証まで進め、実画面・ログ・コミットを提示。人物の顔や既存能力は変更しないで。`

## これを実現するための注意
本指示書のGitHub保存だけでPC上のCodexが自律的に読み始めるわけではない。次回起動時に通常のAGENTS.md読込と上の参照文で受領する。定期的な別開発タスクはこの作業の完了を保証しない。

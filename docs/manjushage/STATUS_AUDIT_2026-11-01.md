# 曼珠沙華 / Mw-fActory — 実装状況と修正監査

監査日：2026-11-01（JST）
対象：GitHub main、現在のGodot 4.6試作。ここにある「コード反映済」は動作検証の完了を意味しない。

## 要約
- **現実に遊べる範囲**：第1面「赤い残響」の通常・生体ルート試作、1〜3人協力、横縦切替、パズル、仮ボス、試作BGMとプロローグ。
- **ゲーム内にコードあり**：コルミィ運気％・おみくじ再抽選・溜め攻撃減衰、ジヨーザの解析結晶・専用ゲージ・初見/ボス無効の特殊解析、マフィオの捕食能力一時装備・敵ごとの消化秒数・食べた敵記録。
- **今回接続した機能**：1面クリア後の準備室、1面再出撃、キャラ入替、2面以降を制作中として出撃禁止、4/5/6面でムゥの発明した専用図鑑や日記が見られる条件。
- **グラフィック**：ユーザー仮決定の細身の3機PNGを art/active/ship_cormii.png、ship_jiyoza.png、ship_mafio.png に実登録。人物の仮決定された参考ビジュアルのゲーム用最終スプライト化はまだ。
- **未完成**：第2〜8面のプレイアブル化、ステージ別ボスと物語、世界線4周、5難易度、ムゥの武器開発、ボス武器継承、マフィオの多種敵能力、食感レポート、図鑑・日記の本格閲覧、Steam版・オンライン協力。

## 監査で見つけて修正した具体的問題
| 問題 | 修正した箇所 | 結果・制限 |
|---|---|---|
| テストが旧コルミィの時間周期火力・旧マフィオの永続コピーを期待 | tests/test_setting_updates.gd | 運気再抽選・捕食直後装備・消化後復帰を基準に修正。まだ実行前 |
| プロローグは8ページなのにテストは6ページを想定 | tests/test_prologue.gd | 8ページと遷移で判定するように修正 |
| プロジェクト名とルートノード名が旧 STARLINK SQUAD | project.godot、main.tscn | 公式名の曼珠沙華 / MANJUSHAGEへ変更（GitHubリポジトリ名自体は維持） |
| 生体ルートのリザルトが旧ルート ruins-v1 と誤記録 | game.gd、tests/test_save.gd | プレイしたルートで保存値を切り替える。既存セーブ値の変更はしない |
| ブリーフィング進行ファイルがゲームから参照されていなかった | game.gd、briefing_progress.gd | 1面クリア→2面準備室、キャラ入替、1面再出撃。未実装の2面では出撃不可 |
| 図鑑・日記が本来の解放面より前に見えてしまった | game.gd | 4面マフィオ、5面ジヨーザ、6面コルミィで閲覧解放 |
| 承認した細身機体のPNGがリポジトリになかった | art/active/*.png | 3機の32×20個別スプライトをGitHubへ登録。実機インポートは未確認 |
| クリア時に必要な ending.wav が存在しない／切替曲 wistful_demo.wav も未配置 | game.gd、tests/test_music_story.gd、tests/test_setting_updates.gd | 無い曲を直接loadせず、存在する既存曲へ自動フォールバック。**オリジナルの本採用エンディング曲自体はまだ未完成** |
| title.wav は約24秒（現行生成スクリプトの16小節設定）なのにテストは50秒以上を要求 | tests/test_music_story.gd | 実在曲の長さに合う閾値へ変更 |
| プロローグの静止惑星を毎フレーム約2万回の矩形描画で再計算 | prologue.gd | 起動時1回だけ163×163のImageTextureへキャッシュ。絵柄はほぼ維持（描画実機未検証） |
| 未使用の運試し日記モデルが旧stability段階を記録 | pilot_journals.gd | 将来の実装に合わせてluck百分率のフィールドへ修正 |
| ブリーフィングに入ると元のキャラ選択が初期値へ戻る | game.gd | 直前の出撃編成を引き継ぎ、重複時は補正。マウス選択も対応 |
| ステージ名の暫定モデルが設定候補と整合しない | briefing_progress.gd | 公式台帳C-018記載の暫定8面名と合わせた。ユーザーが正式採用した名前ではない |

## 現在の動作検証状態
1. GitHubファイルの存在・修正コミット・静的なソース整合は確認した。
2. **このチャットの実行環境にGodot 4.6の実行ファイルがない**。そのため今回修正後のGDScriptパース／UI実画面／全自動テスト／ゲームパッド／音声聴感は**すべて未検証**。以前の古い0.6〜0.7テストPASSを最新版に流用してはならない。
3. 追加または更新したテスト：tests/test_prologue.gd、test_save.gd、test_setting_updates.gd、test_music_story.gd、test_cormii_fortune.gd、test_briefing_progress.gd、test_briefing_game_flow.gd、test_jiyoza_analysis.gd。既存の生体／アートスロット等も要再試験。
4. 音源フォルダーには title.wav、ruins.wav、sentinel.wav と6つの効果音が存在する。ending.wav と wistful_demo.wav は未配置。新しく立てたフォールバックはコード上の安全策で、曲の完成ではない。

## Codexの次回作業・検収チェック（最優先）
Godot 4.6 Standard、最新版 main、汚れていない作業ディレクトリ、テスト専用 user:// プロファイルを使う。保存データの実利用先でテストをしない。
```text
godot --headless --editor --path . --import --quit
godot --headless --path . --script tests/test_art_slots.gd
godot --headless --path . --script tests/test_prologue.gd
godot --headless --path . --script tests/test_setting_updates.gd
godot --headless --path . --script tests/test_cormii_fortune.gd
godot --headless --path . --script tests/test_briefing_progress.gd
godot --headless --path . --script tests/test_briefing_game_flow.gd
godot --headless --path . --script tests/test_jiyoza_analysis.gd
godot --headless --path . --script tests/test_save.gd
godot --headless --path . --script tests/test_music_story.gd
godot --headless --path . --script tests/test_biological_stage.gd
godot --headless --path . --fixed-fps 60 -- --autotest --players=1
godot --headless --path . --fixed-fps 60 -- --autotest --players=2
godot --headless --path . --fixed-fps 60 -- --autotest --players=3
```
確認ポイント：全スクリプトのパース／音源フォールバック、タイトルからの初回出撃、1面クリア→準備室、2面出撃阻止、1面のリプレイ、3人入替、4/5/6面の図鑑解放、コルミィの和風おみくじを避ける選択、ジヨーザ初出現／ボス免疫、マフィオ消化中だけ武器変化、縦横で3機のPNGが細身に見えるか。
テストが失敗したらこの監査の「修正済」を「動作確認済」と読み替えず、必ずエラー・スクリーンショット・修正コミットを記録。

## 実装判断のルール
ユーザー確定事項とAIの試作値はCANON.mdの状態を守って区別する。良い案は仮実装してよいが、ひとつの実装によってユーザーの確定したキャラデザイン・世界線設定・能力仕様を巻き戻さない。

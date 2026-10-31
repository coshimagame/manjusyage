# 開発・検証

Godot 4.6 Standardを使用。Pythonは音声再生成のときだけ必要で、標準ライブラリのみ。
以下の `godot` は自分のGodot実行ファイルへ読み替える。作業ディレクトリはリポジトリ直下。

```text
godot --headless --editor --path . --import --quit
godot --path .
```

音声生成（この順序）：

```text
python tools/make_audio.py
python tools/make_music.py
godot --headless --editor --path . --import --quit
```

PCK生成（Godotでインポートした後）：

```text
godot --headless --path . --script tools/pack.gd
godot --main-pack STARLINK-SQUAD.pck
```

正式なSteam配布向けエクスポートは未整備。PCK＋エディターバイナリを使う現在の配布は試作向け。

## 自動検証

Windowsではテスト専用のAPPDATAを先に設定し、実プレイの記録を上書きしない。
PowerShell例（このシェル内だけの環境設定）：

```powershell
New-Item -ItemType Directory -Force userdata/test-profile | Out-Null
$env:APPDATA = (Resolve-Path userdata/test-profile).Path
```

```text
godot --headless --path . --fixed-fps 60 -- --autotest --players=1
godot --headless --path . --fixed-fps 60 -- --autotest --players=2
godot --headless --path . --fixed-fps 60 -- --autotest --players=3
godot --headless --path . --script tests/test_save.gd
```

終了コード0とPASS出力を確認し、SCRIPT ERRORも確認する。
自動攻略には無敵と自動操作があり、難易度・操作感を評価するものではない。

入力・音声の診断は、認識済みコントローラー1台と音声出力のある環境で実行：

```text
godot --path . --script tests/test_input_audio.gd
```

これはそのゲームプロセス内へ合成イベントを注入する検査。実際のボタン操作は別途試す必要がある。
検査ではパッド設定ファイルを書き換えるため、テスト専用APPDATAでのみ実行する。
音声検査は再生位置と音声バスの信号を確認するもので、人が音を聞けた証明ではない。

## 実プレイで確認する項目

- タイトルで曲が聞こえるか。F6、F7の出力変更、Mが機能するか。
- 十字キーで人数が変わり、出撃後に上下左右・斜めへ動けるか。
- F2で8操作を登録後、タイトルとゲーム中で反映され、再起動後も保存されるか。
- 1〜3台の混在、途中切断と再接続、救出、全滅とリトライ。
- ソロで両方のパズルが理解できるか。ショット／弾幕が見やすいか。

Godotのキャッシュ・生成PCKは.gitignoreで除外。WAV原本と生成スクリプトは管理対象。

## 2026-11-01 追加の必須回帰テスト
リポジトリ最新版ではGodot 4.6での実行がまだ未検証。以下はテスト**実行指示**であり、PASS報告ではない。必ず本来のセーブとは別のGodot user:// プロファイルを使う。
```text
godot --headless --path . --script tests/test_art_slots.gd
godot --headless --path . --script tests/test_prologue.gd
godot --headless --path . --script tests/test_cormii_fortune.gd
godot --headless --path . --script tests/test_setting_updates.gd
godot --headless --path . --script tests/test_briefing_progress.gd
godot --headless --path . --script tests/test_briefing_game_flow.gd
godot --headless --path . --script tests/test_jiyoza_analysis.gd
godot --headless --path . --script tests/test_save.gd
godot --headless --path . --script tests/test_music_story.gd
godot --headless --path . --script tests/test_biological_stage.gd
```
Godot 4.6のプロジェクトインポート→すべてのSCRIPT ERRORゼロ→1/2/3人自動走行→実機音・ゲームパッド・縦横スリム機体の見た目を検証。現行audioにはending.wavとwistful_demo.wavがないため、既存曲への安全フォールバックが正しく動くことも確認。詳細 docs/manjushage/STATUS_AUDIT_2026-11-01.md。

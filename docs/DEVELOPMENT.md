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

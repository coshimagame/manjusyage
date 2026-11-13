# Mw-fActory サウンド制作チーム → Codex 連携申し送り書 (v0.1)

発行：**Mw-fActory サウンド制作担当（Antigravity）**  
宛先：**Codex（ゲーム本体実装担当）**  
日付：2026-11-13  
ブランチ：`feature/audio-production-01`  

---

## 1. 原則と安全保障の確認

- **ゲーム本体非干渉の厳守**：`game.gd`、`project.godot`、`scripts/` 内のスクリプト、既存のシーン、既存の `audio/` 内素材は一切改変・上書きしていません。Codexの実装作業との競合は発生しません。
- **配置場所**：新規素材はすべて独立した `assets/audio/`、`tools/audio/`、`docs/manjushage/audio/` 配下に格納されています。

---

## 2. 納品音源素材とGodot 4.6 組み込み仕様

### A. BGM素材 (シームレスループ)

| 素材ID | ファイルパス | 再生シーン / 条件 | Godot Import設定 | 推奨バス / 音量 |
|---|---|---|---|---|
| `AUD-013` | `assets/audio/music/bgm_stage01_plan_a.wav` | 第1面「赤い残響」道中 (A案) | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.0 dB |
| `AUD-014` | `assets/audio/music/bgm_stage01_plan_b.wav` | 第1面「赤い残響」道中 (B案) | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.5 dB |
| `AUD-015` | `assets/audio/music/bgm_boss01_plan_a.wav` | 第1面ボス戦 (A案) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |
| `AUD-016` | `assets/audio/music/bgm_boss01_plan_b.wav` | 第1面ボス戦 (B案) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |

**フェード推奨仕様**：
- 道中からボス戦への移行：道中BGMを 1.2秒 でフェードアウト後、ボスBGMを 0.3秒 でフェードイン。
- A案・B案の比較テスト：デバッグキー（例：F6等）でA案/B案をクロスフェード（1.0秒）切り替え可能にすることを推奨。

---

### B. ジングル素材 (ワンショット)

| 素材ID | ファイルパス | 再生イベント | Godot Import設定 | 推奨バス / 音量 |
|---|---|---|---|---|
| `AUD-017` | `assets/audio/jingles/jg002_sortie.wav` | 出撃決定 / ステージ開始演出 | `loop=false` | `Music` or `Jingle`<br>-2.0 dB |

- **演出連携**：本ジングル再生中は道中BGMの再生を待機し、ジングル終了（または発進スプライトの加速タイミング・約2.8秒地点）から道中BGMを再生開始すると最高の盛り上がりが得られます。

---

### C. 効果音素材 (SFX)

| 素材ID | ファイルパス | トリガーイベント | 同時発音制御 | 推奨バス / 音量 |
|---|---|---|---|---|
| `AUD-018` | `assets/audio/sfx/se_shot_cormii.wav` | 1P コルミィ通常弾発射 | ポリフォニック (最大4音) | `SFX` / -2.0 dB |
| `AUD-019` | `assets/audio/sfx/se_shot_jiyoza.wav` | 2P ジヨーザ通常弾発射 | ポリフォニック (最大4音) | `SFX` / -3.0 dB |
| `AUD-020` | `assets/audio/sfx/se_shot_mafio.wav` | 3P マフィオ通常弾発射 | ポリフォニック (最大4音) | `SFX` / -2.5 dB |
| `AUD-021` | `assets/audio/sfx/se_boss_warning.wav` | ボス大技予兆・形態移行前 | 最優先（他SEの音量を3dBダッキング推奨） | `SFX` / -1.5 dB |
| `AUD-022` | `assets/audio/sfx/se_boss_destroy.wav` | ボスHPゼロ・撃破時 | 最優先（BGM停止・フェードアウト） | `SFX` / 0.0 dB |

---

## 3. 動作確認・テスト手順

1. **整合性テスト**：
   ```bash
   python tests/test_audio_batch01.py
   ```
2. **Godot 4.6 エディタでのインポート確認**：
   - Godot 4.6でプロジェクトを開くと、`assets/audio/` 配下のWAVが自動インポートされます。
   - `bgm_*.wav` のインポート設定で `Loop: Enabled`、`Loop Offset: 0` であることを確認してください。
3. **ユーザー試聴**：
   - ユーザーの好みに応じてA案・B案のいずれかを本採用とするか、あるいは周回差分（例：1周目A案、2周目B案）として採用するかを協議します。

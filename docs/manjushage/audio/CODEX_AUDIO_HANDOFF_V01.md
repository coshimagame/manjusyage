# Mw-fActory サウンド制作チーム → Codex 連携指示書・正式採用通知書 (v1.0)

発行：**Mw-fActory サウンド制作責任者（Antigravity）**  
宛先：**Codex（ゲーム本体実装責任者）**  
日付：2026-11-16  
ブランチ：`feature/audio-production-01`  
ステータス：**【ユーザー承認済み・正式採用指示】(APPROVED & ADOPTED)**

---

## 1. 採用指示の概要

ユーザーによる試聴および方針合意に基づき、以下の音響アセット群（全32素材）を『曼珠沙華（MANJUSHAGE）』本体への**正式採用アセット**として指定します。

Codexにおかれましては、本指示書の仕様に従い、Godot 4.6の各シーン（タイトル、自機選択、出撃演出、ステージ1〜3、ボス戦、クリアリザルト、UI、効果音処理）へ順次組み込み・結線をお願いいたします。

---

## 2. 正式採用アセット一覧とGodot 4.6 組み込み仕様

### A. オープニング・BGM素材 (シームレスループ)

| 素材ID | ファイルパス | 場面 / 採用先 | Godot設定 | バス / 推奨音量 |
|---|---|---|---|---|
| `AUD-001` | `assets/audio/music/bgm_opening_plan_a.wav` | **タイトル画面 / オープニング (本採用 A案)**<br>「曼珠沙華 〜 記憶の深淵」 | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |
| `AUD-002` | `assets/audio/music/bgm_opening_plan_b.wav` | タイトル画面 (B案 / 2周目以降変奏用)<br>「曼珠沙華 〜 輪廻のプロローグ」 | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |
| `AUD-013` | `assets/audio/music/bgm_stage01_plan_a.wav` | **第1面「赤い残響」道中 (本採用 A案)** | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.0 dB |
| `AUD-014` | `assets/audio/music/bgm_stage01_plan_b.wav` | 第1面「赤い残響」道中 (B案 / 2周目変奏) | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.5 dB |
| `AUD-015` | `assets/audio/music/bgm_boss01_plan_a.wav` | **第1面ボス戦 (本採用 A案)** | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.0 dB |
| `AUD-016` | `assets/audio/music/bgm_boss01_plan_b.wav` | 第1面ボス戦 (B案 / 高難度・2周目変奏) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.0 dB |
| `AUD-023` | `assets/audio/music/bgm_stage02_plan_a.wav` | **第2面「追憶の海」道中 (本採用 A案)**<br>6/8拍子 潮騒ワルツ (ビブラフォン＆Rhodes) | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.0 dB |
| `AUD-024` | `assets/audio/music/bgm_stage02_plan_b.wav` | 第2面「追憶の海」道中 (B案 / 水中グルーヴ) | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.0 dB |
| `AUD-025` | `assets/audio/music/bgm_stage03_plan_a.wav` | **第3面「孤独な庭」道中 (本採用 A案)**<br>3/4拍子 からくりオルゴール＆ギター | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.0 dB |
| `AUD-026` | `assets/audio/music/bgm_stage03_plan_b.wav` | 第3面「孤独な庭」道中 (B案 / 廃墟チェロレクイエム) | `loop=true`<br>`loop_offset=0` | `Music`<br>-4.0 dB |

**フェード・遷移制御**：
- タイトルから出撃決定時：タイトルBGMを 0.8秒 でフェードアウト。
- 道中からボス戦への移行：道中BGMを 1.0秒 でフェードアウト後、ボスBGMを 0.2秒 でフェードイン。
- ステージクリア時：ボスBGM即時停止、`jg007_stage_clear.wav` を再生。

---

### B. ジングル素材 (ワンショット)

| 素材ID | ファイルパス | 再生イベント / トリガー | Godot設定 | バス / 推奨音量 |
|---|---|---|---|---|
| `AUD-010` | `assets/audio/jingles/jg001_title.wav` | タイトルロゴ表示 / 曼珠沙華開花演出 | `loop=false` | `Jingle` / -2.0 dB |
| `AUD-017` | `assets/audio/jingles/jg002_sortie.wav` | 自機選択後の出撃決定音 | `loop=false` | `Jingle` / -2.0 dB |
| `AUD-011` | `assets/audio/jingles/jg003_stage_start.wav` | **ステージ開始・発艦ブースト演出** | `loop=false` | `Jingle` / -1.5 dB |
| `AUD-012` | `assets/audio/jingles/jg007_stage_clear.wav` | **ステージクリア / ボス撃破リザルト** | `loop=false` | `Jingle` / -1.5 dB |

---

### C. プレイヤー3機 固有効果音 (SFX)

| 素材ID | ファイルパス | 対象機体 / 能力 | トリガー条件 | 発音制御 | バス / 音量 |
|---|---|---|---|---|---|
| `AUD-018` | `assets/audio/sfx/se_shot_cormii.wav` | コルミィ | 通常弾ショット発射 | ポリフォニック (最大6音) | `SFX` / -2.0 dB |
| `AUD-031` | `assets/audio/sfx/se_cormii_charge.wav` | コルミィ | 最大出力・チャージ完了 | 単音（最優先） | `SFX` / -1.5 dB |
| `AUD-032` | `assets/audio/sfx/se_cormii_omikuji.wav` | コルミィ | 開運おみくじ・アイテム発動 | 単音 | `SFX` / -2.0 dB |
| `AUD-019` | `assets/audio/sfx/se_shot_jiyoza.wav` | ジヨーザ | 通常弾レーザー発射 | ポリフォニック (最大6音) | `SFX` / -2.5 dB |
| `AUD-033` | `assets/audio/sfx/se_jiyoza_analyze.wav` | ジヨーザ | 敵解析完了 / 弱点看破 | 単音 | `SFX` / -2.0 dB |
| `AUD-034` | `assets/audio/sfx/se_jiyoza_barrier.wav` | ジヨーザ | 解析バリア展開 / 防御発動 | 単音 | `SFX` / -2.0 dB |
| `AUD-020` | `assets/audio/sfx/se_shot_mafio.wav` | マフィオ | 通常弾バイオキャノン発射 | ポリフォニック (最大6音) | `SFX` / -2.5 dB |
| `AUD-035` | `assets/audio/sfx/se_mafio_predation.wav` | マフィオ | 敵捕食・噛み砕き | 単音 | `SFX` / -1.5 dB |
| `AUD-036` | `assets/audio/sfx/se_mafio_absorb.wav` | マフィオ | 能力獲得・一時武装装着 | 単音 | `SFX` / -1.5 dB |

---

### D. 基本戦闘・システム効果音 (SFX)

| 素材ID | ファイルパス | イベント | トリガー条件 | バス / 音量 |
|---|---|---|---|---|
| `AUD-037` | `assets/audio/sfx/se_player_hit.wav` | 自機被弾 | シールド減少・被弾時無敵開始 | `SFX` / -1.5 dB |
| `AUD-038` | `assets/audio/sfx/se_enemy_shot.wav` | 敵弾発射 | 小型・中型敵の発射時 | `SFX` / -4.5 dB |
| `AUD-039` | `assets/audio/sfx/se_enemy_destroy_small.wav` | 雑魚撃破 | 小型敵のHPゼロ時 | `SFX` / -2.5 dB |
| `AUD-021` | `assets/audio/sfx/se_boss_warning.wav` | ボス予兆 | 大技攻撃前・形態変化前 | `SFX` / -1.0 dB |
| `AUD-022` | `assets/audio/sfx/se_boss_destroy.wav` | ボス撃破 | ボスHPゼロ・大爆発 | `SFX` / 0.0 dB |
| `AUD-040` | `assets/audio/sfx/se_item_get.wav` | アイテム取得 | Pアイテム・回復取得時 | `SFX` / -2.5 dB |
| `AUD-041` | `assets/audio/sfx/se_menu_cursor.wav` | UIカーソル | メニュー移動時 | `UI` / -4.0 dB |
| `AUD-042` | `assets/audio/sfx/se_menu_select.wav` | UI決定 | メニュー決定時 | `UI` / -3.0 dB |
| `AUD-043` | `assets/audio/sfx/se_menu_cancel.wav` | UI取消 | キャンセル・戻る時 | `UI` / -3.5 dB |

---

## 3. 動作確認および品質保証

- **規格厳守**：全ファイルは 44.1kHz, 16-bit, ステレオPCM WAV 形式。
- **クリッピング皆無**：最大ピーク -1.0 dBFS (0.891) 以下を厳守。
- **DCオフセット除去済み**：全ファイルでDCオフセット補正済み。
- **テスト自動検証**：
  ```bash
  python tests/test_audio_batch01.py
  ```
  上記を実行することで、全32ファイルが100%パスすることを確認済みです。

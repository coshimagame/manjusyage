# Mw-fActory サウンド制作チーム → Codex 連携指示書・正式採用通知書 (v1.1)

発行：**Mw-fActory サウンド制作責任者（Antigravity）**  
宛先：**Codex（ゲーム本体実装責任者）**  
日付：2026-11-20  
ブランチ：`feature/audio-production-01`  
ステータス：**【ユーザー承認済み・正式採用指示】(APPROVED & ADOPTED)**

---

## 1. 採用指示の概要

ユーザーによる試聴および方針合意に基づき、以下の音響アセット群（**全49素材：BGM 14曲、ジングル 8種、効果音 27種**）を『曼珠沙華（MANJUSHAGE）』本体への**正式採用アセット**として指定します。

Ableton Liveでの制作環境に対応したMIDIデータ（`assets/audio/midi/`、`assets/audio/ableton/`）も完全納品済みです。

---

## 2. 正式採用アセット一覧とGodot 4.6 組み込み仕様

### A. BGM素材 (シームレスループ - 全14曲)

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
| `AUD-027` | `assets/audio/music/bgm_stage04_plan_a.wav` | **第4面「分岐する空」道中 (本採用 A案)**<br>165 BPM 碧落の疾走 (超高速雲海フライト) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |
| `AUD-028` | `assets/audio/music/bgm_stage04_plan_b.wav` | 第4面「分岐する空」道中 (B案 / 乱気流のロンド) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |
| `AUD-029` | `assets/audio/music/bgm_stage05_plan_a.wav` | **第5面「忘却の要塞」道中 (本採用 A案)**<br>148 BPM 鋼鉄の残影 (重厚インダストリアルFM) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |
| `AUD-030` | `assets/audio/music/bgm_stage05_plan_b.wav` | 第5面「忘却の要塞」道中 (B案 / 機械仕掛けの記憶) | `loop=true`<br>`loop_offset=0` | `Music`<br>-3.5 dB |

---

### B. ジングル素材 (ワンショット - 全8種)

| 素材ID | ファイルパス | 再生イベント / トリガー | Godot設定 | バス / 推奨音量 |
|---|---|---|---|---|
| `AUD-010` | `assets/audio/jingles/jg001_title.wav` | タイトルロゴ表示 / 曼珠沙華開花演出 | `loop=false` | `Jingle` / -2.0 dB |
| `AUD-017` | `assets/audio/jingles/jg002_sortie.wav` | 自機選択後の出撃決定音 | `loop=false` | `Jingle` / -2.0 dB |
| `AUD-011` | `assets/audio/jingles/jg003_stage_start.wav` | **ステージ開始・発艦ブースト演出** | `loop=false` | `Jingle` / -1.5 dB |
| `AUD-044` | `assets/audio/jingles/jg004_miniboss.wav` | **小ボス・中ボス急接近出現アラート** | `loop=false` | `Jingle` / -1.5 dB |
| `AUD-045` | `assets/audio/jingles/jg006_boss_warning.wav` | **大ボス出現警告（警報サイレン＆金管）** | `loop=false` | `Jingle` / -1.0 dB |
| `AUD-012` | `assets/audio/jingles/jg007_stage_clear.wav` | **ステージクリア / ボス撃破リザルト** | `loop=false` | `Jingle` / -1.5 dB |
| `AUD-046` | `assets/audio/jingles/jg011_weapon_unlocked.wav` | **新武器完成 / パワー全開演出** | `loop=false` | `Jingle` / -1.5 dB |
| `AUD-047` | `assets/audio/jingles/jg012_worldline_shift.wav` | **世界線移動 / 時空ワープ突入演出** | `loop=false` | `Jingle` / -1.5 dB |

---

### C. 効果音素材 (SFX - 全27種)

#### 1. レーザー武装 (3種)
- `AUD-048` `se_laser_pierce.wav`：貫通ハイパービームレーザー（`SFX` / -2.0 dB）
- `AUD-049` `se_laser_enemy_sweep.wav`：敵極太薙ぎ払いレーザー（`SFX` / -1.0 dB）
- `AUD-050` `se_laser_homing.wav`：追尾ホーミングレーザー（`SFX` / -2.5 dB）

#### 2. パワーアップ＆拡散ショット (3種)
- `AUD-051` `se_shot_cormii_wide.wav`：コルミィ 5WAY拡散ショット（`SFX` / -2.0 dB）
- `AUD-052` `se_shot_jiyoza_beam.wav`：ジヨーザ 集束貫通フォトンレーザー（`SFX` / -2.5 dB）
- `AUD-053` `se_shot_mafio_wave.wav`：マフィオ 波動生体キャノン（`SFX` / -2.0 dB）

#### 3. 爽快撃破・破壊音 (3種)
- `AUD-054` `se_destroy_medium.wav`：中型敵撃破重爆発（`SFX` / -1.5 dB）
- `AUD-055` `se_destroy_heavy_chain.wav`：大型敵連続誘爆（`SFX` / -1.0 dB）
- `AUD-056` `se_armor_break.wav`：装甲破壊・シールドブレイク（`SFX` / -1.5 dB）

#### 4. プレイヤー3機 固有SE (9種)
- `AUD-018` `se_shot_cormii.wav`：コルミィ通常弾
- `AUD-031` `se_cormii_charge.wav`：コルミィ最大出力チャージ完了
- `AUD-032` `se_cormii_omikuji.wav`：コルミィ開運おみくじ
- `AUD-019` `se_shot_jiyoza.wav`：ジヨーザ通常弾
- `AUD-033` `se_jiyoza_analyze.wav`：ジヨーザ解析完了
- `AUD-034` `se_jiyoza_barrier.wav`：ジヨーザ解析バリア
- `AUD-020` `se_shot_mafio.wav`：マフィオ通常弾
- `AUD-035` `se_mafio_predation.wav`：マフィオ捕食
- `AUD-036` `se_mafio_absorb.wav`：マフィオ能力獲得

#### 5. 基本戦闘・システムSE (9種)
- `AUD-037` `se_player_hit.wav`：自機被弾
- `AUD-038` `se_enemy_shot.wav`：敵弾発射
- `AUD-039` `se_enemy_destroy_small.wav`：小型敵撃破
- `AUD-021` `se_boss_warning.wav`：ボス攻撃予兆
- `AUD-022` `se_boss_destroy.wav`：ボス撃破大爆発
- `AUD-040` `se_item_get.wav`：アイテム取得
- `AUD-041` `se_menu_cursor.wav`：メニュー移動
- `AUD-042` `se_menu_select.wav`：メニュー決定
- `AUD-043` `se_menu_cancel.wav`：メニュー取消

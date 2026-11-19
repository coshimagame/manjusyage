# 『曼珠沙華（MANJUSHAGE）』公式音響素材台帳 (v1.2)

制作：**Mw-fActory 音楽制作チーム**（Antigravity サウンド制作責任者）  
版数：v1.2（2026-11-20）  
状態：**【ユーザー承認済み・正式採用】(APPROVED & ADOPTED)**  
原本生成コード：
- `tools/audio/generate_opening_bgm.py`（オープニング・タイトル曲）
- `tools/audio/generate_audio_assets.py`（第1面道中・ボス1）
- `tools/audio/generate_stage_variations.py`（第2面海・第3面廃墟 多彩音色エンジン）
- `tools/audio/generate_stages4_and_5.py`（第4面空・第5面要塞 高速爽快エンジン）
- `tools/audio/generate_expanded_sfx_and_jingles.py`（初期ジングル・機体固有SE）
- `tools/audio/generate_thrilling_sfx_and_jingles.py`（レーザー・大爆発・装甲破壊・ボス警報）
- `tools/audio/export_all_to_midi.py`（全14曲 MIDI & Ableton Live Clips 出力）  
品質検査：`tests/test_audio_batch01.py`（**全49素材 合格 100% PASS**）  

---

## 1. 音楽素材一覧 (BGM - 全14曲 / MIDI原本完備)

| 素材ID | WAVファイル | MIDI原本ファイル | 曲名 / 場面 | 調性 / BPM | 尺 | 採用ステータス |
|---|---|---|---|---|---|---|
| **AUD-001** | `assets/audio/music/bgm_opening_plan_a.wav` | `assets/audio/midi/bgm_opening_plan_a.mid` | **曼珠沙華 〜 記憶の深淵**<br>(タイトル / オープニング A案) | D短調<br>82 BPM | 43.98s | **【本採用】タイトルBGM** |
| **AUD-002** | `assets/audio/music/bgm_opening_plan_b.wav` | `assets/audio/midi/bgm_opening_plan_b.mid` | 曼珠沙華 〜 輪廻のプロローグ<br>(タイトル / オープニング B案) | A短調<br>96 BPM | 37.50s | **【採用】2周目以降変奏** |
| **AUD-013** | `assets/audio/music/bgm_stage01_plan_a.wav` | `assets/audio/midi/bgm_stage01_plan_a.mid` | **赤い残響 〜 幽玄の飛翔**<br>(第1面道中 A案) | D短調<br>156 BPM | 49.23s | **【本採用】1面道中BGM** |
| **AUD-014** | `assets/audio/music/bgm_stage01_plan_b.wav` | `assets/audio/midi/bgm_stage01_plan_b.mid` | 赤い残響 〜 緋色の鼓動<br>(第1面道中 B案) | F#短調<br>162 BPM | 51.20s | **【採用】2周目変奏** |
| **AUD-015** | `assets/audio/music/bgm_boss01_plan_a.wav` | `assets/audio/midi/bgm_boss01_plan_a.mid` | **生体中枢 〜 脈動する境界**<br>(第1面ボス戦 A案) | G短調<br>168 BPM | 46.83s | **【本採用】1面ボスBGM** |
| **AUD-016** | `assets/audio/music/bgm_boss01_plan_b.wav` | `assets/audio/midi/bgm_boss01_plan_b.mid` | 輪廻の狂詩曲 〜 死線突破<br>(第1面ボス戦 B案) | E短調<br>174 BPM | 45.18s | **【採用】高難度変奏** |
| **AUD-023** | `assets/audio/music/bgm_stage02_plan_a.wav` | `assets/audio/midi/bgm_stage02_plan_a.mid` | **追憶の海 〜 水底の残照**<br>(第2面道中 A案) | Eb長調<br>108 BPM (6/8) | 28.67s | **【本採用】2面道中BGM** |
| **AUD-024** | `assets/audio/music/bgm_stage02_plan_b.wav` | `assets/audio/midi/bgm_stage02_plan_b.mid` | 追憶の海 〜 潮流のセレナーデ<br>(第2面道中 B案) | G短調<br>120 BPM | 34.00s | **【採用】2周目変奏** |
| **AUD-025** | `assets/audio/music/bgm_stage03_plan_a.wav` | `assets/audio/midi/bgm_stage03_plan_a.mid` | **孤独な庭 〜 錆びた歯車と曼珠沙華**<br>(第3面道中 A案) | G短調<br>126 BPM (3/4) | 25.36s | **【本採用】3面道中BGM** |
| **AUD-026** | `assets/audio/music/bgm_stage03_plan_b.wav` | `assets/audio/midi/bgm_stage03_plan_b.mid` | 孤独な庭 〜 静寂の回廊<br>(第3面道中 B案) | D短調<br>88 BPM | 35.73s | **【採用】2周目変奏** |
| **AUD-027** | `assets/audio/music/bgm_stage04_plan_a.wav` | `assets/audio/midi/bgm_stage04_plan_a.mid` | **分岐する空 〜 碧落の疾走**<br>(第4面道中 A案) | E短調<br>165 BPM | 25.27s | **【本採用】4面道中BGM** |
| **AUD-028** | `assets/audio/music/bgm_stage04_plan_b.wav` | `assets/audio/midi/bgm_stage04_plan_b.mid` | 分岐する空 〜 乱気流のロンド<br>(第4面道中 B案) | A短調<br>158 BPM | 26.30s | **【採用】2周目変奏** |
| **AUD-029** | `assets/audio/music/bgm_stage05_plan_a.wav` | `assets/audio/midi/bgm_stage05_plan_a.mid` | **忘却の要塞 〜 鋼鉄の残影**<br>(第5面道中 A案) | C短調<br>148 BPM | 27.95s | **【本採用】5面道中BGM** |
| **AUD-030** | `assets/audio/music/bgm_stage05_plan_b.wav` | `assets/audio/midi/bgm_stage05_plan_b.mid` | 忘却の要塞 〜 機械仕掛けの記憶<br>(第5面道中 B案) | D短調<br>152 BPM | 27.26s | **【採用】2周目変奏** |

---

## 2. ジングル一覧 (Jingle - 全8種)

| 素材ID | ファイルパス | 名称 / 場面 | 尺 | 特徴 | 採用ステータス |
|---|---|---|---|---|---|
| **AUD-010** | `assets/audio/jingles/jg001_title.wav` | JG-001: タイトル表示ジングル | 2.60s | 笙の重厚和音＋クリスタルチャイム | **【採用】ロゴ表示** |
| **AUD-017** | `assets/audio/jingles/jg002_sortie.wav` | JG-002: 出撃決定ファンファーレ | 3.80s | 龍笛・琵琶駆け上がり＋太鼓 | **【採用】自機決定時** |
| **AUD-011** | `assets/audio/jingles/jg003_stage_start.wav` | JG-003: ステージ開始・発進ジングル | 2.80s | 点火スイープ＋金管＋ブースト爆燃 | **【採用】発進・出撃演出** |
| **AUD-044** | `assets/audio/jingles/jg004_miniboss.wav` | JG-004: 小ボス出現アラート | 2.40s | 急接近パルス＋緊迫ブラス | **【採用】中ボス演出** |
| **AUD-045** | `assets/audio/jingles/jg006_boss_warning.wav` | JG-006: 大ボス出現警告 | 3.40s | 交互サイレン警報＋巨大出現和音 | **【採用】大ボス警告** |
| **AUD-012** | `assets/audio/jingles/jg007_stage_clear.wav` | JG-007: ステージクリアジングル | 3.60s | 勝利アルペジオ＋和太鼓連打 | **【採用】クリアリザルト** |
| **AUD-046** | `assets/audio/jingles/jg011_weapon_unlocked.wav` | JG-011: 新武器完成・パワー全開 | 2.60s | 駆け上がりアルペジオ＋歓喜和音 | **【採用】強化演出** |
| **AUD-047** | `assets/audio/jingles/jg012_worldline_shift.wav` | JG-012: 世界線移動・時空ワープ | 2.80s | ディメンション・ワープスイープ | **【採用】世界線シフト** |

---

## 3. 効果音一覧 (SFX - 全27種)

### A. レーザー・特化武装 (3種)
- `AUD-048` `se_laser_pierce.wav`：貫通ハイパービームレーザー (0.38s)
- `AUD-049` `se_laser_enemy_sweep.wav`：敵極太薙ぎ払いレーザー (0.85s)
- `AUD-050` `se_laser_homing.wav`：追尾ホーミングレーザー (0.28s)

### B. 爽快ショット音 (3種)
- `AUD-051` `se_shot_cormii_wide.wav`：コルミィ 5WAY拡散ショット (0.20s)
- `AUD-052` `se_shot_jiyoza_beam.wav`：ジヨーザ 集束貫通フォトンレーザー (0.24s)
- `AUD-053` `se_shot_mafio_wave.wav`：マフィオ 波動生体キャノン (0.32s)

### C. 爽快撃破・破壊音 (3種)
- `AUD-054` `se_destroy_medium.wav`：中型敵撃破重爆発 (0.65s)
- `AUD-055` `se_destroy_heavy_chain.wav`：大型敵連続誘爆 (1.60s)
- `AUD-056` `se_armor_break.wav`：装甲破壊・シールドブレイク (0.42s)

### D. 機体固有・戦闘・システムSE (18種)
- `AUD-018` 〜 `AUD-020`: 3機通常ショット
- `AUD-031` 〜 `AUD-036`: チャージ完了、おみくじ、解析完了、バリア、捕食、能力獲得
- `AUD-037` 〜 `AUD-043`: 被弾、敵弾、小型爆発、ボス予兆、ボス撃破、アイテム取得、UI操作音3種

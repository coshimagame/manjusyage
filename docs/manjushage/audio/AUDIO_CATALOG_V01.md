# 『曼珠沙華（MANJUSHAGE）』公式音響素材台帳 (v1.0)

制作：**Mw-fActory 音楽制作チーム**（Antigravity サウンド制作責任者）  
版数：v1.0（2026-11-16）  
状態：**【ユーザー承認済み・正式採用】(APPROVED & ADOPTED)**  
原本生成コード：
- `tools/audio/generate_opening_bgm.py`（オープニング・タイトル曲）
- `tools/audio/generate_audio_assets.py`（第1面道中・ボス1）
- `tools/audio/generate_stage_variations.py`（第2面海・第3面廃墟 多彩音色エンジン）
- `tools/audio/generate_expanded_sfx_and_jingles.py`（ジングル・機体固有SE・戦闘・システムSE）  
品質検査：`tests/test_audio_batch01.py`（**全32素材 合格 100% PASS**）  

---

## 1. 制作概要・品質保証基準

本台帳は、Steam向けオリジナルシューティングゲーム『曼珠沙華（MANJUSHAGE）』における全32音響素材（BGM 10曲、ジングル 4種、機体固有効果音 9種、戦闘・システム効果音 9種）の現物仕様および採用状況を記録した公式台帳です。

- **フォーマット**：44,100 Hz, 16-bit PCM ステレオ WAV
- **音量基準**：ピーク天井 -1.0 dBFS（最大振幅 0.891）正規化、DCオフセット 0.0、クリッピング皆無
- **権利情報**：完全オリジナル数学的波形合成。外部サンプリング音源・既存曲メロディー・他社著作物の流用は一切なし。

---

## 2. 音楽素材一覧 (BGM - 全10曲)

各楽曲はWAV音源に加えて、DAWでの編集・音色差し替えが可能な**SMF Format 1 標準MIDIファイル（.mid）**を原本として完全納品しています。

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

---

## 3. ジングル一覧 (Jingle - 全4種)

| 素材ID | ファイルパス | 名称 / 場面 | 尺 | 特徴 | 採用ステータス |
|---|---|---|---|---|---|
| **AUD-010** | `assets/audio/jingles/jg001_title.wav` | JG-001: タイトル表示ジングル | 2.60s | 笙の重厚和音＋クリスタルチャイム | **【採用】ロゴ表示** |
| **AUD-017** | `assets/audio/jingles/jg002_sortie.wav` | JG-002: 出撃決定ファンファーレ | 3.80s | 龍笛・琵琶駆け上がり＋太鼓 | **【採用】自機決定時** |
| **AUD-011** | `assets/audio/jingles/jg003_stage_start.wav` | JG-003: ステージ開始・発進ジングル | 2.80s | 点火スイープ＋金管＋ブースト爆燃 | **【採用】発進・出撃演出** |
| **AUD-012** | `assets/audio/jingles/jg007_stage_clear.wav` | JG-007: ステージクリアジングル | 3.60s | 勝利アルペジオ＋和太鼓連打 | **【採用】クリアリザルト** |

---

## 4. 効果音一覧 (SFX - 全18種)

### A. プレイヤー3機 固有SE (9種)
| 素材ID | ファイルパス | 機体 / 能力 | 尺 | 特徴 |
|---|---|---|---|---|
| **AUD-018** | `assets/audio/sfx/se_shot_cormii.wav` | コルミィ通常弾 | 0.14s | 920Hz→180Hz プラズマバースト |
| **AUD-031** | `assets/audio/sfx/se_cormii_charge.wav` | コルミィ最大出力 | 0.45s | 急上昇プラズマ共鳴パルス |
| **AUD-032** | `assets/audio/sfx/se_cormii_omikuji.wav` | コルミィ開運おみくじ | 0.38s | 神社鈴風 四重クリスタルチャイム |
| **AUD-019** | `assets/audio/sfx/se_shot_jiyoza.wav` | ジヨーザ通常弾 | 0.15s | 1950Hz/1300Hz 精緻レーザー |
| **AUD-033** | `assets/audio/sfx/se_jiyoza_analyze.wav` | ジヨーザ解析完了 | 0.30s | ハイテク2段階ロックオンチャープ |
| **AUD-034** | `assets/audio/sfx/se_jiyoza_barrier.wav` | ジヨーザ解析バリア | 0.40s | クリスタル防御シールドハム音 |
| **AUD-020** | `assets/audio/sfx/se_shot_mafio.wav` | マフィオ通常弾 | 0.18s | 165Hz→42Hz 重低音バイオ弾 |
| **AUD-035** | `assets/audio/sfx/se_mafio_predation.wav` | マフィオ捕食 | 0.32s | 吸引バキューム＋咀嚼クランチ |
| **AUD-036** | `assets/audio/sfx/se_mafio_absorb.wav` | マフィオ能力獲得 | 0.38s | 生体同化重低音パルス |

### B. 基本戦闘・システムSE (9種)
| 素材ID | ファイルパス | 対象イベント | 尺 | 特徴 |
|---|---|---|---|---|
| **AUD-037** | `assets/audio/sfx/se_player_hit.wav` | 自機被弾 / シールド損傷 | 0.28s | 金属打撃衝撃＋シールド警報 |
| **AUD-038** | `assets/audio/sfx/se_enemy_shot.wav` | 敵弾発射 | 0.12s | レトロSTG定番の高域レーザー |
| **AUD-039** | `assets/audio/sfx/se_enemy_destroy_small.wav` | 雑魚敵撃破爆発 | 0.35s | 爽快な破砕クラッシュノイズ |
| **AUD-021** | `assets/audio/sfx/se_boss_warning.wav` | ボス攻撃予兆音 | 0.85s | FM金属音＋18Hz変調警告 |
| **AUD-022** | `assets/audio/sfx/se_boss_destroy.wav` | ボス撃破大爆発 | 2.80s | 衝撃波＋連鎖爆発＋結晶散乱 |
| **AUD-040** | `assets/audio/sfx/se_item_get.wav` | アイテム取得 | 0.25s | D6→A6 軽快な2連ベル音 |
| **AUD-041** | `assets/audio/sfx/se_menu_cursor.wav` | メニュー移動 | 0.04s | 880Hz 短音ブリップ |
| **AUD-042** | `assets/audio/sfx/se_menu_select.wav` | メニュー決定 | 0.12s | 前向きな上昇トーン |
| **AUD-043** | `assets/audio/sfx/se_menu_cancel.wav` | メニュー取消 | 0.10s | 落ち着いた下降トーン |

---

## 5. Codex 実装連携

Godot 4.6 への組み込み手順、ノード構成、音量バランスおよびトリガー制御仕様については、下記連携指示書に完全準拠します：
- [CODEX_AUDIO_HANDOFF_V01.md](file:///C:/Users/wa-ma/.gemini/antigravity/scratch/manjusyage/docs/manjushage/audio/CODEX_AUDIO_HANDOFF_V01.md)

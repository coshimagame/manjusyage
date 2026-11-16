#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Mw-fActory Sound Team: Comprehensive HTML5 Web Audio Preview Player Builder
Encodes all 32 generated audio assets into a single standalone HTML page with Base64 audio URIs.
"""

import os
import base64
import json

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
PREVIEW_DIR = os.path.join(r"C:\Users\wa-ma\.gemini\antigravity\brain\8d77af9d-9696-457f-a23d-0b87681dcbec", "audio_preview")
OUTPUT_HTML = os.path.join(r"C:\Users\wa-ma\.gemini\antigravity\brain\8d77af9d-9696-457f-a23d-0b87681dcbec", "audio_player.html")

TRACKS = [
    # BGM
    {
        "id": "AUD-001",
        "category": "bgm",
        "title": "タイトル・オープニング A案「曼珠沙華 〜 記憶の深淵」",
        "subtitle": "82 BPM / D minor / 44.0s (本採用)",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_opening_plan_a.wav"),
        "loop": True,
        "desc": "【正式採用】笙の幽玄な和音、ハープ・琴のアルペジオ、哀愁と情熱のSFC木管リード、重厚なチェロとティンパニ。"
    },
    {
        "id": "AUD-002",
        "category": "bgm",
        "title": "タイトル・オープニング B案「曼珠沙華 〜 輪廻のプロローグ」",
        "subtitle": "96 BPM / A minor / 37.5s (2周目変奏用)",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_opening_plan_b.wav"),
        "loop": True,
        "desc": "透明感ある水晶チャイム、心臓の鼓動を思わせるサブビート、胸を打つ哀愁の旋律と静かな情熱。"
    },
    {
        "id": "AUD-013",
        "category": "bgm",
        "title": "第1面「赤い残響」A案「幽玄の飛翔」",
        "subtitle": "156 BPM / D minor / 49.2s (本採用)",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage01_plan_a.wav"),
        "loop": True,
        "desc": "【正式採用】雅楽フューチャー × 哀愁の疾走感。笙の宇宙空間、篳篥のエモーショナルな主旋律、FMベースの推進力。"
    },
    {
        "id": "AUD-014",
        "category": "bgm",
        "title": "第1面「赤い残響」B案「緋色の鼓動」",
        "subtitle": "162 BPM / F# minor / 51.2s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage01_plan_b.wav"),
        "loop": True,
        "desc": "往年の王道アクションSTGを彷彿とさせる疾走感。三連符ギャロップベースと切ないサビ展開。"
    },
    {
        "id": "AUD-015",
        "category": "bgm",
        "title": "第1面ボス戦 A案「生体中枢 〜 脈動する境界」",
        "subtitle": "168 BPM / G minor / 46.8s (本採用)",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_boss01_plan_a.wav"),
        "loop": True,
        "desc": "【正式採用】巨大生体コアの脈動。減五度トリトーンの不気味さ、叫ぶ篳篥、緊迫のポリリズム太鼓。"
    },
    {
        "id": "AUD-016",
        "category": "bgm",
        "title": "第1面ボス戦 B案「輪廻の狂詩曲 〜 死線突破」",
        "subtitle": "174 BPM / E minor / 45.2s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_boss01_plan_b.wav"),
        "loop": True,
        "desc": "超高速テクノSTGバトル。主題動機を極限まで加速させ、死線を潜り抜ける緊張感。"
    },
    {
        "id": "AUD-023",
        "category": "bgm",
        "title": "第2面「追憶の海」A案「水底の残照」",
        "subtitle": "108 BPM / 6/8拍子 潮騒ワルツ / Eb Major / 28.7s (本採用)",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage02_plan_a.wav"),
        "loop": True,
        "desc": "【正式採用】透明なビブラフォン主旋律、暖かなRhodesエレピ和音、クラシックギター分散和音、水滴音、ブラシスネア。"
    },
    {
        "id": "AUD-024",
        "category": "bgm",
        "title": "第2面「追憶の海」B案「潮流のセレナーデ」",
        "subtitle": "120 BPM / G minor / 34.0s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage02_plan_b.wav"),
        "loop": True,
        "desc": "木製マリンバの16分アルペジオ水流、ビブラフォン哀愁旋律、水泡チャープ、深海フレットレスベース。"
    },
    {
        "id": "AUD-025",
        "category": "bgm",
        "title": "第3面「孤独な庭・廃墟」A案「錆びた歯車と曼珠沙華」",
        "subtitle": "126 BPM / 3/4拍子 からくりワルツ / G minor / 25.4s (本採用)",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage03_plan_a.wav"),
        "loop": True,
        "desc": "【正式採用】アンティークオルゴール（鉄櫛歯の結晶音）、古時計のチクタク音、クラシックギター、チェンバロ、教会鐘。"
    },
    {
        "id": "AUD-026",
        "category": "bgm",
        "title": "第3面「孤独な庭・廃墟」B案「静寂の回廊」",
        "subtitle": "88 BPM / D minor / 35.7s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage03_plan_b.wav"),
        "loop": True,
        "desc": "むせび泣く孤独なチェロ独奏、爪弾くクラシックギターアルペジオ、教会鐘の残響、パイプオルガン。"
    },
    # Jingles
    {
        "id": "AUD-010",
        "category": "jingle",
        "title": "JG-001: タイトル表示ジングル",
        "subtitle": "2.60s / Title Logo / Bloom",
        "file": os.path.join(PREVIEW_DIR, "jingles", "jg001_title.wav"),
        "loop": False,
        "desc": "笙の重厚な開花和音から、高音クリスタルチャイムが駆け上がる神聖なロゴ表示音。"
    },
    {
        "id": "AUD-017",
        "category": "jingle",
        "title": "JG-002: 出撃決定ファンファーレ",
        "subtitle": "3.80s / Sortie Confirmed",
        "file": os.path.join(PREVIEW_DIR, "jingles", "jg002_sortie.wav"),
        "loop": False,
        "desc": "笙の和音から龍笛・琵琶の駆け上がりアルペジオ、太鼓の連打とブースト点火の低域炸裂音。"
    },
    {
        "id": "AUD-011",
        "category": "jingle",
        "title": "JG-003: ステージ開始・発進ジングル",
        "subtitle": "2.80s / Stage Launch Departure",
        "file": os.path.join(PREVIEW_DIR, "jingles", "jg003_stage_start.wav"),
        "loop": False,
        "desc": "ジェットエンジン点火・高周波スイープから金管ファンファーレ、ブースト加速炸裂音への展開。"
    },
    {
        "id": "AUD-012",
        "category": "jingle",
        "title": "JG-007: ステージクリアジングル",
        "subtitle": "3.60s / Victory Resolution",
        "file": os.path.join(PREVIEW_DIR, "jingles", "jg007_stage_clear.wav"),
        "loop": False,
        "desc": "勝利のファンファーレアルペジオ、和太鼓の連打と安堵の和音着地。"
    },
    # Character SFX
    {
        "id": "AUD-018",
        "category": "sfx",
        "title": "コルミィ通常ショット SE",
        "subtitle": "0.14s / Plasma Burst",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_shot_cormii.wav"),
        "loop": False,
        "desc": "920Hz→180Hz急降下。快活で瞬間火力の高いプラズマバースト音。"
    },
    {
        "id": "AUD-031",
        "category": "sfx",
        "title": "コルミィ最大出力・チャージ完了 SE",
        "subtitle": "0.45s / Full Power Surge",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_cormii_charge.wav"),
        "loop": False,
        "desc": "220Hzから急上昇するプラズマ共鳴パルス。最大出力到達の爽快な合図。"
    },
    {
        "id": "AUD-032",
        "category": "sfx",
        "title": "コルミィ開運おみくじ・アイテム発動 SE",
        "subtitle": "0.38s / Lucky Shinto Chime",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_cormii_omikuji.wav"),
        "loop": False,
        "desc": "神社の鈴のような四重クリスタルチャイム。運気上昇を告げる軽やかな煌めき。"
    },
    {
        "id": "AUD-019",
        "category": "sfx",
        "title": "ジヨーザ通常ショット SE",
        "subtitle": "0.15s / Dual Laser Chirp",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_shot_jiyoza.wav"),
        "loop": False,
        "desc": "1950Hz/1300Hzデュアルスイープ。知的で精緻な集束レーザー音。"
    },
    {
        "id": "AUD-033",
        "category": "sfx",
        "title": "ジヨーザ解析完了 SE",
        "subtitle": "0.30s / Lock-on Analysis",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_jiyoza_analyze.wav"),
        "loop": False,
        "desc": "2段階のハイテク電子チャープ音。弱点看破・解析完了の精緻なフィードバック。"
    },
    {
        "id": "AUD-034",
        "category": "sfx",
        "title": "ジヨーザ解析バリア展開 SE",
        "subtitle": "0.40s / Crystal Barrier",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_jiyoza_barrier.wav"),
        "loop": False,
        "desc": "共振周波数を捉えて展開するクリスタル防御シールドのハム音。"
    },
    {
        "id": "AUD-020",
        "category": "sfx",
        "title": "マフィオ通常ショット SE",
        "subtitle": "0.18s / Bio Cannon",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_shot_mafio.wav"),
        "loop": False,
        "desc": "165Hz→42Hz重低音＋クラッシュ。食欲旺盛・力強い生体弾撃音。"
    },
    {
        "id": "AUD-035",
        "category": "sfx",
        "title": "マフィオ捕食音 SE",
        "subtitle": "0.32s / Vacuum Predation",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_mafio_predation.wav"),
        "loop": False,
        "desc": "敵を引き裂き丸呑みするバキューム吸引と咀嚼クランチ音。"
    },
    {
        "id": "AUD-036",
        "category": "sfx",
        "title": "マフィオ能力獲得・消化完了 SE",
        "subtitle": "0.38s / Power Mutation",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_mafio_absorb.wav"),
        "loop": False,
        "desc": "捕食した特性を機体へ同化・定着させる生体重低音パルス。"
    },
    # Core Combat & System SFX
    {
        "id": "AUD-037",
        "category": "sfx",
        "title": "自機被弾・シールド損傷 SE",
        "subtitle": "0.28s / Shield Damage",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_player_hit.wav"),
        "loop": False,
        "desc": "金属的打撃衝撃音とシールド低下のアラート。"
    },
    {
        "id": "AUD-038",
        "category": "sfx",
        "title": "敵弾発射 SE",
        "subtitle": "0.12s / Enemy Laser",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_enemy_shot.wav"),
        "loop": False,
        "desc": "レトロSTG定番の鋭い高域下降レーザーパルス。"
    },
    {
        "id": "AUD-039",
        "category": "sfx",
        "title": "小型敵撃破爆発 SE",
        "subtitle": "0.35s / Crisp Explosion",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_enemy_destroy_small.wav"),
        "loop": False,
        "desc": "小気味よい低音アタックと破砕ノイズ。連鎖撃破時の爽快感を重視。"
    },
    {
        "id": "AUD-021",
        "category": "sfx",
        "title": "ボス大技予兆 SE",
        "subtitle": "0.85s / Threat Alert",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_boss_warning.wav"),
        "loop": False,
        "desc": "320Hz→980Hz FM金属音＋18Hz変調。BGMを突き抜ける危険警告。"
    },
    {
        "id": "AUD-022",
        "category": "sfx",
        "title": "ボス撃破 SE",
        "subtitle": "2.80s / Massive Destruction",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_boss_destroy.wav"),
        "loop": False,
        "desc": "初速衝撃波＋深層地響き＋多重連鎖爆発＋結晶散乱テール。"
    },
    {
        "id": "AUD-040",
        "category": "sfx",
        "title": "アイテム取得・パワーアップ SE",
        "subtitle": "0.25s / Item Get",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_item_get.wav"),
        "loop": False,
        "desc": "D6→A6の爽やかな二連ベル音。"
    },
    {
        "id": "AUD-041",
        "category": "sfx",
        "title": "メニュー移動 SE",
        "subtitle": "0.04s / Cursor Move",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_menu_cursor.wav"),
        "loop": False,
        "desc": "軽快で邪魔にならない880Hz短音ブリップ。"
    },
    {
        "id": "AUD-042",
        "category": "sfx",
        "title": "メニュー決定 SE",
        "subtitle": "0.12s / Confirm",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_menu_select.wav"),
        "loop": False,
        "desc": "前向きな2連上昇トーン。"
    },
    {
        "id": "AUD-043",
        "category": "sfx",
        "title": "メニューキャンセル SE",
        "subtitle": "0.10s / Cancel",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_menu_cancel.wav"),
        "loop": False,
        "desc": "落ち着いた2連下降トーン。"
    },
]

print("Encoding audio tracks to base64...")
track_data = []
for t in TRACKS:
    with open(t["file"], "rb") as f:
        b64 = base64.b64encode(f.read()).decode("ascii")
    track_data.append({
        "id": t["id"],
        "category": t["category"],
        "title": t["title"],
        "subtitle": t["subtitle"],
        "loop": t["loop"],
        "desc": t["desc"],
        "data_uri": f"data:audio/wav;base64,{b64}"
    })
    print(f"  Encoded {t['id']} ({len(b64)} chars)")

json_tracks = json.dumps(track_data)

html_content = f"""<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>曼珠沙華 (MANJUSHAGE) - Mw-fActory 音楽・効果音試聴コンソール</title>
<style>
  :root {{
    --bg-dark: #0a0a10;
    --card-bg: #141420;
    --card-hover: #1c1c30;
    --accent-red: #e63946;
    --accent-gold: #f4a261;
    --accent-cyan: #2a9d8f;
    --text-main: #f1faee;
    --text-sub: #a8dadc;
    --text-dim: #707585;
    --active-border: #e63946;
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    background-color: var(--bg-dark);
    color: var(--text-main);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    padding: 24px;
    line-height: 1.5;
  }}
  header {{
    border-bottom: 2px solid var(--accent-red);
    padding-bottom: 16px;
    margin-bottom: 24px;
  }}
  h1 {{
    font-size: 26px;
    color: var(--text-main);
    letter-spacing: 2px;
    display: flex;
    align-items: center;
    gap: 12px;
  }}
  .badge {{
    font-size: 11px;
    padding: 3px 8px;
    border-radius: 4px;
    background: var(--accent-red);
    color: #fff;
    font-weight: normal;
  }}
  .sub-header {{
    color: var(--text-sub);
    font-size: 13px;
    margin-top: 6px;
  }}
  .filter-tabs {{
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
  }}
  .tab-btn {{
    background: var(--card-bg);
    border: 1px solid #2a2a3e;
    color: var(--text-sub);
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    transition: all 0.2s;
  }}
  .tab-btn:hover, .tab-btn.active {{
    background: var(--accent-red);
    color: #fff;
    border-color: var(--accent-red);
  }}
  .grid {{
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
    gap: 16px;
  }}
  .card {{
    background: var(--card-bg);
    border: 1px solid #222238;
    border-radius: 8px;
    padding: 16px;
    transition: all 0.2s;
    position: relative;
  }}
  .card:hover {{
    background: var(--card-hover);
    border-color: var(--accent-gold);
  }}
  .card.playing {{
    border-color: var(--active-border);
    box-shadow: 0 0 14px rgba(230, 57, 70, 0.4);
  }}
  .card-top {{
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 8px;
  }}
  .track-id {{
    font-size: 12px;
    font-weight: bold;
    color: var(--accent-gold);
    letter-spacing: 1px;
  }}
  .category-pill {{
    font-size: 10px;
    padding: 2px 6px;
    border-radius: 3px;
    background: #1e2638;
    color: var(--accent-cyan);
    text-transform: uppercase;
  }}
  .track-title {{
    font-size: 15px;
    font-weight: bold;
    color: var(--text-main);
    margin-bottom: 4px;
  }}
  .track-sub {{
    font-size: 12px;
    color: var(--text-dim);
    margin-bottom: 12px;
  }}
  .track-desc {{
    font-size: 12px;
    color: var(--text-sub);
    margin-bottom: 14px;
    min-height: 36px;
  }}
  .controls {{
    display: flex;
    align-items: center;
    gap: 10px;
  }}
  .play-btn {{
    background: var(--accent-red);
    border: none;
    color: white;
    width: 38px;
    height: 38px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    transition: transform 0.1s;
  }}
  .play-btn:active {{
    transform: scale(0.92);
  }}
  .progress-bar-bg {{
    flex: 1;
    height: 6px;
    background: #2a2a3e;
    border-radius: 3px;
    overflow: hidden;
    cursor: pointer;
  }}
  .progress-bar-fill {{
    height: 100%;
    width: 0%;
    background: var(--accent-gold);
    transition: width 0.1s linear;
  }}
  .time-display {{
    font-size: 11px;
    color: var(--text-dim);
    min-width: 60px;
    text-align: right;
    font-variant-numeric: tabular-nums;
  }}
  .loop-badge {{
    font-size: 10px;
    color: var(--accent-cyan);
    display: inline-flex;
    align-items: center;
    gap: 3px;
  }}
</style>
</head>
<body>

<header>
  <h1>曼珠沙華 (MANJUSHAGE) <span class="badge">全32音響素材 正式採用カタログ</span></h1>
  <div class="sub-header">Mw-fActory 音楽制作責任者（Antigravity） | 44.1kHz 16bit Stereo PCM 完全保証 | クリッピング皆無</div>
</header>

<div class="filter-tabs">
  <button class="tab-btn active" onclick="filterCategory('all')">全素材 (32)</button>
  <button class="tab-btn" onclick="filterCategory('bgm')">BGM (10)</button>
  <button class="tab-btn" onclick="filterCategory('jingle')">ジングル (4)</button>
  <button class="tab-btn" onclick="filterCategory('sfx')">効果音 (18)</button>
</div>

<div class="grid" id="grid"></div>

<script>
const tracks = {json_tracks};
let currentAudio = null;
let currentTrackId = null;
let currentProgressFill = null;
let currentTimeDisplay = null;

function renderGrid(filter = 'all') {{
  const grid = document.getElementById('grid');
  grid.innerHTML = '';
  tracks.forEach(t => {{
    if (filter !== 'all' && t.category !== filter) return;
    const card = document.createElement('div');
    card.className = 'card';
    card.id = 'card-' + t.id;
    card.innerHTML = `
      <div class="card-top">
        <span class="track-id">${{t.id}}</span>
        <span class="category-pill">${{t.category}}</span>
      </div>
      <div class="track-title">${{t.title}}</div>
      <div class="track-sub">${{t.subtitle}} ${{t.loop ? '<span class="loop-badge">🔁 シームレスループ</span>' : ''}}</div>
      <div class="track-desc">${{t.desc}}</div>
      <div class="controls">
        <button class="play-btn" id="btn-${{t.id}}" onclick="togglePlay('${{t.id}}')">▶</button>
        <div class="progress-bar-bg" onclick="seekTrack(event, '${{t.id}}')">
          <div class="progress-bar-fill" id="fill-${{t.id}}"></div>
        </div>
        <span class="time-display" id="time-${{t.id}}">0:00</span>
      </div>
    `;
    grid.appendChild(card);
  }});
}}

function togglePlay(id) {{
  if (currentTrackId === id) {{
    if (currentAudio && !currentAudio.paused) {{
      currentAudio.pause();
      document.getElementById('btn-' + id).textContent = '▶';
      document.getElementById('card-' + id).classList.remove('playing');
    }} else if (currentAudio) {{
      currentAudio.play();
      document.getElementById('btn-' + id).textContent = '⏸';
      document.getElementById('card-' + id).classList.add('playing');
    }}
    return;
  }}

  if (currentAudio) {{
    currentAudio.pause();
    if (currentTrackId) {{
      const b = document.getElementById('btn-' + currentTrackId);
      const c = document.getElementById('card-' + currentTrackId);
      if (b) b.textContent = '▶';
      if (c) c.classList.remove('playing');
    }}
  }}

  const track = tracks.find(t => t.id === id);
  if (!track) return;

  currentAudio = new Audio(track.data_uri);
  currentAudio.loop = track.loop;
  currentTrackId = id;
  currentProgressFill = document.getElementById('fill-' + id);
  currentTimeDisplay = document.getElementById('time-' + id);

  currentAudio.addEventListener('timeupdate', () => {{
    if (!currentAudio.duration) return;
    const pct = (currentAudio.currentTime / currentAudio.duration) * 100;
    if (currentProgressFill) currentProgressFill.style.width = pct + '%';
    if (currentTimeDisplay) {{
      const cur = formatTime(currentAudio.currentTime);
      const tot = formatTime(currentAudio.duration);
      currentTimeDisplay.textContent = cur + ' / ' + tot;
    }}
  }});

  currentAudio.addEventListener('ended', () => {{
    if (!track.loop) {{
      document.getElementById('btn-' + id).textContent = '▶';
      document.getElementById('card-' + id).classList.remove('playing');
      if (currentProgressFill) currentProgressFill.style.width = '0%';
    }}
  }});

  currentAudio.play();
  document.getElementById('btn-' + id).textContent = '⏸';
  document.getElementById('card-' + id).classList.add('playing');
}}

function seekTrack(event, id) {{
  if (currentTrackId !== id || !currentAudio || !currentAudio.duration) return;
  const rect = event.currentTarget.getBoundingClientRect();
  const ratio = (event.clientX - rect.left) / rect.width;
  currentAudio.currentTime = ratio * currentAudio.duration;
}}

function formatTime(sec) {{
  const m = Math.floor(sec / 60);
  const s = Math.floor(sec % 60);
  return m + ':' + (s < 10 ? '0' : '') + s;
}}

function filterCategory(cat) {{
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');
  renderGrid(cat);
}}

renderGrid();
</script>
</body>
</html>
"""

with open(OUTPUT_HTML, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"=== Audio Player HTML written to {OUTPUT_HTML} ({len(html_content)} bytes) ===")

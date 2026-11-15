#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate standalone interactive HTML Audio Player for Mw-fActory Sound Team Batch 01."""

import os
import base64
import json

PREVIEW_DIR = r"C:\Users\wa-ma\.gemini\antigravity\brain\8d77af9d-9696-457f-a23d-0b87681dcbec\audio_preview"
OUTPUT_HTML = r"C:\Users\wa-ma\.gemini\antigravity\brain\8d77af9d-9696-457f-a23d-0b87681dcbec\audio_player.html"

TRACKS = [
    {
        "id": "AUD-013",
        "category": "bgm",
        "title": "第1面道中 A案「赤い残響 〜 幽玄の飛翔」",
        "subtitle": "160 BPM / D minor (Dorian) / 48.0s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage01_plan_a.wav"),
        "loop": True,
        "desc": "雅楽フューチャー × 疾走哀愁。笙の天蓋和音、篳篥のエモーショナルな主旋律、龍笛の高音、16-bit FMベースと電子ドラム。"
    },
    {
        "id": "AUD-014",
        "category": "bgm",
        "title": "第1面道中 B案「赤い残響 〜 緋色の鼓動」",
        "subtitle": "152 BPM / F# minor / 50.5s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage01_plan_b.wav"),
        "loop": True,
        "desc": "往年の名作STGを想起させる哀愁のレトロロック調。三連符ギャロップのFMベースラインと情熱的なコード進行。"
    },
    {
        "id": "AUD-015",
        "category": "bgm",
        "title": "第1面ボス戦 A案「生体中枢 〜 脈動する境界」",
        "subtitle": "168 BPM / G minor (Diminished) / 45.7s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_boss01_plan_a.wav"),
        "loop": True,
        "desc": "減五度の不気味な和声と変拍子風和太鼓連打。心臓状生体天体中枢のうごめく胎動と緊迫の死闘。"
    },
    {
        "id": "AUD-016",
        "category": "bgm",
        "title": "第1面ボス戦 B案「輪廻の狂詩曲 〜 死線突破」",
        "subtitle": "174 BPM / C minor / 44.1s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_boss01_plan_b.wav"),
        "loop": True,
        "desc": "BPM 174の超高速テクノSTGバトル。第1面の主題動機を極限まで加速・尖鋭化させたクライマックスラプソディ。"
    },
    {
        "id": "AUD-023",
        "category": "bgm",
        "title": "第2面「追憶の海」A案「水底の残照」",
        "subtitle": "136 BPM / F minor / 56.5s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage02_plan_a.wav"),
        "loop": True,
        "desc": "水中の浮遊感、水泡が弾ける音、深海サブベース、透明なアクアストリングスと哀愁のパンフルート旋律。"
    },
    {
        "id": "AUD-024",
        "category": "bgm",
        "title": "第2面「追憶の海」B案「潮流のセレナーデ」",
        "subtitle": "142 BPM / Bb minor (Dorian) / 54.1s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage02_plan_b.wav"),
        "loop": True,
        "desc": "湧き上がる潮流の躍動感。泡のように流れる16分アルペジオと切なく高鳴るリード。"
    },
    {
        "id": "AUD-025",
        "category": "bgm",
        "title": "第3面「孤独な庭」A案「錆びた歯車と曼珠沙華」",
        "subtitle": "144 BPM / A minor (Insen Modal) / 53.3s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage03_plan_a.wav"),
        "loop": True,
        "desc": "機械文明の廃墟。歯車のチクタク音、古びた石壁に咲く曼珠沙華を想わせる陰旋法の箏ハープと孤独な和笛。"
    },
    {
        "id": "AUD-026",
        "category": "bgm",
        "title": "第3面「孤独な庭」B案「静寂の回廊」",
        "subtitle": "138 BPM / E minor / 55.7s",
        "file": os.path.join(PREVIEW_DIR, "music", "bgm_stage03_plan_b.wav"),
        "loop": True,
        "desc": "誰もいない回廊に響く時計仕掛けのリズム。静寂と廃墟の不気味さ、そして胸を締め付ける哀愁の疾走メロディ。"
    },
    {
        "id": "AUD-017",
        "category": "jingle",
        "title": "JG-002: 出撃決定ファンファーレ",
        "subtitle": "D major / 3.6s",
        "file": os.path.join(PREVIEW_DIR, "jingles", "jg002_sortie.wav"),
        "loop": False,
        "desc": "笙の重厚な和音から龍笛・琵琶の駆け上がりアルペジオ、太鼓の連打とブースト点火の低域炸裂音。"
    },
    {
        "id": "AUD-018",
        "category": "sfx",
        "title": "コルミィ通常ショット SE",
        "subtitle": "0.14s / Plasma Burst",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_shot_cormii.wav"),
        "loop": False,
        "desc": "920Hz→180Hz急降下。元気で瞬間火力の高いプラズマバースト音。"
    },
    {
        "id": "AUD-019",
        "category": "sfx",
        "title": "ジヨーザ通常ショット SE",
        "subtitle": "0.15s / Dual Chirp",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_shot_jiyoza.wav"),
        "loop": False,
        "desc": "1950Hz/1300Hzデュアルスイープ。知的で精緻な集束レーザー音。"
    },
    {
        "id": "AUD-020",
        "category": "sfx",
        "title": "マフィオ通常ショット SE",
        "subtitle": "0.18s / Bio-Kinetic",
        "file": os.path.join(PREVIEW_DIR, "sfx", "se_shot_mafio.wav"),
        "loop": False,
        "desc": "165Hz→42Hz重低音＋クラッシュ。食欲旺盛・力強い生体弾撃音。"
    },
    {
        "id": "AUD-021",
        "category": "sfx",
        "title": "ボス大技予兆 SE",
        "subtitle": "0.85s / FM Threat",
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
  <title>Mw-fActory Sound Player - 曼珠沙華</title>
  <script src="https://www.gstatic.com/antigravity/web/dev/tailwindcss.min.js"></script>
</head>
<body class="bg-transparent text-[var(--foreground)] antialiased p-3">
  <div class="bg-[var(--card)] text-[var(--foreground)] border border-[var(--border)] rounded-2xl p-5 shadow-lg max-w-4xl mx-auto">
    <!-- Header -->
    <div class="flex flex-wrap items-center justify-between pb-4 mb-4 border-b border-[var(--border)]">
      <div>
        <div class="flex items-center gap-2">
          <span class="inline-block w-3 h-3 rounded-full bg-red-500 animate-pulse"></span>
          <span class="text-xs font-bold tracking-widest text-red-500 uppercase">Mw-fActory Sound Studio</span>
        </div>
        <h1 class="text-xl font-bold tracking-tight mt-1 text-[var(--foreground)]">『曼珠沙華（MANJUSHAGE）』試聴プレイヤー</h1>
        <p class="text-xs text-[var(--muted-foreground)]">第1期 制作音響素材（全10曲・効果音）/ 44.1kHz 16-bit PCM 原本プレビュー</p>
      </div>
      <div class="flex gap-2 mt-2 sm:mt-0">
        <button onclick="filterCategory('all')" id="btn-all" class="px-3 py-1.5 text-xs font-semibold rounded-lg bg-[var(--primary)] text-[var(--primary-foreground)] shadow-sm">すべて (14)</button>
        <button onclick="filterCategory('bgm')" id="btn-bgm" class="px-3 py-1.5 text-xs font-semibold rounded-lg bg-[var(--secondary)] text-[var(--secondary-foreground)] hover:bg-[var(--border)]">BGM (8)</button>
        <button onclick="filterCategory('jingle')" id="btn-jingle" class="px-3 py-1.5 text-xs font-semibold rounded-lg bg-[var(--secondary)] text-[var(--secondary-foreground)] hover:bg-[var(--border)]">ジングル (1)</button>
        <button onclick="filterCategory('sfx')" id="btn-sfx" class="px-3 py-1.5 text-xs font-semibold rounded-lg bg-[var(--secondary)] text-[var(--secondary-foreground)] hover:bg-[var(--border)]">SE (5)</button>
      </div>
    </div>

    <!-- Active Player Bar -->
    <div class="bg-[var(--background)] border border-[var(--border)] rounded-xl p-4 mb-5 shadow-inner">
      <div class="flex flex-wrap items-center justify-between gap-3 mb-2">
        <div class="flex items-center gap-3">
          <button id="master-play-btn" onclick="togglePlay()" class="w-10 h-10 rounded-full bg-red-600 hover:bg-red-500 text-white flex items-center justify-center shadow-md font-bold text-sm">
            ▶
          </button>
          <div>
            <div id="now-title" class="text-sm font-bold text-[var(--foreground)]">曲を選択してください</div>
            <div id="now-sub" class="text-xs text-[var(--muted-foreground)]">クリックして再生を開始します</div>
          </div>
        </div>
        <div class="flex items-center gap-4 text-xs">
          <label class="flex items-center gap-1.5 cursor-pointer">
            <input type="checkbox" id="loop-toggle" onchange="toggleLoop()" class="rounded border-[var(--border)]">
            <span class="text-[var(--muted-foreground)]">シームレスループ</span>
          </label>
          <div class="flex items-center gap-1.5">
            <span class="text-[var(--muted-foreground)]">音量</span>
            <input type="range" id="vol-slider" min="0" max="1" step="0.05" value="0.8" oninput="setVolume(this.value)" class="w-20 cursor-pointer">
          </div>
        </div>
      </div>
      <!-- Progress Bar -->
      <div class="w-full bg-[var(--border)] h-2 rounded-full overflow-hidden cursor-pointer" onclick="seekAudio(event)">
        <div id="progress-bar" class="bg-red-500 h-full w-0 transition-all duration-100"></div>
      </div>
      <div class="flex justify-between text-[11px] text-[var(--muted-foreground)] mt-1 font-mono">
        <span id="current-time">0:00</span>
        <span id="total-time">0:00</span>
      </div>
    </div>

    <!-- Track Grid -->
    <div id="track-list" class="grid grid-cols-1 md:grid-cols-2 gap-3">
      <!-- Generated via JS -->
    </div>
  </div>

  <audio id="audio-elem"></audio>

  <script>
    const tracks = {json_tracks};
    const audio = document.getElementById('audio-elem');
    let currentTrack = null;
    let currentFilter = 'all';

    function init() {{
      renderTracks();
      audio.volume = 0.8;
      audio.ontimeupdate = updateProgress;
      audio.onended = () => {{
        if (!audio.loop) {{
          document.getElementById('master-play-btn').innerText = '▶';
          updateTrackCardButton(null);
        }}
      }};
    }}

    function filterCategory(cat) {{
      currentFilter = cat;
      ['all', 'bgm', 'jingle', 'sfx'].forEach(c => {{
        const btn = document.getElementById('btn-' + c);
        if (c === cat) {{
          btn.className = 'px-3 py-1.5 text-xs font-semibold rounded-lg bg-[var(--primary)] text-[var(--primary-foreground)] shadow-sm';
        }} else {{
          btn.className = 'px-3 py-1.5 text-xs font-semibold rounded-lg bg-[var(--secondary)] text-[var(--secondary-foreground)] hover:bg-[var(--border)]';
        }}
      }});
      renderTracks();
    }}

    function renderTracks() {{
      const container = document.getElementById('track-list');
      container.innerHTML = '';
      tracks.forEach((t, idx) => {{
        if (currentFilter !== 'all' && t.category !== currentFilter) return;

        const isPlaying = currentTrack && currentTrack.id === t.id && !audio.paused;
        const card = document.createElement('div');
        card.id = 'card-' + t.id;
        card.className = `p-3.5 rounded-xl border transition-all flex flex-col justify-between ${{
          currentTrack && currentTrack.id === t.id
            ? 'border-red-500 bg-[var(--background)] shadow-sm ring-1 ring-red-500/30'
            : 'border-[var(--border)] bg-[var(--card)] hover:border-[var(--muted-foreground)]'
        }}`;

        card.innerHTML = `
          <div>
            <div class="flex items-center justify-between gap-2 mb-1">
              <span class="text-[11px] font-mono font-bold px-2 py-0.5 rounded bg-[var(--secondary)] text-[var(--secondary-foreground)]">${{t.id}}</span>
              <span class="text-[11px] font-mono text-[var(--muted-foreground)]">${{t.subtitle}}</span>
            </div>
            <h3 class="text-sm font-bold text-[var(--foreground)] mb-1">${{t.title}}</h3>
            <p class="text-xs text-[var(--muted-foreground)] line-clamp-2 mb-3">${{t.desc}}</p>
          </div>
          <div class="flex items-center justify-between pt-2 border-t border-[var(--border)] mt-auto">
            <span class="text-[11px] text-red-500 font-semibold">${{t.category === 'bgm' ? 'シームレスループ可' : 'ワンショット'}}</span>
            <button onclick="playTrack(${{idx}})" id="btn-play-${{t.id}}" class="px-3 py-1 text-xs font-bold rounded-lg ${{
              isPlaying ? 'bg-red-600 text-white' : 'bg-[var(--secondary)] text-[var(--foreground)] hover:bg-red-600 hover:text-white'
            }}">
              ${{isPlaying ? '⏸ 停止' : '▶ 試聴'}}
            </button>
          </div>
        `;
        container.appendChild(card);
      }});
    }}

    function playTrack(idx) {{
      const track = tracks[idx];
      if (currentTrack && currentTrack.id === track.id) {{
        if (audio.paused) {{
          audio.play();
          document.getElementById('master-play-btn').innerText = '⏸';
        }} else {{
          audio.pause();
          document.getElementById('master-play-btn').innerText = '▶';
        }}
      }} else {{
        currentTrack = track;
        audio.src = track.data_uri;
        audio.loop = track.loop;
        document.getElementById('loop-toggle').checked = track.loop;
        document.getElementById('now-title').innerText = track.title;
        document.getElementById('now-sub').innerText = track.subtitle;
        audio.play();
        document.getElementById('master-play-btn').innerText = '⏸';
      }}
      renderTracks();
    }}

    function togglePlay() {{
      if (!currentTrack) {{
        playTrack(0);
        return;
      }}
      if (audio.paused) {{
        audio.play();
        document.getElementById('master-play-btn').innerText = '⏸';
      }} else {{
        audio.pause();
        document.getElementById('master-play-btn').innerText = '▶';
      }}
      renderTracks();
    }}

    function toggleLoop() {{
      audio.loop = document.getElementById('loop-toggle').checked;
    }}

    function setVolume(val) {{
      audio.volume = parseFloat(val);
    }}

    function updateProgress() {{
      if (!audio.duration) return;
      const pct = (audio.currentTime / audio.duration) * 100;
      document.getElementById('progress-bar').style.width = pct + '%';
      document.getElementById('current-time').innerText = formatTime(audio.currentTime);
      document.getElementById('total-time').innerText = formatTime(audio.duration);
    }}

    function seekAudio(e) {{
      if (!audio.duration) return;
      const rect = e.currentTarget.getBoundingClientRect();
      const clickX = e.clientX - rect.left;
      const pct = clickX / rect.width;
      audio.currentTime = pct * audio.duration;
    }}

    function formatTime(sec) {{
      if (isNaN(sec)) return '0:00';
      const m = Math.floor(sec / 60);
      const s = Math.floor(sec % 60);
      return m + ':' + (s < 10 ? '0' : '') + s;
    }}

    window.onload = init;
  </script>
</body>
</html>
"""

with open(OUTPUT_HTML, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"=== Audio Player HTML written to {OUTPUT_HTML} ({len(html_content)} bytes) ===")

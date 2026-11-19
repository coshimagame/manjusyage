# Mw-fActory: Ableton Live 制作・連携ガイド (v1.0)

対象：**Ableton Live 10 / 11 / 12 (Suite / Standard)**  
制作：**Mw-fActory 音楽制作責任者（Antigravity）**

---

## 1. 概要

本プロジェクト『曼珠沙華（MANJUSHAGE）』の全BGM楽曲（全14曲）は、Ableton Liveでの即時インポート、音色再設計、リミックス、および演奏が完全に行えるよう以下の2系統で整備されています。

1. **フルマルチトラックMIDI（SMF Format 1）**：`assets/audio/midi/*.mid`
2. **パート別クリップMIDI（Ableton Drag & Drop専用）**：`assets/audio/ableton/MIDI_Clips/*.mid`

---

## 2. Ableton Live での取り込み手順

### A. 楽曲全体を新規Live Setへ取り込む場合
1. Ableton Liveを起動し、新規Live Setを開きます。
2. Abletonのブラウザー（左側 `Places` またはエクスプローラー）から、目的のマルチトラックMIDI（例：`bgm_stage04_plan_a.mid`）を**Arrangementビューのトラックエリアへドラッグ＆ドロップ**します。
3. Liveから「テンポと拍子の変更をインポートしますか？」というダイアログが表示されたら、**「はい」**を選択してください。
   - BPM（例：165 BPM）と拍子（4/4、6/8、3/4）がマスタータイムラインに自動設定されます。
   - `Lead`、`Arpeggio`、`Chords/Pad`、`Bass`、`Drums` が個別のMIDIトラックとして自動生成されます。

### B. 個別パートを好きな音源（Operator, Wavetable, Drum Rack等）に割り当てる場合
`assets/audio/ableton/MIDI_Clips/` 内のファイルは、BPM・調性・パート名が明記されています：
- `Lead_165BPM_Emin_Stage04A.mid` → Liveの **Operator** や **Analog** へドロップ
- `Arp_165BPM_Emin_Stage04A.mid` → Liveの **Wavetable** へドロップ
- `Bass_165BPM_Emin_Stage04A.mid` → Liveの **Tension** や **Sub-Bass Operator** へドロップ
- `Lead_82BPM_Dmin_OpeningA.mid` → **Simpler** / **Sampler**（尺八・木管インストゥルメント）へドロップ

---

## 3. ドラム・打楽器のAbleton Drum Rackマッピング

全ドラムトラックは General MIDI (GM) 標準キーマッピングに準拠しています：
- **C1 (Note 36)**: Bass Drum / Kick
- **D1 (Note 38)**: Snare Drum / Rim
- **F#1 (Note 42)**: Closed Hi-Hat
- **A#1 (Note 46)**: Open Hi-Hat
- **C#2 (Note 49)**: Crash Cymbal
- **E2 / G2 (Note 52/55)**: Chinese Cymbal / Splash
- **C2 / D2 (Note 48/50)**: High / Mid Tom / Taiko

Ableton Liveのデフォルト **Drum Rack** や **Kit-Core 909 / 808** をそのままトラックにロードするだけで、即座に正しいパッドで発音します。

---

## 4. オーディオステムの活用

`assets/audio/music/` 内のマスターWAVをAbleton Liveのオーディオトラックに配置し、Liveの **Warp（Complex Pro / Beats モード）** を有効にすることで、ゲーム中のBPM変更やクロスフェード検証をDAW上で直感的にシミュレート可能です。

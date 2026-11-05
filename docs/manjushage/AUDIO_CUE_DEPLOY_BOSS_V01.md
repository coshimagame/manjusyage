# 出撃・ボス登場音楽キュー v0.1
2026-11-05。SFC風PCM／サンプルベースの温かい音を主役。**設計のみ、WAV未制作、Godot未組込・未検証**。既存曲を上書きしない。

## 出撃 DEPLOY-001
128 BPM、4拍子、D minorからF majorの希望をにじませる2小節＝3.75秒。独自の8音上昇フレーズ。イベント（開始拍/音高/長さ拍）：0/D4/0.5、0.5/F4/0.5、1/G4/0.5、1.5/A4/0.5、2/C5/1、3/D5/1、4/F5/1、5/E5/1、6/D5/2。最後のD5は余韻。PCMベル、短いブラス、温かなベース、薄いアルペジオ。タイトルSTART押下は即座にボタン視覚反応、ロード完了後ジングルを一度だけ鳴らし、次小節頭で道中BGMへ。教習／再会／EDはこの音型の速度・音色・和声を変奏。

## ボス登場 BOSS-INTRO-001
道中BGMの音数を0.25〜0.5秒で減らす→低い鼓動／機械パルス→128 BPMの2小節3.75秒でD3-A3-C4-E4-F4へ上昇→最後の拍でボス名→次小節頭にボスBGM。生体ボスは鼓動と笙風の柔らかい和音、機械ボスは金属の短い残響、記憶を持つボスは出撃モチーフ後半を和声的に歪ませる。画面点滅を使わず、敵弾・被弾SEの明瞭さを優先。

## Codex/Antigravity実装仕様
AudioStreamPlayerを title/stage/boss/cue の4系統に分離。CueControllerは IDLE→DEPLOY→STAGE→BOSS_INTRO→BOSS→CLEAR の状態機械。入力連打をガードしscene_tokenで古いタイマーを無効化。音声のget_length()を使いロード遅延・拍同期を補正。ポーズ時は全プレイヤー停止。リトライは出撃キュー再演可、セーブ復帰は短縮オプション。ボス直前死亡で重複発音しない。音声ファイルは新規名 audio/cues/deploy_128bpm_v01.wav と audio/cues/boss_intro_128bpm_v01.wav を予定、既存audioは不変更。

検証：Godot4.6インポート、START連打、パッド反応、ロード遅延、1〜3人、ポーズ、リトライ、ボス再戦、SEとの音量バランス。**いずれも未実施**。

## UI/人物素材の次回制作台帳
art/ui/buttons/start_{normal,hover,pressed,disabled}.png（各128x32 RGBA）
art/ui/hud/gauge_{hp,energy,boss}_{empty,fill}.png（各96x12 RGBA）
art/portraits/{colmii,jiyoza,mafio}/{neutral,smile,angry,sad,surprised}.png（各96x96 RGBA）
既存の確定原画とart/activeの11スロットを保護。今回は命名とサイズの提案のみ、PNG未制作・未採用。
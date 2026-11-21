# v0.9 パイロット会話肖像 — 採用台帳

2026-11-21　[3人の指定透過原本・自機の横と縦を一枚で参照](../../../docs/manjushage/PILOT_SHIP_REFERENCE.md)。現行の会話・ステータスはこの原本から縮小描画する。

## 11月17日版での採用範囲

2026-11-17、ユーザーがこの3人の背景透過ビジュアルを「基本」として指定した。11月17日の試遊版では、ステータス画面、プロローグの発話者肖像、Stage 1クリア後の通信幕間で共通に使う。ゲーム上の呼称と性別は既存の設定を維持する。

| パイロット | 選定済み透過ソース | 11月17日のドット絵 | 表示先 |
|---|---|---|---|
| コルミィ | `art/originals/pilots/cormii_transparent_source_v01.png` | `cormii_dialogue_pixel_v01.png` | ステータス／プロローグ／幕間 |
| ジヨーザ（男の子） | `art/originals/pilots/jiyoza_transparent_source_v01.png` | `jiyoza_dialogue_pixel_v01.png` | ステータス／プロローグ／幕間 |
| マフィオ（ボーイッシュな女の子） | `art/originals/pilots/mafio_transparent_source_v01.png` | `mafio_dialogue_pixel_v01.png` | ステータス／プロローグ／幕間 |

## 11月17日版の来歴と制作方法

- 選定済み透過ソースのコピー元: `C:\Users\wa-ma\Documents\Codex\2026-11-07\new-chat\outputs\manjushage-transparent\characters\`。同梱`manifest.json`は、これらを「reference-based generated derivative」であり、失われた原画を復元したものではないと記録している。
- 11月17日版: CodexのImageGenで2026-11-17に各選定ソースから生成。透明背景を維持し、既存のポーズ、表情、髪色、衣装の識別を保ちながら、640×360のUIでnearest表示できる16bit風のドット絵表現へ変換した。外部ゲームの人物・ロゴ・文字は指定・使用していない。
- 採用状態: ユーザー指示に基づく**11月17日の試遊版の基本肖像**。服装等の全詳細を長期の公式設定として新規決定したものではない。正式設定を更新する場合は、別途CANON/CHARACTERSの判断を要する。
- 置換時: 同名ファイルを上書きせず、`*_v02`を追加してからコード、`ART_ASSETS.md`、実画面をまとめて更新する。元の選定ソースは消さない。

## 版・検証値

| ファイル | 寸法 | SHA-256 |
|---|---:|---|
| `art/originals/pilots/cormii_transparent_source_v01.png` | 1312×1199 | `cbb7fd80d24a281751d886fc2f0d392385f0eb7553818265f34f572670eda7b2` |
| `art/originals/pilots/jiyoza_transparent_source_v01.png` | 1117×1408 | `ad51cc0b5f9b81a15c60743c2d65b7ac4a1e94751c09fed5239de8a1a111687e` |
| `art/originals/pilots/mafio_transparent_source_v01.png` | 1159×1356 | `2fbd33fb8eae15986f7349820ded1d1c86d0be740ef93b96810b81208d464831` |
| `cormii_dialogue_pixel_v01.png` | 1312×1199 | `4e5620cba8cf2edc5e7bcd11a04ac691924639ec9d8134342037b947227f85ef` |
| `jiyoza_dialogue_pixel_v01.png` | 1117×1408 | `980a00e870939b8c36aeb67af9b6c06ec699ee19c8e2934eacafb00f3aa7f28e` |
| `mafio_dialogue_pixel_v01.png` | 1159×1357 | `723f9685b3f906c6e85ce2c331e72d4f173dbf81c1592f0c30b57dc4f590f092` |

## 11月17日版の検証状態

- Godot 4.6.3 console + 隔離`APPDATA`: `test_status_v09.gd`、`test_prologue.gd`、`stage_intermission_smoke.gd`、`test_v09.gd`がPASS。
- `docs/screenshots/latest/prologue_cormii_pixel_dialogue_20261117.png`は通常レンダラーで保存済みの640×360会話画面。コルミィの発話時にこのドット絵肖像が表示される。
- 人間のキーボード操作、物理コントローラー、音楽の実聴、性能測定は未検証。今回のシェルからの通常Godot再起動はWindows signal 11で失敗し、配布用Windowsパッケージの更新はしていない。

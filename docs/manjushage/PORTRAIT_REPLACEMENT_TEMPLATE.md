# 主人公の表情画像：差し替え用テンプレート（2026-11-05）

この仕組みは「プログラムを触らずにPNGを交換する」ための共通枠です。正式キャラクター画像を新規に決めたり、既存の原画を上書きしたりするものではありません。

## 画像の置き場所
- `art/active/portraits/cormii/neutral.png` （コルミィ）
- `art/active/portraits/jiyoza/neutral.png` （ジヨーザ）
- `art/active/portraits/mafio/neutral.png` （マフィオ）

各フォルダで使える表情名：`neutral.png`, `happy.png`, `focused.png`, `worried.png`, `hurt.png`, `digesting.png`。

**差し替え方**：正式採用したPNGを対応するファイル名で置く → Godotで再インポート → Windows試遊版を再ビルド。コードの編集は不要。表情画像が未登録の場合はゲーム内の簡易表情表示へ自動で戻る。特定の表情だけ未登録なら `neutral.png` に戻る。

## 素材制作の雛形
- 推奨：透明背景PNG、64×64 px または 128×128 px、1キャラ・1表情につき1枚
- 全表情で同じキャンバスサイズ・顔の位置・髪型・服装・パレットを保つ
- ステータス画面の表示領域はゲーム座標 62×39 px。顔が見切れないように余白を設ける
- 正式な採用判断前の候補は `art/concept/` に保管し、`art/active/portraits/` には採用済みだけを置く
- ファイル名は英小文字。画像の差し替え後はWindowsビルドで実表示を確認する

## 現在の状態
`portrait_slots.gd` がPNGを任意ロードし、`game.gd` のステータス画面で表示。画像の実体はこの変更に含まれない。ビルド・実機動作検証は別途必要。

将来、会話画面やキャラクター選択画面も同じ `portrait_slots.gd` を使う。独立した顔画像の複製を増やさず、共通の正式素材を参照する。

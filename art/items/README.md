# アイテム素材 — 共通とキャラ固有を分けて管理

## 保存先

| 分類 | アイテム | 新しい画像パス |
| --- | --- | --- |
| 全キャラ共通 | HP回復 | `common/hp/icon.png` |
| 全キャラ共通 | エネルギー | `common/energy/icon.png` |
| コルミィ専用 | 開運おみくじ | `characters/cormii/omikuji/icon.png` |
| ジヨーザ専用 | 解析結晶 | `characters/jiyoza/analysis/icon.png` |
| マフィオ専用 | 未確定 | `characters/mafio/`（追加待ち） |

**各アイテムは別フォルダ**なので、すべて `icon.png` でも混ざらない。キャラ固有のアイテムが増えたら `characters/キャラ名/アイテム名/icon.png` に追加する。敵を食べて技を得るマフィオの能力と、拾う固有アイテムを混同しない。

読み込み順は **新しい分類パス → 旧 `art/items/アイテム名/icon.png` → `art/active/item_*.png` → 既存プログラム描画**。既存PNGの移動・削除はしない。原画取り込み・Godot実行検証は未完了。
